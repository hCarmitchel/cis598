class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true

  validates :votes, :total_rating, :rating_website, :rateable_type, :rateable_id, :presence => { :message => "This field is required."}
  validates :total_rating, :inclusion => { :in => (0..10), :message => "%{value} is not greater than 0 and less than equal to 10." }
  validates :votes, :numericality => { :only_integer => true, :message => "Votes must be an integer."}
  validates :rateable_id, :numericality => { :only_integer => true, :message => "Item_id must be an integer."}

  def self.total_grouped_by_day(type,table,year)
  	ratings = unscoped.where('rateable_type = \''+type+'\'')
    ratings = ratings.joins('LEFT JOIN '+table+' ON ratings.rateable_id='+table+'.id')
    ratings = ratings.group("date("+year+")").select("date("+year+") as year, count(*) as count")
		ratings.each_with_object({}) do |rating, counts|
      if !rating.year.nil?
		    counts[rating.year.to_date.strftime("%Y")] = rating.count
      end
		end
  end
  def self.avg_grouped_by_day(type,table,year)
    ratings = unscoped.where('rateable_type = \''+type+'\'')
    ratings = ratings.joins('LEFT JOIN '+table+' ON ratings.rateable_id='+table+'.id')
    ratings = ratings.group("date("+year+")").select("date("+year+") as year, avg(total_rating) as average")
    ratings.each_with_object({}) do |rating, averages|
        if !rating.year.nil?
          averages[rating.year.to_date.strftime("%Y")] = rating.average
        end
    end
  end
  def self.top(website,type,table,votes,limit)
    ratings = unscoped.where('rateable_type = \''+type+'\' and rating_website = \''+website+'\' and votes > '+votes)
    ratings = ratings.joins('LEFT JOIN '+table+' ON ratings.rateable_id='+table+'.id')
    ratings = ratings.order("total_rating desc").select('total_rating, title, '+table+'.id as id').limit(limit)
  end
  def self.rating(type,table,id,website)
    ratings = unscoped.where('rateable_type = \''+type+'\' and rating_website = \''+website+'\' and '+table+'.id = '+id)
    ratings = ratings.joins('LEFT JOIN '+table+' ON ratings.rateable_id='+table+'.id')
    ratings = ratings.select("avg(total_rating) as average")
  end
end
