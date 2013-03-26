module WelcomeHelper
  def tv_shows_chart_data
    tv_shows_by_day = TvShow.total_grouped_by_day(73.years.ago) 
    tv_episodes_by_day = TvEpisode.total_grouped_by_day(73.years.ago) 

    (1940..2013).map do |date|
      {
        year_released: Date.new(date,1,1),
        count: tv_shows_by_day[date.to_s] || 0,
        count_eps: tv_episodes_by_day[date.to_s] || 0
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
    comedy_by_day = Genre.comedy_grouped_by_day
    drama_by_day = Genre.drama_grouped_by_day
    documentary_by_day = Genre.documentary_grouped_by_day
    animation_by_day = Genre.animation_grouped_by_day
    realitytv_by_day = Genre.realitytv_grouped_by_day

    (1980..2013).map do |date|
      {
        year_released: Date.new(date,1,1),
        comedy: comedy_by_day[date.to_s] || 0,
        drama: drama_by_day[date.to_s] || 0,
        documentary: documentary_by_day[date.to_s] || 0,
        animation: animation_by_day[date.to_s] || 0,
        realitytv: realitytv_by_day[date.to_s] || 0
      }
    end
  end
end
