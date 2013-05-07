#!/usr/bin/env ruby.exe
# encoding: utf-8

require 'feedzirra'

# fetching a single feed
bdfeed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/BillieDoux")
tvfeed = Feedzirra::Feed.fetch_and_parse("http://feedity.com/tv-com/VlNVUFdU.rss")
fanaticfeed = Feedzirra::Feed.fetch_and_parse("http://feedity.com/tvfanatic-com/VlNUUltb.rss")
equalsfeed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/tvequals")

begin
  heroku = false
  conn = PGconn.open(:dbname => 'development', :port => 5432)
rescue
  heroku = true
  conn = PGconn.open("dbname=d9brbfi46siqi host=ec2-54-225-112-205.compute-1.amazonaws.com port=5432 user=ekyfschexohgiw password=Et0EzcB-nWkhrlIJaMhn1W_TIk sslmode=require")
end

if conn 
  tvfeed.entries.each do |entry|
    if (/Review:/ =~ entry.title) # is Review

      require 'nokogiri'
      require 'open-uri'
      doc = Nokogiri::HTML(open(entry.url))
      doc.css('br').each{ |br| br.replace "\n" }
      div = doc.css('div.content')
      header = div.css('p')[0].text
      div = div.inner_text.strip.sub /^.{1,}S\d{1,2}E\d{1,2}:.{1}".{1,45}"/, ''
      ep_title = /".{1,}"/.match(header[0,80])[0]
      ep_title = ep_title.gsub('"','').strip

      season_number = /S\d{1,2}E\d{1,2}/.match(header[0,80])[0].gsub(/E\d{1,2}/,'').gsub('S','')
      episode_number = /S\d{1,2}E\d{1,2}/.match(header[0,80])[0].gsub(/S\d{1,2}E/,'')
      if !(show_title = /^.{1,}S\d{1,2}E\d{1,2}/.match(header[0,80]).nil?)
        show_title = /^.{1,}S\d{1,2}E\d{1,2}/.match(header[0,80])[0].strip
        show_title = show_title.gsub(/S\d{1,2}E\d{1,2}/,'').gsub(/\A[[:space:]]+|[[:space:]]+\z/, '').strip
      else
        show_title = ""
      end

      author = /By .{1,20},/.match(entry.title)
      if !author.nil? and author.length > 0
        author = author[0][2,author[0].to_s.length-2].strip.chomp(',') 
      else
        author = ""
      end
      shows = conn.exec('SELECT id FROM tv_shows where title = $1;',[show_title])
      shows.each do |show|
        seasons = conn.exec('SELECT id FROM tv_seasons where tv_show_id = $1 and number = $2;',[show["id"],season_number])
        seasons.each do |season|
          liketitle = false
          if shows.num_tuples > 1
            eps = conn.exec('SELECT id FROM tv_episodes where tv_season_id = $1 and number = $2 and upper(title) like upper($3);',[season["id"],episode_number,'%'+ep_title+'%'])
            liketitle = true
          else
            eps = conn.exec('SELECT id FROM tv_episodes where tv_season_id = $1 and number = $2;',[season["id"],episode_number])
          end  
          if eps.num_tuples > 0
            year = Date.parse(Time.now.strftime('%Y/%m/%d')).to_s

            if liketitle
              alreadyInserted = conn.exec('SELECT id FROM reviews where upper(title) like upper($1) and author = $2 and website = $3 and reviewable_id = $4;',['%'+ep_title+'%',author,"TV.com",eps[0]["id"]])
            else
              alreadyInserted = conn.exec('SELECT id FROM reviews where title = $1 and author = $2 and website = $3 and reviewable_id = $4;',[ep_title,author,"TV.com",eps[0]["id"]])
            end

            if alreadyInserted.num_tuples == 0
              positives = 0
              negatives = 0
              sentiment = 0
              File.open("lib/assets/sentimentwords.txt", "r") do |f|
                f.each_line do |word|
                  if (/^POSITIVES$/ =~ word)
                    #puts "found positive"
                    sentiment = 1
                  elsif (/^NEGATIVES$/ =~ word)
                    #puts "found negative"
                    sentiment = -1
                  else
                    if ((div.downcase.include?(' '+word.downcase.strip)) && (sentiment == 1) && !(/^POSITIVES$/ =~ word))
                      #puts ep_title+" Positive: "+word
                      positives = positives + 1
                    elsif ((div.downcase.include?(' '+word.downcase.strip)) && (sentiment == -1) && !(/^NEGATIVES$/ =~ word))
                      #puts ep_title+" Negative: "+word
                      negatives = negatives + 1
                    end
                  end 
                end
              end
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type,positives,negatives) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[div,year,ep_title,author,entry.url,"TV.com",eps[0]["id"],"TvEpisode",positives,negatives])
            else
              puts "already inserted: "+ show_title+"." + ep_title+ " "+season_number.to_s+ " "+episode_number.to_s
              puts " "
            end
          end
        end
      end
    else
      puts "no eps: "+show_title.to_s+"."+ep_title.to_s+"."
    end
  end
  bdfeed.entries.each do |entry|
    if (/^.{1,}: .{1,}$/ =~ entry.title)
      require 'nokogiri'
      require 'open-uri'
      doc = Nokogiri::HTML(open(entry.url))
      doc.css('br').each{ |br| br.replace "\n" }
      div = doc.css('div.post-body')
      div.at_css("div.separator")
      div = div.inner_text

      show_title = entry.title.split(":").first.strip
      ep_title = entry.title.split(":").last.strip

      shows = conn.exec('SELECT id FROM tv_shows where title = $1;',[show_title])
      shows.each do |show|
        seasons = conn.exec('SELECT id FROM tv_seasons where tv_show_id = $1;',[show["id"]])
        seasons.each do |season|
          eps = conn.exec('SELECT id FROM tv_episodes where title = $1 and tv_season_id = $2;',[ep_title,season["id"]])
          if eps.num_tuples > 0
            year = Date.parse(Time.now.strftime('%Y/%m/%d')).to_s
            alreadyInserted = conn.exec('SELECT id FROM reviews where title = $1 and author = $2 and website = $3 and reviewable_id = $4;',[ep_title,entry.author,"DouxReviews.com",eps[0]["id"]])

            if alreadyInserted.num_tuples == 0
              positives = 0
              negatives = 0
              sentiment = 0
              File.open("lib/assets/sentimentwords.txt", "r") do |f|
                f.each_line do |word|
                  if (/^POSITIVES$/ =~ word)
                    #puts "found positive"
                    sentiment = 1
                  elsif (/^NEGATIVES$/ =~ word)
                    #puts "found negative"
                    sentiment = -1
                  else
                    if ((div.downcase.include?(' '+word.downcase.strip)) && (sentiment == 1) && !(/^POSITIVES$/ =~ word))
                      #puts ep_title+" Positive: "+word
                      positives = positives + 1
                    elsif ((div.downcase.include?(' '+word.downcase.strip)) && (sentiment == -1) && !(/^NEGATIVES$/ =~ word))
                      #puts ep_title+" Negative: "+word
                      negatives = negatives + 1
                    end
                  end 
                end
              end
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type,positives,negatives) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[div,year,ep_title,entry.author,entry.url,"DouxReviews.com",eps[0]["id"],"TvEpisode",positives,negatives])
              #puts "Found correct episode"
            else
              puts "Already inserted: "+show_title+"." + ep_title+"."
              puts " "
            end
          else
            puts "No eps "+show_title+"."+ep_title+"."
          end
        end
      end
    end
  end
  fanaticfeed.entries.each do |entry|
    if (/Season \d{1,2}, Episode \d{1,2}/ =~ entry.title)

      puts "fanatic feed"
      require 'nokogiri'
      require 'open-uri'
      breakNow = false
      doc = Nokogiri::HTML(open(entry.url))
      doc.css('br').each{ |br| br.replace "\n" }
      div = doc.css('div.description').inner_text
      author = doc.css('span.reviewer').inner_text.strip
      show_title = /^.{1,} Season/.match(entry.title)[0].split(' Season').first.strip
      ep_title = /".{1,}$/.match(entry.title)[0].sub('"','').strip
      season_number = /Season \d{1,2}, Episode \d{1,2}/.match(entry.title)[0].split(', ').first.sub('Season ','')
      episode_number = /Season \d{1,2}, Episode \d{1,2}/.match(entry.title)[0].split(', ').last.sub('Episode ','')

      puts show_title+"." + ep_title+ " "+season_number.to_s+ " "+episode_number.to_s
      puts " "

      shows = conn.exec('SELECT id FROM tv_shows where title = $1;',[show_title])
      shows.each do |show|
        seasons = conn.exec('SELECT id FROM tv_seasons where tv_show_id = $1 and number = $2;',[show["id"],season_number])
        seasons.each do |season|
          if (shows.num_tuples == 1)
            eps = conn.exec('SELECT id FROM tv_episodes where tv_season_id = $1 and number = $2 and upper(title) like upper($3);',[season["id"],episode_number,ep_title])
          else
            eps = conn.exec('SELECT id FROM tv_episodes where tv_season_id = $1 and number = $2;',[season["id"],episode_number])
          end
          if eps.num_tuples > 0
            year = Date.parse(Time.now.strftime('%Y/%m/%d')).to_s
            alreadyInserted = conn.exec('SELECT id FROM reviews where title = $1 and author = $2 and website = $3',[ep_title,author,"TVFanatic.com"])

            if alreadyInserted.num_tuples == 0
              positives = 0
              negatives = 0
              sentiment = 0
              File.open("lib/assets/sentimentwords.txt", "r") do |f|
                f.each_line do |word|
                  if (/^POSITIVES$/ =~ word)
                    #puts "found positive"
                    sentiment = 1
                  elsif (/^NEGATIVES$/ =~ word)
                    #puts "found negative"
                    sentiment = -1
                  else
                    if ((div.downcase.include?(' '+word.downcase.strip)) && (sentiment == 1) && !(/^POSITIVES$/ =~ word))
                      #puts ep_title+" Positive: "+word
                      positives = positives + 1
                    elsif ((div.downcase.include?(' '+word.downcase.strip)) && (sentiment == -1) && !(/^NEGATIVES$/ =~ word))
                      #puts ep_title+" Negative: "+word
                      negatives = negatives + 1
                    end
                  end 
                end
              end
              puts "inserting"
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type,positives,negatives) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[div,year,ep_title,author,entry.url,"TVFanatic.com",eps[0]["id"],"TvEpisode",positives,negatives])
            else
              puts "already inserted: "+show_title+" "+ep_title
            end
          end
        end
      end
    else
      puts "No eps: "+show_title+"."+ep_title
    end
  end
  equalsfeed.entries.each do |entry|
    if (/^.{1,} Season \d{1,} Review.{1,}/ =~ entry.title)

      puts "in equals feed "
      require 'nokogiri'
      require 'open-uri'
      doc = Nokogiri::HTML(open(entry.url))
      doc.css('br').each{ |br| br.replace "\n" }
      div = doc.css('div.entry').inner_text
      author = doc.css('div.pm-left').inner_text.strip
      author = /By \w{1,20} \w{1,20}/.match(author)
      if !author.nil? and author.length > 0
        author = author[0][2,author[0].to_s.length-2].strip.chomp(',') 
      else
        author = ""
      end

      show_title = /^.{1,} Season \d{1,2}/.match(entry.title)[0].gsub(/ Season \d{1,2}/,'').strip
      ep_title = /^.{1,} Season \d{1,2} .{1,}$/.match(entry.title)[0].gsub(/^.{1,} Season \d{1,2} Review /,'')
      puts "Ep before: "+ep_title
      ep_title.gsub('[\u201C\u201D\u201E\u201F\u2033\u2036]', '"').gsub(/[‘’]/, "'").strip
      ep_title = ep_title[1..ep_title.length-2].strip
      season_number = /^.{1,} Season \d{1,2}/.match(entry.title)[0].gsub(/^.{1,} Season /,'').strip


      shows = conn.exec('SELECT id FROM tv_shows where title = $1;',[show_title])
      shows.each do |show|
        seasons = conn.exec('SELECT id FROM tv_seasons where tv_show_id = $1 and number = $2;',[show["id"],season_number])
        seasons.each do |season|
          eps = conn.exec('SELECT id FROM tv_episodes where tv_season_id = $1 and upper(title) like upper($2);',[season["id"],ep_title]) 
          if eps.num_tuples > 0
            year = Date.parse(Time.now.strftime('%Y/%m/%d')).to_s
            alreadyInserted = conn.exec('SELECT id FROM reviews where title = $1 and author = $2 and website = $3 and reviewable_id = $4;',[ep_title,author,"TVEquals.com",eps[0]["id"]])

            if alreadyInserted.num_tuples == 0
              positives = 0
              negatives = 0
              sentiment = 0
              File.open("lib/assets/sentimentwords.txt", "r") do |f|
                f.each_line do |word|
                  if (/^POSITIVES$/ =~ word)
                    #puts "found positive"
                    sentiment = 1
                  elsif (/^NEGATIVES$/ =~ word)
                    #puts "found negative"
                    sentiment = -1
                  else
                    if ((div.downcase.include?(' '+word.downcase.strip)) && (sentiment == 1) && !(/^POSITIVES$/ =~ word))
                      #puts ep_title+" Positive: "+word
                      positives = positives + 1
                    elsif ((div.downcase.include?(' '+word.downcase.strip)) && (sentiment == -1) && !(/^NEGATIVES$/ =~ word))
                      #puts ep_title+" Negative: "+word
                      negatives = negatives + 1
                    end
                  end 
                end
              end
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type,positives,negatives) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[div,year,ep_title,author,entry.url,"TVEquals.com",eps[0]["id"],"TvEpisode",positives,negatives])
              break
            else
              puts "alreadyInserted: "+show_title+"." + ep_title+ " "+season_number.to_s
              puts "      "
            end
          else
            puts "no eps: "+show_title+"."+ep_title
          end
        end
      end
    end
  end
  conn.close()
else
  puts "Could not connect to database!"
end