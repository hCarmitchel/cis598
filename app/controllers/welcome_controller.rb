class WelcomeController < ApplicationController
	def index
		@topIMDB = Rating.top_ten('IMDB','TvShow','tv_shows')
		@topIMDBeps = Rating.top_ten('IMDB','TvEpisode','tv_episodes')
	end
	def stats
		@genres = Genre.total_grouped_by_genre
		@average_rating = Rating.average('total_rating')
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
	def search_results
		@tv_result = TvShow.simple_search(params[:search]).paginate(:page => params[:page])
		@ep_result = TvEpisode.simple_search(params[:search]).paginate(:page => params[:page])
	end
end
