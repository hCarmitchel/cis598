class Genre < ActiveRecord::Base
	attr_accessible :name, :tv_show_id

	belongs_to :tv_show

	validates :name, :tv_show_id, :presence => { :message => "This field is required."}
	validates :name, :length => { :minimum => 2 }

	def self.total_grouped_by_genre
	    genres = unscoped.group("name").select("name, count(*) as count")
		genres.each_with_object({}) do |genre, counts|
		    counts[genre.name] = genre.count
		end
    end
    def self.genres_grouped_by_day(genre)
    	genres = unscoped.where(:name=>genre).joins('LEFT JOIN tv_shows ON genres.tv_show_id=tv_shows.id')
	    genres = genres.group("date(year_released), genres.name")
	    genres = genres.select("name, date(year_released) as year_released, count(*) as count")
		genres.each_with_object({}) do |genre, counts|
		    counts[genre.year_released.to_date.strftime("%Y")] = genre.count
		end
  	end
  	def self.genres_ratings
  		genres = unscoped.where("ratings.rateable_type = 'TvShow'")
  		genres = genres.select('genres.name, avg(ratings.total_rating) as average')
  		genres = genres.group("genres.name")
  		genres = genres.joins('LEFT OUTER JOIN ratings ON ratings.rateable_id = genres.tv_show_id')
  		genres = genres.order("average asc")
  		genres.each_with_object({}) do |genre, averages|
		    averages[genre.name] = genre.average
		end
  	end
  	def self.parseIMDB
      puts "parsing genres"
      require_relative '../../script/parse_genres_prod'
	end
end
