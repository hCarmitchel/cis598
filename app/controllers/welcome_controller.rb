class WelcomeController < ApplicationController
	def index
		@top_shows = Rating.top('IMDB','TvShow','tv_shows','10000',15)
		@top_episodes = Rating.top('IMDB','TvEpisode','tv_episodes','1000',15)
		@recentReviews = Review.limit(8).page(params[:page]).per_page(2)
	end
	def stats
		@genres = Genre.total_grouped_by_genre
		@average_rating = Rating.average('total_rating')
		@DouxReviews = Review.where(:website => "DouxReviews.com").count
		@TVReviews = Review.where(:website => "TV.com").count
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
