class TvSeason < ActiveRecord::Base
	has_many :ratings, :as => :rateable, :foreign_key => "item_id"
	has_many :tvEpisodes
	has_many :genres, :through => :tvShows
	
	validates :show_id, :number, :presence => true
end
