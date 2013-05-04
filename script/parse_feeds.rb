#!/usr/bin/env ruby.exe
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
    if (/Review/ =~ entry.title) # is Review

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
                    puts "found positive"
                    sentiment = 1
                  elsif (/^NEGATIVES$/ =~ word)
                    puts "found negative"
                    sentiment = -1
                  else
                    if ((div.downcase.include?(' '+word.downcase.strip+' ')) && (sentiment == 1) && !(/^POSITIVES$/ =~ word))
                      puts ep_title+" Positive: "+word
                      positives = positives + 1
                    elsif ((div.downcase.include?(' '+word.downcase.strip+' ')) && (sentiment == -1) && !(/^NEGATIVES$/ =~ word))
                      puts ep_title+" Negative: "+word
                      negatives = negatives + 1
                    end
                  end 
                end
              end
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type,positives,negatives) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[div,year,ep_title,author,entry.url,"TV.com",eps[0]["id"],"TvEpisode",positives,negatives])
            end
          end
        end
      end
    end
  end
  bdfeed.entries.each do |entry|
    if (/^.{1,}: .{1,}$/ =~ entry.title)
      #puts "Found review"
      require 'nokogiri'
      require 'open-uri'
      doc = Nokogiri::HTML(open(entry.url))
      doc.css('br').each{ |br| br.replace "\n" }
      div = doc.css('div.post-body')
      div.at_css("div.separator")
      div = div.inner_text
      #puts "there"
      #puts div.inner_text
      show_title = entry.title.split(":").first.strip
      ep_title = entry.title.split(":").last.strip
      #puts show_title
      #puts ep_title
      shows = conn.exec('SELECT id FROM tv_shows where title = $1;',[show_title])
      #puts "NUM shows: "+shows.num_tuples.to_s
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
                    puts "found positive"
                    sentiment = 1
                  elsif (/^NEGATIVES$/ =~ word)
                    puts "found negative"
                    sentiment = -1
                  else
                    if ((div.downcase.include?(' '+word.downcase.strip+' ')) && (sentiment == 1) && !(/^POSITIVES$/ =~ word))
                      puts ep_title+" Positive: "+word
                      positives = positives + 1
                    elsif ((div.downcase.include?(' '+word.downcase.strip+' ')) && (sentiment == -1) && !(/^NEGATIVES$/ =~ word))
                      puts ep_title+" Negative: "+word
                      negatives = negatives + 1
                    end
                  end 
                end
              end
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type,positives,negatives) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[div,year,ep_title,entry.author,entry.url,"DouxReviews.com",eps[0]["id"],"TvEpisode",positives,negatives])
              #puts "Found correct episode"
            else
              #puts "Already inserted episode"
            end
          else
            #puts "Couldn't find any eps"
          end
        end
      end
    end
  end
  fanaticfeed.entries.each do |entry|
    if (/Season \d{1,2}, Episode \d{1,2}/ =~ entry.title)

      #puts " "
      require 'nokogiri'
      require 'open-uri'
      breakNow = false
      doc = Nokogiri::HTML(open(entry.url))
      doc.css('br').each{ |br| br.replace "\n" }
      div = doc.css('div.description').inner_text
      author = doc.css('span.reviewer').inner_text.strip
      show_title = /^.{1,} Season/.match(entry.title)[0].split(' Season').first.strip
      puts show_title
      ep_title = /".{1,}$/.match(entry.title)[0].sub('"','').strip
      puts ep_title
      season_number = /Season \d{1,2}, Episode \d{1,2}/.match(entry.title)[0].split(', ').first.sub('Season ','')
      puts season_number
      episode_number = /Season \d{1,2}, Episode \d{1,2}/.match(entry.title)[0].split(', ').last.sub('Episode ','')
      puts episode_number

      shows = conn.exec('SELECT id FROM tv_shows where title = $1;',[show_title])
      shows.each do |show|
        seasons = conn.exec('SELECT id FROM tv_seasons where tv_show_id = $1;',[show["id"]])
        seasons.each do |season|
          eps = conn.exec('SELECT id FROM tv_episodes where tv_season_id = $1 and number = $2 and upper(title) like upper($3);',[season["id"],episode_number,ep_title])
          if eps.num_tuples > 0
            year = Date.parse(Time.now.strftime('%Y/%m/%d')).to_s
            alreadyInserted = conn.exec('SELECT id FROM reviews where title = $1 and author = $2 and website = $3 and reviewable_id = $4;',[ep_title,author,"TVFanatic.com",eps[0]["id"]])

            if alreadyInserted.num_tuples == 0
              positives = 0
              negatives = 0
              sentiment = 0
              File.open("lib/assets/sentimentwords.txt", "r") do |f|
                f.each_line do |word|
                  if (/^POSITIVES$/ =~ word)
                    puts "found positive"
                    sentiment = 1
                  elsif (/^NEGATIVES$/ =~ word)
                    puts "found negative"
                    sentiment = -1
                  else
                    if ((div.downcase.include?(' '+word.downcase.strip+' ')) && (sentiment == 1) && !(/^POSITIVES$/ =~ word))
                      puts ep_title+" Positive: "+word
                      positives = positives + 1
                    elsif ((div.downcase.include?(' '+word.downcase.strip+' ')) && (sentiment == -1) && !(/^NEGATIVES$/ =~ word))
                      puts ep_title+" Negative: "+word
                      negatives = negatives + 1
                    end
                  end 
                end
              end
              puts "inserting"
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type,positives,negatives) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[div,year,ep_title,author,entry.url,"TVFanatic.com",eps[0]["id"],"TvEpisode",positives,negatives])
            else
              puts "NOT INSERTING"
            end
          end
        end
      end
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
      author = doc.css('link[rel=author]')[0]
      puts "author " +author.to_s+"."
      show_title = /^.{1,} Season \d{1,2}/.match(entry.title)[0].gsub(/ Season \d{1,2}/,'').strip
      puts show_title+"."
      ep_title = /^.{1,} Season \d{1,2} .{1,}$/.match(entry.title)[0].gsub(/^.{1,} Season \d{1,2} Review /,'')
      ep_title.gsub!(8220.chr(Encoding::UTF_8), '"').gsub('" .{1,}','')
      ep_title = ep_title[1..ep_title.length-2]
      puts ep_title+"."
      season_number = /^.{1,} Season \d{1,2}/.match(entry.title)[0].gsub(/^.{1,} Season /,'').strip
      puts season_number.to_s+"."
      puts " "

      shows = conn.exec('SELECT id FROM tv_shows where title = $1;',[show_title])
      shows.each do |show|
        seasons = conn.exec('SELECT id FROM tv_seasons where tv_show_id = $1;',[show["id"]])
        seasons.each do |season|
          eps = conn.exec('SELECT id FROM tv_episodes where tv_season_id = $1 and upper(title) like upper($2);',[season["id"],ep_title]) 
          if eps.num_tuples > 0
            year = Date.parse(Time.now.strftime('%Y/%m/%d')).to_s
            alreadyInserted = conn.exec('SELECT id FROM reviews where title = $1 and author = $2 and website = $3 and reviewable_id = $4;',[ep_title,author,"TVEquals.com",eps[0]["id"]])

            if alreadyInserted.num_tuples == 0
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8)',[div,year,ep_title,author,entry.url,"TVEquals.com",eps[0]["id"],"TvEpisode"])
              break
            end
          end
        end
      end
    end
  end
  conn.close()
else
  puts "Could not connect to database!"
end