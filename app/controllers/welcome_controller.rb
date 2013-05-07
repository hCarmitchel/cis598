class WelcomeController < ApplicationController
	def index
		@top_shows = Rating.top('IMDB','TvShow','tv_shows','10000',15)
		@top_episodes = Rating.top('IMDB','TvEpisode','tv_episodes','1000',15)
		@recentReviews = Review.limit(12).paginate(:page => params[:page], :per_page => 3)
		@g = Genre.genres_ratings
		@d = Review.unscoped.where("year_reviewed > :d", {:d => Time.now - 5.days }).order('positives desc').first
		@e = Review.unscoped.where("year_reviewed > :d", {:d => Time.now - 5.days }).order('negatives desc').first
		if @d == @e
			@e = Review.unscoped.where("year_reviewed > :d", {:d => Time.now - 3.days }).order('negatives desc').offset(1).first
		end

	    require 'open-uri'
	    require 'uri'
	    require 'json'
	    result = JSON.parse(open("http://imdbapi.org/?title="+URI.escape(@d.reviewable.tv_season.tv_show.title.to_s)+"&type=json&plot=simple&episode=0&limit=1&year="+@d.reviewable.tv_season.tv_show.year_released.try(:strftime, "%Y")+"&yg=1&mt=TVS&lang=en-US&offset=&aka=simple&release=simple&business=0&tech=0").read)

	    if !result[0].nil?
	      @poster = result[0]["poster"]
	    end
	    result2 = JSON.parse(open("http://imdbapi.org/?title="+URI.escape(@e.reviewable.tv_season.tv_show.title.to_s)+"&type=json&plot=simple&episode=0&limit=1&year="+@e.reviewable.tv_season.tv_show.year_released.try(:strftime, "%Y")+"&yg=1&mt=TVS&lang=en-US&offset=&aka=simple&release=simple&business=0&tech=0").read)

	    if !result2[0].nil?
	      @poster2 = result2[0]["poster"]
	    end

	    @b = TvShow.find_title('Breaking Bad',DateTime.strptime('01/01/2008', '%m/%d/%Y').strftime('%m/%d/%Y').to_s).first.id
	end
	def stats
		@genres = Genre.total_grouped_by_genre
		@average_rating = Rating.average(:total_rating).round(2)
		@average_votes = Rating.average(:votes).round(2)

		@DouxReviews = Review.where(:website => "DouxReviews.com").count
		@TVReviews = Review.where(:website => "TV.com").count
		@EqualsReviews = Review.where(:website => "TVEquals.com").count
		@FanaticReviews = Review.where(:website => "TVFanatic.com").count

		@DouxReviewsPositive = Review.positives_average("DouxReviews.com")
		@DouxReviewsNegative = Review.negatives_average("DouxReviews.com")
		@TVReviewsPositive = Review.positives_average("TV.com")
		@TVReviewsNegative = Review.negatives_average("TV.com")
		@EqualsReviewsPositive = Review.positives_average("TVEquals.com")
		@EqualsReviewsNegative = Review.negatives_average("TVEquals.com")
		@FanaticReviewsPositive = Review.positives_average("TVFanatic.com")
		@FanaticReviewsNegative = Review.negatives_average("TVFanatic.com")
		@DouxReviews_size = 0
		@TVReviews_size = 0
		@EqualsReviews_size = 0
		@FanaticReviews_size = 0

		Review.find_each(:batch_size => 50) do |review|
		  size = review.content.split.size
		  if review.website == "DouxReviews.com"
		  	@DouxReviews_size = @DouxReviews_size + size
		  elsif review.website == "TV.com"
		  	@TVReviews_size = @TVReviews_size + size
		  elsif review.website == "TVEquals.com"
		  	@EqualsReviews_size = @EqualsReviews_size + size
		  elsif review.website == "TVFanatic.com"
		  	@FanaticReviews_size = @FanaticReviews_size + size
		  end
		end

		@DouxPositive = ((@DouxReviewsPositive) /  1.0 / (@DouxReviews_size)).round(6)
		@DouxNegative = ((@DouxReviewsNegative) /  1.0 / (@DouxReviews_size)).round(6)
		@TVPositive = ((@TVReviewsPositive) /  1.0 / (@TVReviews_size)).round(6)
		@TVNegative = ((@TVReviewsNegative) /  1.0 / (@TVReviews_size)).round(6)
		@TVPositive = ((@TVReviewsPositive) /  1.0 / (@TVReviews_size)).round(6)
		@FanaticNegative = ((@FanaticReviewsNegative) /  1.0 / (@FanaticReviews_size)).round(6)
		@FanaticPositive = ((@FanaticReviewsPositive) /  1.0 / (@FanaticReviews_size)).round(6)
		@EqualsPositive = ((@EqualsReviewsPositive) /  1.0 / (@EqualsReviews_size)).round(6)
		@EqualsNegative = ((@EqualsReviewsNegative) /  1.0 / (@EqualsReviews_size)).round(6)

		@notYet = TvEpisode.where("air_date > :start_date", {:start_date => Time.zone.now }).count
		@notYetTV = TvShow.where("year_released > :start_date", {:start_date => Time.zone.now }).count
	end
	def tv_show_search
		@q = TvShow.search(params[:q])
 		@tv_shows_result = @q.result(:distinct => true)
        @tv_shows_result = @tv_shows_result.where(:year_released => nil) unless params[:q]
	end
	def tv_episode_search
		@q = TvEpisode.search(params[:q])
 		@tv_episodes_result = @q.result(:distinct => true)
        @tv_episodes_result = @tv_episodes_result.where(:id => nil) unless params[:q]
	end
	def review_search
		@q = Review.search(params[:q])
 		@reviews_result = @q.result(:distinct => true)
        @reviews_result = @reviews_result.where(:year_reviewed => nil) unless params[:q]
	end
	def search_results
		@tv_result = TvShow.simple_search(params[:search]).paginate(:page => params[:page])
		@ep_result = TvEpisode.simple_search(params[:search]).paginate(:page => params[:page])
	end
end
