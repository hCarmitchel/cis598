class TvShow < ActiveRecord::Base
	has_many :genres, :dependent => :destroy
	has_many :ratings, :as => :rateable, :dependent => :destroy
	has_many :tv_seasons, :dependent => :destroy
	has_many :tv_episodes, :through => :tv_seasons, :dependent => :destroy

	validates :title, :year_released, :presence => { :message => "This field is required."}
	validates :title, :length => { :minimum => 2 }
end
