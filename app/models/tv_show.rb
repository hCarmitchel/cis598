class TvShow < ActiveRecord::Base
	attr_accessible :year_released, :year_ended, :title, :description, :id

	has_many :genres, :dependent => :destroy
	has_many :ratings, :as => :rateable, :dependent => :destroy
	has_many :reviews, :as => :reviewable, :dependent => :destroy
	has_many :tv_seasons, :dependent => :destroy
	has_many :tv_episodes, :through => :tv_seasons, :dependent => :destroy

	validates :title, :year_released, :presence => { :message => "This field is required."}
	validates :title, :length => { :minimum => 2 }

  def self.total_grouped_by_day(start)
    tv_shows = unscoped.where(year_released: start.beginning_of_day..Time.zone.now).group("date(year_released)")
    tv_shows = tv_shows.select("date(year_released) as year_released, count(*) as count")
  	tv_shows.each_with_object({}) do |tv_show, counts|
  	    counts[tv_show.year_released.to_date.strftime("%Y")] = tv_show.count
  	end
  end
  def IMDB_rating(id)
    show = Rating.where(:rateable_type=>'TvShow',:rating_website=>'iMDB',:rateable_id=>id)
  end
  def self.find_title(title,year)
    TvShow.where(:title=>title,:year_released=>year)
  end
  def self.seasons(id)
    TvSeason.where(:tv_show_id=>id).select('id as tv_season_id, number')
  end
  def self.episodes(id,order,limit)

  end
  def self.reviews(id)
    Review.where(:reviewable_id=>id,:reviewable_type=>'TvShow')
  end
  def self.parseIMDB
      require 'zlib'
      require 'open-uri'

      uri = 'ftp://ftp.fu-berlin.de/pub/misc/movies/database/movies.list.gz'
      source = open(uri)
      gz = Zlib::GzipReader.new(source)
      result = gz.read
      puts result
  end
  def self.simple_search(search)
	  if search
	    where 'UPPER(title) LIKE UPPER(?) or UPPER(description) LIKE UPPER(?)', "%#{search}%", "%#{search}%"
	  else
	    scoped
	  end
  end
end
