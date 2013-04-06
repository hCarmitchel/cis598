class Review < ActiveRecord::Base
	belongs_to :reviewable, :polymorphic => true

    validates :reviewable_id, :numericality => { :only_integer => true, :message => "Item_id must be an integer."}
	validates :year_reviewed, :content, :reviewable_type, :reviewable_id, :presence => { :message => "This field is required."}

	default_scope :order => "year_reviewed DESC"

  def self.recent(number)
    Review.order("year_reviewed desc").limit(number)
  end
end
