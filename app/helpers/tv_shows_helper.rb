module TvShowsHelper
  def shows_ratings_data(id)
  	arr = Array.new 
    seasons = TvShow.seasons(id)
    seasons.each do |season|
      episodes = TvSeason.episodes(season.tv_season_id)
      episodes.each do |episode|
        arr.push("S"+season.number.to_s+"xE"+episode.number.to_s)
        arr.push(Rating.where("rateable_type = 'TvEpisode' and rating_website = 'IMDB' and rateable_id = ?", episode.tv_episode_id).average("total_rating") || nil)
        arr.push(Rating.where("rateable_type = 'TvEpisode' and rating_website = 'TVDB' and rateable_id = ?", episode.tv_episode_id).average("total_rating") || nil)
        arr.push(episode.title)
        arr.push(episode.tv_episode_id)
      end
    end

    arr.each_slice(5).map do |num,rating,rating_TVDB,title,id|
      {
        year: num,
        average: rating || nil,
        average_TVDB: rating_TVDB || nil,
        title: title,
        id: id
      }
    end
  end
end
