class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true

  validates :votes, :total_rating, :rating_website, :rateable_type, :rateable_id, :presence => { :message => "This field is required."}
  validates :total_rating, :inclusion => { :in => (0..10), :message => "%{value} is not greater than 0 and less than equal to 10." }
  validates :votes, :numericality => { :only_integer => true, :message => "Votes must be an integer."}
  validates :rateable_id, :numericality => { :only_integer => true, :message => "Item_id must be an integer."}
  def self.total_grouped_by_day
  	ratings = unscoped.where('rateable_type = \'TvShow\'')
    ratings = ratings.joins('LEFT JOIN tv_shows ON ratings.rateable_id=tv_shows.id')
    ratings = ratings.group("date(year_released)").select("date(year_released) as year_released, count(*) as count")
		ratings.each_with_object({}) do |rating, counts|
		    counts[rating.year_released.to_date.strftime("%Y")] = rating.count
		end
  end
  def self.avg_grouped_by_day
    ratings = unscoped.where('rateable_type = \'TvShow\'')
    ratings = ratings.joins('LEFT JOIN tv_shows ON ratings.rateable_id=tv_shows.id')
    ratings = ratings.group("date(year_released)").select("date(year_released) as year_released, avg(total_rating) as average")
    ratings.each_with_object({}) do |rating, averages|
        averages[rating.year_released.to_date.strftime("%Y")] = rating.average
    end
  end
  def self.top_ten(website)
    ratings = unscoped.where('rateable_type = \'TvShow\' and rating_website = \''+website+'\' and votes > 100000')
    ratings = ratings.joins('LEFT JOIN tv_shows ON ratings.rateable_id=tv_shows.id')
    ratings = ratings.order("total_rating desc").select("total_rating, title").limit(10)
  end
end
