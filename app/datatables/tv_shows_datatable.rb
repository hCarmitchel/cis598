class TVShowsDatatable
  delegate  :params, :h, :link_to, to: :@view
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context 

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: TvShow.count,
      iTotalDisplayRecords: tvshows.total_entries,
      aaData: data
    }
  end

private

  def data
    tvshows.map do |tvshow|
      [
        link_to(tvshow.title, tvshow),
        tvshow.description,
        tvshow.year_released.strftime("%Y"),
        tvshow.year_ended,
        icon_link_to(tvshow,{:icon => "eye-open",:enlarge => false},{ :method => :get })+icon_link_to("/tv_shows/"+tvshow.id.to_s+"/edit",{:icon =>"pencil",:enlarge => false},{:action => :edit})+icon_link_to(tvshow,{:icon =>"trash",:enlarge => false},{confirm: 'Are you sure?',:method => :delete})
      ]
    end
  end

  def tvshows
    @tvshows ||= fetch_tvshows
  end

  def fetch_tvshows
    tvshows = TvShow.order("#{sort_column} #{sort_direction}")
    tvshows = tvshows.page(page).per_page(per_page)
    if params[:sSearch].present?
      tvshows = tvshows.where("title like :search or description like :search", search: "%#{params[:sSearch]}%")
    end
    tvshows
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title description year_released year_ended actions]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end