#!/usr/bin/env ruby.exe

require 'rubygems' 
require 'zlib'
require 'open-uri'
require 'pg'
require 'date'

puts "getting ready to parse"

uri = 'ftp://ftp.fu-berlin.de/pub/misc/movies/database/movies.list.gz'
source = open(uri)
result = Zlib::GzipReader.new(source)

begin
	heroku = false
	conn = PGconn.open(:dbname => 'development', :port => 5432)
rescue
	heroku = true
	conn = PGconn.open("dbname=d9brbfi46siqi host=ec2-54-225-112-205.compute-1.amazonaws.com port=5432 user=ekyfschexohgiw password=Et0EzcB-nWkhrlIJaMhn1W_TIk sslmode=require")
end

if conn 
	result.each do |f|
		f = f.unpack('C*').pack('U*')
		if /\d{4,}\-\d{4,5}$/ =~ f || /\d{4,}\-\?{4,5}$/ =~ f #if matches tv show
			if !heroku 
				puts "Show= "+f
			end
		  	tString = /^".{1,}"/.match(f)[0]
		  	title = (tString[1,tString.length-2].gsub("'","\'"))
		  	valid_tv_title = (tString[1,tString.length-2].gsub("'","\'\'")).unpack('C*').pack('U*')
		  	valid_title = title.unpack('C*').pack('U*')

		    query,y1,y2 = ''
		    y1 = Date::strptime(/\d{4,}\-\S{4,5}$/.match(f)[0].split("-").first, "%Y").to_s

		    query = 'SELECT id FROM tv_shows where title = \''+valid_tv_title+'\' and year_released = \''+y1+'\';'
			tvshows = conn.exec(query)
			# tvshowID = conn.exec('SELECT id FROM tv_shows where title = $1 and year_released = $2',[valid_tv_title,tvYear]).getvalue(0,0)
			if tvshows.num_tuples == 0 #if we don't already have that tvshow
			    if /\d{4,}\-\d{4,5}$/ =~ f
			    	y2 = Date::strptime(/\d{4,}\-\d{4,5}$/.match(f)[0].split("-").last, "%Y").to_s
			    	if !heroku
			    		puts "TV SHOW 1: "+valid_title+" y1:"+y1
			    	end
				    conn.exec('INSERT INTO tv_shows (id,title,year_released,year_ended) VALUES (DEFAULT,$1,$2,$3)',[valid_title,y1,y2])
			    else
			    	if !heroku
			    		puts "TV SHOW 2: "+valid_title+" y1:"+y1
			    	end
				    conn.exec('INSERT INTO tv_shows (id,title,year_released) VALUES (DEFAULT,$1,$2)',[valid_title,y1])
			    end
			end
		elsif /\((\d{1,})\)\s{1,}{/ =~ f && !(/\d{4,}\-\d{4,5}$/ =~ f || /\d{4,}\-\?{4,5}$/ =~ f)
			if !heroku
				puts "Ep= "+f
			end
			tvString = /^".{1,}"/.match(f)[0]
			valid_tv_title = (tvString[1,tvString.length-2].gsub("'","\'\'")).unpack('C*').pack('U*')

		    if /{.{1,}(#.{1,}\..{1,})}/ =~ f #is numbered
			   	epSeason = /\d{1,}\.\d{1,}/.match(f)[0].split(".").first
			   	epNumber = /\d{1,}\.\d{1,}/.match(f)[0].split(".").last
			   	epTitleString = /{.{1,}(#)/.match(f)[0]
			   	hasNoNumber = false
		   	elsif /{.{1,}}/ =~ f #has title braces
		   		epSeason = '0'
		   		epNumber = '0'
		   		epTitleString = /{.{1,}}/.match(f)[0] 
		   		hasNoNumber = true
		   	else
		   		epTitleString = ''
		   	end

		   	if /{\(\d{4}-\d{2}-\d{2}\)}/ =~ epTitleString || /{\(SUSPENDED\)}/ =~ epTitleString
		   		epTitleString = ''
		   	end

	   		if epTitleString.length > 250
		   		valid_ep_title = (epTitleString[1,250].gsub("'","\'")).unpack('C*').pack('U*')
		   	elsif epTitleString.length > 4 and !hasNoNumber
		   		valid_ep_title = (epTitleString[1,epTitleString.length-4].gsub("'","\'")).unpack('C*').pack('U*')
		   	elsif epTitleString.length > 4 and hasNoNumber
		   		valid_ep_title = (epTitleString[1,epTitleString.length-2].gsub("'","\'")).unpack('C*').pack('U*')
		   	else
		   		valid_ep_title = ''
		   	end
		   	tvYearMatch = /\((\d{1,})\)/.match(f)[0]
		   	tvYear = Date::strptime(tvYearMatch[1,tvYearMatch.length-2], "%Y").to_s
	    	#puts "valid_tv_title: "+valid_tv_title
	    	#puts "valid_ep_title: "+valid_ep_title
	    	#puts "epSeason: "+epSeason
	    	#puts "epNumber: "+epNumber
	    	#puts "tvYear: "+tvYear

	    	query = 'SELECT id FROM tv_shows where title = \''+valid_tv_title+'\' and year_released = \''+tvYear+'\';'
	    	#puts "QUERY: "+query
	    	tvshows = conn.exec(query)
	    	# tvshowID = conn.exec('SELECT id FROM tv_shows where title = $1 and year_released = $2',[valid_tv_title,tvYear]).getvalue(0,0)
		    if tvshows.num_tuples > 0
			    tvshowID = tvshows.getvalue(0,0)

			    tvseason = conn.exec('SELECT id from tv_seasons where tv_show_id = $1 and number = $2',[tvshowID,epSeason])

				if tvseason == nil or tvseason == 0 or tvseason.num_tuples.zero? #season does not exist so create season
				    conn.exec('INSERT INTO tv_seasons (id,tv_show_id,number) VALUES (DEFAULT,$1,$2);',[tvshowID,epSeason])
				end

				tvseason = conn.exec('SELECT id from tv_seasons where tv_show_id = $1 and number = $2',[tvshowID,epSeason])
				tvseasonID = tvseason.getvalue(0,0) 
				tvepisodes = conn.exec('SELECT id from tv_episodes where tv_season_id = $1 and number = $2',[tvseasonID,epNumber]) 

				if tvepisodes.num_tuples == 0
			    	if (/\d{4,5}$/) =~ f #ep has year
				    	epYear = Date::strptime(/\d{4,5}$/.match(f)[0], "%Y").to_s
				    	if !heroku
				    		puts "Ep "+f
				    	end
				    	conn.exec('INSERT INTO tv_episodes (id,number,title,tv_season_id,air_date) VALUES 
			    			(DEFAULT,$1,$2,$3,$4)',[epNumber,valid_ep_title,tvseasonID,epYear])
				    else #ep has no year
				    	if !heroku
				    		puts "Ep "+f
				    	end
				    	conn.exec('INSERT INTO tv_episodes (id,number,title,tv_season_id) VALUES 
			    			(DEFAULT,$1,$2,$3)',[epNumber,valid_ep_title,tvseasonID])
				    end
				end
			end
	    end 
	end 
	conn.close()
end
puts "end of file!"