class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true, :foreign_key => "item_id"

  validates :votes, :total_rating, :rating_website, :type, :item_id, :presence => true
  validates :total_rating, :inclusion => { :in => 0..10) }
end
