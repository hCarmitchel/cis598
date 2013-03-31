class TvEpisode < ActiveRecord::Base
	attr_accessible :air_date, :tv_season_id, :number, :title

	has_many :ratings, :as => :rateable, :dependent => :destroy
	has_many :genres, :through => :tv_season
	
	belongs_to :tv_season
	belongs_to :tv_show

	validates :tv_season_id, :number, :presence => { :message => "This field is required." }
	validates :number, :numericality => { :only_integer => true, :message => "Number must be an integer." }

	default_scope :order => "number ASC"

	def self.total_grouped_by_day(start)
	    tv_episodes = unscoped.where(air_date: start.beginning_of_day..Time.zone.now)
	    tv_episodes = tv_episodes.group("date(air_date)")
	    tv_episodes = tv_episodes.select("date(air_date) as air_date, count(*) as count")
		tv_episodes.each_with_object({}) do |tv_episode, counts|
		    counts[tv_episode.air_date.to_date.strftime("%Y")] = tv_episode.count
		end
    end
    def self.simple_search(search)
	  if search
	    where 'UPPER(title) LIKE UPPER(?)', "%#{search}%"
	  else
	    scoped
	  end
  end
end
