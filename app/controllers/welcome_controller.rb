class WelcomeController < ApplicationController
  def index
  end
  def showByTitle
  	 @tv_show = TvShow.find(params[:title])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tv_show }
    end
  end
end
