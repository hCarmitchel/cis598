module WelcomeHelper
  def tv_shows_chart_data
    tv_shows_by_day = TvShow.total_grouped_by_day(73.years.ago) 
    tv_ratings_by_day = Rating.total_grouped_by_day("TvShow","tv_shows","year_released")

    (1940..2013).map do |date|
      {
        year_released: Date.new(date,1,1),
        count: tv_shows_by_day[date.to_s] || 0,
        rating: tv_ratings_by_day[date.to_s] || 0
      }
    end
  end
  def genres_pie_data
    genres = Genre.total_grouped_by_genre

    genres.map do |genre|
      {
      label: genre[0],
      value: genre[1].to_i
      }
    end
  end
  def genres_chart_data
    comedy_by_day = Genre.genres_grouped_by_day("Comedy")
    drama_by_day = Genre.genres_grouped_by_day("Drama")
    documentary_by_day = Genre.genres_grouped_by_day("Documentary")
    realitytv_by_day = Genre.genres_grouped_by_day("Reality-TV")
    talkshow_by_day = Genre.genres_grouped_by_day("Talk-Show")

    (1980..2013).map do |date|
      {
        year_released: Date.new(date,1,1),
        comedy: comedy_by_day[date.to_s] || 0,
        drama: drama_by_day[date.to_s] || 0,
        documentary: documentary_by_day[date.to_s] || 0,
        realitytv: realitytv_by_day[date.to_s] || 0,
        talkshow: talkshow_by_day[date.to_s] || 0
      }
    end
  end
  def ratings_chart_data
    ep_ratings_by_day = Rating.total_grouped_by_day("TvEpisode","tv_episodes","air_date")
    tv_episodes_by_day = TvEpisode.total_grouped_by_day(73.years.ago) 

    (1940..2013).map do |date|
      {
        year_released: Date.new(date,1,1),
        count: tv_episodes_by_day[date.to_s] || 0,
        rating: ep_ratings_by_day[date.to_s] || 0
      }
    end
  end
    def ratings_avg_data
    tv_ratings_by_day = Rating.avg_grouped_by_day("TvShow","tv_shows","year_released")
    ep_ratings_by_day = Rating.avg_grouped_by_day("TvEpisode","tv_episodes","air_date")

    (1940..2013).map do |date|
      {
        year: Date.new(date,1,1),
        average: tv_ratings_by_day[date.to_s] || 0,
        epaverage: ep_ratings_by_day[date.to_s] || 0
      }
    end
  end
end
