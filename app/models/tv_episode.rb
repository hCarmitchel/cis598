class TvEpisode < ActiveRecord::Base
	has_many :ratings, :as => :rateable, :foreign_key => "item_id"
	has_many :genres, :through => :tv_shows
	
	belongs_to :tvSeasons
	belongs_to :tvShows

	validates :show_id, :season_id, :number, :presence => true
end
