class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true

  validates :votes, :total_rating, :rating_website, :rateable_type, :rateable_id, :presence => { :message => "This field is required."}
  validates :total_rating, :inclusion => { :in => (0..10), :message => "%{value} is not greater than 0 and less than equal to 10." }
  validates :votes, :numericality => { :only_integer => true, :message => "Votes must be an integer."}
  validates :rateable_id, :numericality => { :only_integer => true, :message => "Item_id must be an integer."}

  def self.total_grouped_by_day(type,table,year)
  	ratings = unscoped.where(:rateable_type=>type)
    ratings = ratings.joins('LEFT JOIN '+table+' ON ratings.rateable_id='+table+'.id')
    ratings = ratings.group("date("+year+")").select("date("+year+") as year, count(*) as count")
		ratings.each_with_object({}) do |rating, counts|
      if !rating.year.nil?
		    counts[rating.year.to_date.strftime("%Y")] = rating.count
      end
		end
  end
  def self.avg_grouped_by_day(type,table,year)
    ratings = unscoped.where(:rateable_type=>type)
    ratings = ratings.joins('LEFT JOIN '+table+' ON ratings.rateable_id='+table+'.id')
    ratings = ratings.group("date("+year+")").select("date("+year+") as year, avg(total_rating) as average")
    ratings.each_with_object({}) do |rating, averages|
        if !rating.year.nil?
          averages[rating.year.to_date.strftime("%Y")] = rating.average
        end
    end
  end
  def self.top(website,type,table,votes,limit)
    ratings = unscoped.where('rateable_type = ? and rating_website = ? and votes > ?',type,website,votes)
    ratings = ratings.joins('LEFT JOIN '+table+' ON ratings.rateable_id='+table+'.id')
    ratings = ratings.order("total_rating desc").select('total_rating, title, '+table+'.id as id').limit(limit)
  end
  def self.rating(type,table,id,website)
    ratings = unscoped.where('rateable_type = \''+type+'\' and rating_website = \''+website+'\' and '+table+'.id = '+id)
    ratings = ratings.joins('LEFT JOIN '+table+' ON ratings.rateable_id='+table+'.id')
    ratings = ratings.select("avg(total_rating) as average")
  end
  def self.parseIMDB
      puts "parsing ratings"
      require_relative '../../script/parse_ratings_prod'
  end
  def self.parseTVDB
      puts "parsing ratings"
      require 'rubygems'
      require 'tvdbr'
      require 'active_support/all'
      require 'pg'

      begin
        heroku = false
        conn = PGconn.open(:dbname => 'development', :port => 5432)
      rescue
        heroku = true
        conn = PGconn.open("dbname=d9brbfi46siqi host=ec2-54-225-112-205.compute-1.amazonaws.com port=5432 user=ekyfschexohgiw password=Et0EzcB-nWkhrlIJaMhn1W_TIk sslmode=require")
      end

      if conn
        tvdb = Tvdbr::Client.new('B352AF640BD00D25')
        calls = 0

        TvShow.find_each(:batch_size => 5000, :start => 4999) do |tv_show|
          series = tvdb.fetch_series_from_data(:title => tv_show.title)
          if !series.nil? && !series.rating_count.nil? && !series.rating.nil? && !series.title.nil? && series.rating.to_i > 0 && series.rating.to_i <= 10
            rateable_id = tv_show.id
            total_rating = series.rating
            votes = series.rating_count

            ratings_found = conn.exec('SELECT id FROM ratings WHERE rateable_type = $1 AND rating_website = $2 AND rateable_id = $3',["TvShow","TVDB",rateable_id])

            if ratings_found.num_tuples > 0
                puts "Updating tv rating to "+series.title+" "+series.rating
                conn.exec('UPDATE ratings SET total_rating = $1, votes = $2 WHERE rateable_id = $3 AND rateable_type = $4 AND rating_website = $5',[total_rating,votes,rateable_id,"TvShow","TVDB"])
            elsif ratings_found.num_tuples == 0
                puts "Inserting tv total_rating "+series.title+" "+series.rating.to_s+" "+tv_show.title
                conn.exec('INSERT INTO ratings (id,votes,total_rating,rating_website,rateable_id,rateable_type) VALUES (DEFAULT,$1,$2,$3,$4,$5)',[votes,total_rating,'TVDB',rateable_id,"TvShow"])
            end
            rateable_id = -1
            rateable_type = nil
            series.episodes.each do |e|
              #puts e.inspect

              total_rating = e.rating
              if !total_rating.nil?
                votes = e.rating_count
                
                tvseason = conn.exec('SELECT id from tv_seasons where tv_show_id = $1 and number = $2',[tv_show.id,e.season_number])
                if tvseason.num_tuples != 0
                  tvseasonID = tvseason.getvalue(0,0) 

                  eps = conn.exec('SELECT id from tv_episodes where tv_season_id = $1 and number = $2',[tvseasonID,e.episode_number])
                  if eps.num_tuples != 0
                    ep_id = eps.getvalue(0,0) 
                    if e.ep_img_flag == 1
                      conn.exec('UPDATE tv_episodes SET image=$1,description=$2 WHERE id = $3',[e.filename,e.overview,ep_id])
                    else
                      conn.exec('UPDATE tv_episodes SET description=$1 WHERE id = $2',[e.overview,ep_id])
                    end
                    ratings_found = conn.exec('SELECT id FROM ratings WHERE rateable_type = $1 AND rating_website = $2 AND rateable_id = $3',["TvEpisode","TVDB",ep_id])

                    if ratings_found.num_tuples > 0
                        puts "Updating tvepisode rating to "+e.episode_name.to_s+" "+e.rating
                        conn.exec('UPDATE ratings SET total_rating = $1, votes = $2 WHERE rateable_id = $3 AND rateable_type = $4 AND rating_website = $5',[total_rating,votes,ep_id,"TvEpisode","TVDB"])
                    elsif ratings_found.num_tuples == 0
                        puts "Inserting tvep total_rating "+e.episode_name.to_s+" "+e.rating.to_s+" "+tv_show.title
                        conn.exec('INSERT INTO ratings (id,votes,total_rating,rating_website,rateable_id,rateable_type) VALUES (DEFAULT,$1,$2,$3,$4,$5)',[votes,total_rating,'TVDB',ep_id,"TvEpisode"])
                    end
                  end
                end
              end
            end
          end
        end
      end
  end
end
