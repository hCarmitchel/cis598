class Genre < ActiveRecord::Base
	belongs_to :tv_shows
	validates :name, :show_id, :presence => true
	validates :name, :length => { :minimum => 2 }
end
