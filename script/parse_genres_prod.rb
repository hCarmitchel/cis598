#!/usr/bin/env ruby.exe

require 'zlib'
require 'open-uri'
require 'pg'
require 'date'

puts "getting ready to parse genres"

uri = 'ftp://ftp.fu-berlin.de/pub/misc/movies/database/genres.list.gz'
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
		if !(/{.{1,}/ =~ f) && (/^".{1,}".(.{1,})\s{1,}.{1,}$/ =~ f) #if not an episode
			if !heroku 
				puts "Show= "+f
			end
		  	tString = /^".{1,}"/.match(f)[0]
		  	valid_title = (tString[1,tString.length-2].gsub("'","\'\'")).unpack('C*').pack('U*')

		    query,tvYear = ''

	   		if (/\((\d{1,})\)/) =~ f #has tv year 
		    	tvYearMatch = /\((\d{1,})\)/.match(f)[0]
		    	tvYear = Date::strptime(tvYearMatch[1,tvYearMatch.length-2], "%Y").to_s

				genre = /\S{1,}$/.match(f)[0]
				#puts "Genre "+genre

		    	query = 'SELECT id FROM tv_shows where title = \''+valid_title+'\' and year_released = \''+tvYear+'\';'
		    	tvshows = conn.exec(query)

			    if tvshows.num_tuples > 0
				    tvshowID = tvshows.getvalue(0,0)
				    foundgenre = false

					genres = conn.exec('SELECT * from genres where tv_show_id = $1',[tvshowID])
					genres.each do |genre_old|
						if genre_old["name"] == genre
							foundgenre = true
						end
					end
					if !foundgenre
						puts "Inserting genre: "+genre+" QUERY: "+valid_title 
			    		conn.exec('INSERT INTO genres (id,name,tv_show_id) VALUES (DEFAULT,$1,$2)',[genre,tvshowID])
					end
				end
		    end
	    end 
	end 
	conn.close()
end
puts "end of file!"
