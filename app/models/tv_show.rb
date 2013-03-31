class TvShow < ActiveRecord::Base
	attr_accessible :year_released, :year_ended, :title, :description, :id

	has_many :genres, :dependent => :destroy
	has_many :ratings, :as => :rateable, :dependent => :destroy
	has_many :tv_seasons, :dependent => :destroy
	has_many :tv_episodes, :through => :tv_seasons, :dependent => :destroy

	validates :title, :year_released, :presence => { :message => "This field is required."}
	validates :title, :length => { :minimum => 2 }

  def self.total_grouped_by_day(start)
    tv_shows = unscoped.where(year_released: start.beginning_of_day..Time.zone.now)
    tv_shows = tv_shows.group("date(year_released)")
    tv_shows = tv_shows.order("date(year_released)")
    tv_shows = tv_shows.select("date(year_released) as year_released, count(*) as count")
	tv_shows.each_with_object({}) do |tv_show, counts|
	    counts[tv_show.year_released.to_date.strftime("%Y")] = tv_show.count
	end
  end
  def IMDB_rating(id)
    show = Rating.where('rateable_type = \''+'TvShow'+'\' and rating_website = \''+'iMDB'+'\' and rateable_id = '+id.to_s)
  end
  def self.simple_search(search)
	  if search
	    where 'UPPER(title) LIKE UPPER(?) or UPPER(description) LIKE UPPER(?)', "%#{search}%", "%#{search}%"
	  else
	    scoped
	  end
  end
end
