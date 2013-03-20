class TVEpisodesDatatable
  delegate  :params, :h, :link_to, to: :@view, :icon_link_to

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: TvEpisode.count,
      iTotalDisplayRecords: tvepisodes.total_entries,
      aaData: data
    }
  end

private

  def data
    tvepisodes.map do |tvepisode|
      [
        link_to(tvepisode.title, tvepisode),
        link_to(tvepisode.tv_season.number, tvepisode.tv_season),
        link_to(tvepisode.number, tvepisode),
        icon_link_to(tv_season,{:icon => "eye-open",:enlarge => false},{ :method => :get })
      ]
    end
  end

  def tvepisodes
    @tvepisodes ||= fetch_tvepisodes
  end

  def fetch_tvepisodes
    tvepisodes = TvEpisode.order("#{sort_column} #{sort_direction}")
    tvepisodes = tvepisodes.page(page).per_page(per_page)
    if params[:sSearch].present?
      tvepisodes = tvepisodes.where("title like :search or number like :search", search: "%#{params[:sSearch]}%")
    end
    tvepisodes
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title season number actions]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end