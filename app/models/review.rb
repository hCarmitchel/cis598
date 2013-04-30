class Review < ActiveRecord::Base
	belongs_to :reviewable, :polymorphic => true

    validates :reviewable_id, :numericality => { :only_integer => true, :message => "Item_id must be an integer."}
	validates :year_reviewed, :content, :reviewable_type, :reviewable_id, :presence => { :message => "This field is required."}

	default_scope :order => "year_reviewed DESC"

  def self.recent(number)
    Review.order("year_reviewed desc").limit(number)
  end
  def self.downloadFeeds
    require 'feedzirra'

    # fetching a single feed
    feed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/BillieDoux")
    feed.sanitize_entries!  # => sanitizes all entries in place

    feed.entries.each do |entry|
      puts "Title:"
      puts entry.title      # => "Ruby Http Client Library Performance"
      puts "URL"
      puts entry.url        # => "http://www.pauldix.net/2009/01/ruby-http-client-library-performance.html"
      puts "author"
      puts entry.author     # => "Paul Dix"
      puts "summary"
      puts entry.summary    # => "..."
      puts "content"
      puts entry.content    # => "..."
      puts "published"
      puts entry.published  # => Thu Jan 29 17:00:19 UTC 2009 # it's a Time object
      puts "categories"
      puts entry.categories
    end
  end
end
