class Review < ActiveRecord::Base
	belongs_to :reviewable, :polymorphic => true

  validates :reviewable_id, :numericality => { :only_integer => true, :message => "Item_id must be an integer."}
	validates :year_reviewed, :content, :reviewable_type, :reviewable_id, :presence => { :message => "This field is required."}

	default_scope :order => "year_reviewed DESC"

  def self.downloadFeeds
      puts "parsing feeds"
      require_relative '../../script/parse_feeds'
  end
  def self.positives_average(website)
  	Review.where(:website => website).sum(:positives)
  end
  def self.negatives_average(website)
  	Review.where(:website => website).sum(:negatives)
  end
  def self.grouped
    reviews = unscoped.group("website").select("website, sum(positives) as positives, sum(negatives) as negatives")
    puts reviews.explain
    return reviews
  end
end
