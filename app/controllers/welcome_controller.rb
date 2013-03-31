class WelcomeController < ApplicationController
	def index
		@archer = TvShow.where(:title=>'Archer').where(:year_released=>'01-01-2009').first
		@breaking_bad = TvShow.where(:title=>'Breaking Bad').where(:year_released=>'01-01-2008').first
		@game_of_thrones = TvShow.where(:title=>'Game of Thrones').where(:year_released=>'01-01-2011').first
		@the_americans = TvShow.where(:title=>'The Americans').where(:year_released=>'01-01-2013').first

		@shows = false
		@seasons = false
		@eps = false

		if params[:type] && params[:type]["select"] == "2"
			@top = Rating.top_ten('IMDB','TvSeason','tv_seasons')
			@seasons = true
			puts "seasons"
		elsif params[:type] && params[:type]["select"] == "3"
			@top = Rating.top_ten('IMDB','TvEpisode','tv_episodes','1000')
			puts @top.size
			@eps = true
			puts "eps"
		else
			@top = Rating.top_ten('IMDB','TvShow','tv_shows','100000')
			@shows = true
			puts "shows"
		end
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
