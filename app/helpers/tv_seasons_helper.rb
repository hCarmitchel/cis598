module TvSeasonsHelper
  def seasons_ratings_data(id)
  	arr = Array.new 
  	season = TvSeason.find(id)
	  episodes = TvSeason.episodes(season.id)
	  episodes.each do |episode|
  	  arr.push("S"+season.number.to_s+"xE"+episode.number.to_s)
  	  arr.push(Rating.where("rateable_type = 'TvEpisode' and rateable_id = ? and rating_website = 'IMDB'", episode.tv_episode_id).average("total_rating") || nil)
      arr.push(Rating.where("rateable_type = 'TvEpisode' and rateable_id = ? and rating_website = 'TVDB'", episode.tv_episode_id).average("total_rating") || nil)
	  end

    arr.each_slice(3).map do |num,rating,rating_tvdb|
      {
        year: num,
        average: rating || nil,
        average_tvdb: rating_tvdb || nil
      }
    end
  end
end
