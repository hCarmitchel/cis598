class TvSeason < ActiveRecord::Base
	attr_accessible :tv_show_id, :number

	has_many :ratings, :as => :rateable, :dependent => :destroy
	has_many :tv_episodes, :dependent => :destroy
	has_many :genres, :through => :tv_show

	belongs_to :tv_show
	
	validates :tv_show_id, :number, :presence => { :message => "This field is required."}
	validates :number, :numericality => { :only_integer => true, :message => "Number must be an integer."}
end
