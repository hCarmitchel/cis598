class TvSeason < ActiveRecord::Base
	attr_accessible :tv_show_id, :number

	has_many :ratings, :as => :rateable, :dependent => :destroy
	has_many :reviews, :as => :reviewable, :dependent => :destroy
	has_many :tv_episodes, :dependent => :destroy
	has_many :genres, :through => :tv_show

	belongs_to :tv_show
	
	validates :tv_show_id, :number, :presence => { :message => "This field is required."}
	validates :number, :numericality => { :only_integer => true, :message => "Number must be an integer."}

	default_scope :order => "number ASC"
	
	def self.episodes(id)
      TvEpisode.where(:tv_season_id=>id).select("tv_episodes.id as tv_episode_id, number, title")
    end
    def self.rating(id)
    	avg = Array.new
	    TvSeason.episodes(id).each do |episode|
	    a = episode.rating(episode.tv_episode_id).average("total_rating")
	    if !a.nil? && a > 0
	      avg.push(a)
	    end

	    @IMDBrating = avg.inject{ |sum, el| sum + el }.to_f / avg.size
	    if @IMDBrating.nil?
	      @IMDBrating = "N/A"
	    else
	      @IMDBrating = @IMDBrating.to_s[0..2]
	    end
	    
	    return @IMDBrating
    end

    @IMDBrating = avg.inject{ |sum, el| sum + el }.to_f / avg.size
    end
	def self.rated_episodes(id,order,limit)
      eps = TvEpisode.unscoped.where('tv_season_id = '+id.to_s+' and total_rating > 0')
      eps = eps.joins('LEFT JOIN ratings ON ratings.rateable_id = tv_episodes.id')
      eps = eps.order("total_rating "+order).select('tv_episodes.id as tv_episode_id, title, total_rating, number').limit(limit)
    end
end

