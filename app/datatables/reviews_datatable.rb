class ReviewsDatatable
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
      iTotalRecords: Review.count,
      iTotalDisplayRecords: reviews.total_entries,
      aaData: data
    }
  end

private

  def data
    reviews.map do |review|
      [
        link_to(review.title, review),
        review.content[0..100]+"...",
        review.author,
        review.website,
        icon_link_to(review,{:icon => "eye-open",:enlarge => false},{ :method => :get })+icon_link_to("/reviews/"+review.id.to_s+"/edit",{:icon =>"pencil",:enlarge => false},{:action => :edit})+icon_link_to(review,{:icon =>"trash",:enlarge => false},{confirm: 'Are you sure?',:method => :delete})
      ]
    end
  end

  def reviews
    @reviews ||= fetch_reviews
  end

  def fetch_reviews
    reviews = Review.order("#{sort_column} #{sort_direction}")
    reviews = reviews.page(page).per_page(per_page)
    if params[:sSearch].present?
      reviews = reviews.where("title like :search or content like :search", search: "%#{params[:sSearch]}%")
    end
    reviews
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title content author website actions]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end