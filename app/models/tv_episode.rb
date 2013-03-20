class TvEpisode < ActiveRecord::Base
	has_many :ratings, :as => :rateable
	has_many :genres, :through => :tv_season
	
	belongs_to :tv_season
	belongs_to :tv_show

	validates :tv_season_id, :number, :presence => { :message => "This field is required." }
	validates :number, :numericality => { :only_integer => true, :message => "Number must be an integer." }
end
