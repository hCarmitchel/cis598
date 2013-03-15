class TvShow < ActiveRecord::Base
	has_many :genres
	has_many :ratings, :as => :rateable, :foreign_key => "item_id"
	
	validates :title, :year_released, :presence => true
	validates :title, :length => { :minimum => 2 }
end
