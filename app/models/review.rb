class Review < ActiveRecord::Base
	belongs_to :reviewable, :polymorphic => true

    validates :rating, :inclusion => { :in => (0..10), :message => "%{value} is not greater than 0 and less than equal to 10." }
    validates :reviewable_id, :numericality => { :only_integer => true, :message => "Item_id must be an integer."}
	validates :year_reviewed, :content, :reviewable_type, :reviewable_id, :presence => { :message => "This field is required."}
end
