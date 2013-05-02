#!/usr/bin/env ruby.exe
require 'feedzirra'

# fetching a single feed
bdfeed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/BillieDoux")
tvfeed = Feedzirra::Feed.fetch_and_parse("http://feedity.com/tv-com/VlNVUFdU.rss")

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
      div = doc.css('div.content')
      header = div.css('p')[0].text
      ep_title = /".{1,}"/.match(header)[0]
      ep_title = ep_title[1,ep_title.length-2].strip
      season_number = /S\d{2}E\d{2}/.match(header)[0][1,2]
      episode_number = /S\d{2}E\d{2}/.match(header)[0][4,5]
      if !(show_title = /^.{1,} S\d{2}E\d{2}/.match(header).nil?)
        show_title = /^.{1,} S\d{2}E\d{2}/.match(header)[0].strip
      else
        show_title = ""
      end
      show_title = show_title[0..show_title.length-7].strip
      puts "- "+show_title.to_s
      puts "+ "+ep_title
      puts " " + season_number + " "
      puts episode_number + " "
      puts show_title 

      div.at_css("a.back_to_top")
      #puts div

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
          eps = conn.exec('SELECT id FROM tv_episodes where tv_season_id = $1 and number = $2;',[season["id"],episode_number])
          if eps.num_tuples > 0
            year = Date.parse(Time.now.strftime('%Y/%m/%d')).to_s
            alreadyInserted = conn.exec('SELECT id FROM reviews where title = $1 and author = $2 and website = $3 and reviewable_id = $4;',[ep_title,author,"TV.com",eps[0]["id"]])

            if alreadyInserted.num_tuples == 0
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8)',[div.inner_text,year,ep_title,author,entry.url,"TV.com",eps[0]["id"],"TvEpisode"])
              puts "Found correct episode"
            else
              puts "Already inserted episode"
            end
          end
        end
      end
    end
  end
  bdfeed.entries.each do |entry|
    if (/^.{1,}: .{1,}$/ =~ entry.title)
      puts "Found review"
      require 'nokogiri'
      require 'open-uri'
      doc = Nokogiri::HTML(open(entry.url))
      div = doc.css('div.post-body')
      div.at_css("div.separator")
      #puts "there"
      #puts div.inner_text
      show_title = entry.title.split(":").first.strip
      ep_title = entry.title.split(":").last.strip
      puts show_title
      puts ep_title
      shows = conn.exec('SELECT id FROM tv_shows where title = $1;',[show_title])
      puts "NUM shows: "+shows.num_tuples.to_s
      shows.each do |show|
        seasons = conn.exec('SELECT id FROM tv_seasons where tv_show_id = $1;',[show["id"]])
        seasons.each do |season|
          eps = conn.exec('SELECT id FROM tv_episodes where title = $1 and tv_season_id = $2;',[ep_title,season["id"]])
          if eps.num_tuples > 0
            year = Date.parse(Time.now.strftime('%Y/%m/%d')).to_s
            if !entry.published.nil?
              year = Date.parse(entry.published.strftime('%Y/%m/%d')).to_s
            end
            alreadyInserted = conn.exec('SELECT id FROM reviews where title = $1 and author = $2 and website = $3 and reviewable_id = $4;',[ep_title,entry.author,"DouxReviews.com",eps[0]["id"]])

            if alreadyInserted.num_tuples == 0
              conn.exec('INSERT INTO reviews (id,content,year_reviewed,title,author,link,website,reviewable_id,reviewable_type) VALUES 
              (DEFAULT,$1,$2,$3,$4,$5,$6,$7,$8)',[div.inner_text,year,ep_title,entry.author,entry.url,"DouxReviews.com",eps[0]["id"],"TvEpisode"])
              puts "Found correct episode"
            else
              puts "Already inserted episode"
            end
          else
            puts "Couldn't find any eps"
          end
        end
      end
    end
  end
  conn.close()
else
  puts "Could not connect to database!"
end