class Review < ActiveRecord::Base
	belongs_to :reviewable, :polymorphic => true

    validates :reviewable_id, :numericality => { :only_integer => true, :message => "Item_id must be an integer."}
	validates :year_reviewed, :content, :reviewable_type, :reviewable_id, :presence => { :message => "This field is required."}

	default_scope :order => "year_reviewed DESC"

  def self.recent(number)
    Review.order("year_reviewed desc").limit(number)
  end
  def downloadFeeds
    require 'feedzirra'

    # fetching a single feed
    feed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/BillieDoux")
    feed.sanitize_entries!  # => sanitizes all entries in place

    feed.entries.each do |entry|
      puts entry.title      # => "Ruby Http Client Library Performance"
      puts entry.url        # => "http://www.pauldix.net/2009/01/ruby-http-client-library-performance.html"
      puts entry.author     # => "Paul Dix"
      puts entry.summary    # => "..."
      puts entry.content    # => "..."
      puts entry.published  # => Thu Jan 29 17:00:19 UTC 2009 # it's a Time object
      puts entry.categories
    end
  end
end
