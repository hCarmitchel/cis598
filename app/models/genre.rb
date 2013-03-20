class Genre < ActiveRecord::Base
	belongs_to :tv_show

	validates :name, :tv_show_id, :presence => { :message => "This field is required."}
	validates :name, :length => { :minimum => 2 }
end
