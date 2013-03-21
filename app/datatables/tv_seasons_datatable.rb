class TVSeasonsDatatable
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
      iTotalRecords: TvSeason.count,
      iTotalDisplayRecords: tvseasons.total_entries,
      aaData: data
    }
  end

private

  def data
    tvseasons.map do |tvseason|
      [
        link_to(tvseason.tv_show.id, tvseason.tv_show),
        link_to(tvseason.number, tvseason),
        icon_link_to(tvseason,{:icon => "eye-open",:enlarge => false},{ :method => :get })+icon_link_to("/tv_seasons/"+tvseason.id.to_s+"/edit",{:icon =>"pencil",:enlarge => false},{:action => :edit})+icon_link_to(tvseason,{:icon =>"trash",:enlarge => false},{confirm: 'Are you sure?',:method => :delete})
      ]
    end
  end

  def tvseasons
    @tvseasons ||= fetch_tvseasons
  end

  def fetch_tvseasons
    tvseasons = TvSeason.order("#{sort_column} #{sort_direction}")
    tvseasons = tvseasons.page(page).per_page(per_page)
    if params[:sSearch].present?
      tvseasons = tvseasons.where("tv_show like :search or number like :search", search: "%#{params[:sSearch]}%")
    end
    tvseasons
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[number tv_show actions]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end