module TvShowsHelper
  def season_ratings_data(id)
  	arr = Array.new 
    seasons = TvShow.seasons(id)
    seasons.each do |season|
      episodes = TvSeason.episodes(season.tv_season_id)
      episodes.each do |episode|
        r = Rating.where("rateable_type = 'TvEpisode' and rateable_id = ?", episode.tv_episode_id).average("total_rating") || 0
        arr.push("S"+season.number.to_s+"xE"+episode.number.to_s)
        arr.push(r)
      end
    end

    arr.each_slice(2).map do |num,rating|
      {
        year: num,
        average: rating || 0
      }
    end
  end
end
