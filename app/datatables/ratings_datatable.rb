class RatingsDatatable
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
      iTotalRecords: Rating.count,
      iTotalDisplayRecords: ratings.total_entries,
      aaData: data
    }
  end

private

  def data
    ratings.map do |rating|
      [
        link_to(rating.votes, rating),
        link_to(rating.total_rating, rating),
        rating.rating_website,
        rating.rateable_type,
        icon_link_to(rating,{:icon => "eye-open",:enlarge => false},{ :method => :get })+icon_link_to("/ratings/"+rating.id.to_s+"/edit",{:icon =>"pencil",:enlarge => false},{:action => :edit})+icon_link_to(rating,{:icon =>"trash",:enlarge => false},{confirm: 'Are you sure?',:method => :delete})
      ]
    end
  end

  def ratings
    @ratings ||= fetch_ratings
  end

  def fetch_ratings
    ratings = Rating.order("#{sort_column} #{sort_direction}")
    ratings = ratings.page(page).per_page(per_page)
    if params[:sSearch].present?
      ratings = ratings.where("rating_website like :search or rateable_type like :search", search: "%#{params[:sSearch]}%")
    end
    ratings
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[votes total website type actions]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end