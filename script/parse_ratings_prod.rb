#!/usr/bin/env ruby.exe

require 'rubygems' 
require 'zlib'
require 'open-uri'
require 'pg'
require 'date'

puts "In file"
uri = 'ftp://ftp.fu-berlin.de/pub/misc/movies/database/ratings.list.gz'
source = open(uri)
puts "Got Source"
result = Zlib::GzipReader.new(source)
puts "Finished downloading"

begin
	heroku = false
	conn = PGconn.open(:dbname => 'development', :port => 5432)
rescue
	heroku = true
	conn = PGconn.open("dbname=d9brbfi46siqi host=ec2-54-225-112-205.compute-1.amazonaws.com port=5432 user=ekyfschexohgiw password=Et0EzcB-nWkhrlIJaMhn1W_TIk sslmode=require")
end

puts "Getting ready to parse"

if conn 
	tvratingsreport = false
	result.each do |f|
		f = f.unpack('C*').pack('U*')

	   	if !tvratingsreport && /^MOVIE RATINGS REPORT$/ =~ f #in movie ratings report
	   		tvratingsreport = true
	   	end
		if tvratingsreport && !(/{.{1,}/ =~ f) && /".{1,}" \(.{1,}\)$/ =~ f #if not an episode
			#puts "NOT EPISODE"
			#puts "TV SHOW: "+f

			#get tv title
		  	tString = /".{1,}"/.match(f)[0]
		  	valid_title = (tString[1,tString.length-2].gsub("'","\'\'")).unpack('C*').pack('U*')

	   		if (/\((\d{1,})\)/) =~ f #has tv year 
		    	tvYearMatch = /\((\d{1,})\)/.match(f)[0]
		    	tvYear = Date::strptime(tvYearMatch[1,tvYearMatch.length-2], "%Y").to_s

				ratingString = /\s\d{1,2}\.\d\s/.match(f)[0]
				total_rating = ratingString[1,ratingString.length-2]
				#puts "Rating "+total_rating

				votesString = /\d{1,}\s{2,3}\d{1,}\./.match(f)[0]
				votes = votesString[0,votesString.length-5]
				#puts "Votes "+votes

		    	#puts "A: "+f
		    	rateables = conn.exec('SELECT id FROM tv_shows where title = \''+valid_title+'\' and year_released = \''+tvYear+'\';')

			    if rateables.num_tuples > 0
				    rateable_id = rateables.getvalue(0,0)
				    ratings_found = conn.exec('SELECT id FROM ratings where rateable_type = $1 and rating_website = $2 and rateable_id = $3',["TvShow","IMDB",rateable_id])

				    if ratings_found.num_tuples > 0
				    	#puts "Updating show rating to "+tings (id,votes,total_rating,rating_website,rateable_id,rateable_type) VALUES (DEFAULT,$1,$2,$3,$4,$5)',[votes,total_rating,'IMDB',rateable_id,"TvEpisode"])
					    #puts total_rating+" "+valid_title
				    	conn.exec('UPDATE ratings set total_rating = $1, votes = $2 WHERE rateable_id = $3 and rateable_type = $4 and rating_website = $5',[total_rating,votes,rateable_id,"TvShow","IMDB"])
				    elsif ratings_found.num_tuples == 0	
				    	puts ratings_found["rateable_id"].to_s + " "+valid_title
				    	puts "Inserting show total_rating "+total_rating.to_s+" "+valid_title
			    		conn.exec('INSERT INTO ratings (id,votes,total_rating,rating_website,rateable_id,rateable_type) VALUES (DEFAULT,$1,$2,$3,$4,$5)',[votes,total_rating,'IMDB',rateable_id,"TvShow"])
					end
				end
		    end
		elsif tvratingsreport && /{.{0,}\(.{1,}\..{1,}\)}/ =~ f #is an episode
	  		#puts "EPISODE"

			#get tv title
		  	tString = /".{1,}"/.match(f)[0]
		  	valid_title = (tString[1,tString.length-2].gsub("'","\'\'")).unpack('C*').pack('U*')

	   		if (/\((\d{1,})\)/) =~ f #has tv year 
		    	tvYearMatch = /\((\d{1,})\)/.match(f)[0]
		    	tvYear = Date::strptime(tvYearMatch[1,tvYearMatch.length-2], "%Y").to_s

				ratingString = /\s\d{1,2}\.\d\s/.match(f)[0]
				total_rating = ratingString[1,ratingString.length-2]
				#puts "Rating "+total_rating

				votesString = /\d{1,}\s{2,3}\d{1,}\./.match(f)[0]
				votes = votesString[0,votesString.length-5]
				#puts "Votes "+votes

		    	seasonNumber = /\d{1,}\.\d{1,}\)/.match(f)[0].split(".").first
		    	epString = /\d{1,}\.\d{1,}\)/.match(f)[0].split(".").last
				episodeNumber = epString[0,epString.length-1]
				#puts episodeNumber

		    	#puts "TV EPISODE: "+f
		    	#puts "QUERY: "+valid_title 
		    	query = 'SELECT tv_episodes.id '+
					 'FROM tv_shows, tv_seasons, tv_episodes '+
					 'WHERE tv_shows.id = tv_seasons.tv_show_id '+
					 'AND tv_seasons.id = tv_episodes.tv_season_id '+
					 'and tv_shows.title = \''+valid_title+'\' '+
					 'and tv_shows.year_released = \''+tvYear+'\' '+
					 'and tv_seasons.number = \''+seasonNumber+'\' '+
					 'and tv_episodes.number = \''+episodeNumber+'\';'

				#puts " QUERY: "+query
		    	episodes = conn.exec(query)

			    if episodes.num_tuples > 0
				    rateable_id = episodes.getvalue(0,0)
				    ratings_found = conn.exec('SELECT id FROM ratings WHERE rateable_type = $1 AND rating_website = $2 AND rateable_id = $3',["TvEpisode","IMDB",rateable_id])

				    if ratings_found.num_tuples > 0
				    	#puts "Updating tvepisode rating to "+total_rating+" "+valid_title
				    	conn.exec('UPDATE ratings SET total_rating = $1, votes = $2 WHERE rateable_id = $3 AND rateable_type = $4 AND rating_website = $5',[total_rating,votes,rateable_id,"TvEpisode","IMDB"])
				    elsif ratings_found.num_tuples == 0
				    	puts ratings_found["rateable_id"].to_s +" "+ valid_title
				    	puts "Inserting tvep total_rating "+total_rating+" "+valid_title
			    		conn.exec('INSERT INTO ratings (id,votes,total_rating,rating_website,rateable_id,rateable_type) VALUES (DEFAULT,$1,$2,$3,$4,$5)',[votes,total_rating,'IMDB',rateable_id,"TvEpisode"])
					end
				end
		    end
	    end 
	end
end 
	
conn.close()
puts "end of file!"
