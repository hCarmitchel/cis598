class GenresDatatable
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
      iTotalRecords: Genre.count,
      iTotalDisplayRecords: genres.total_entries,
      aaData: data
    }
  end

private

  def data
    genres.map do |genre|
      [
        link_to(genre.name, genre),
        link_to(genre.tv_show.title, genre.tv_show),
        icon_link_to(genre,{:icon => "eye-open",:enlarge => false},{ :method => :get })+icon_link_to("/genres/"+genre.id.to_s+"/edit",{:icon =>"pencil",:enlarge => false},{:action => :edit})+icon_link_to(genre,{:icon =>"trash",:enlarge => false},{confirm: 'Are you sure?',:method => :delete})
      ]
    end
  end

  def genres
    @genres ||= fetch_genres
  end

  def fetch_genres
    genres = Genre.order("#{sort_column} #{sort_direction}")
    genres = genres.page(page).per_page(per_page)
    if params[:sSearch].present?
      genres = genres.where("name like :search", search: "%#{params[:sSearch]}%")
    end
    genres
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name show actions]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end