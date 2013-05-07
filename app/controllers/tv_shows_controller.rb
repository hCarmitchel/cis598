class TvShowsController < ApplicationController
  # GET /tv_shows
  # GET /tv_shows.json
  def index
    @tv_shows = TvShow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: TVShowsDatatable.new(view_context) }
    end
  end

  # GET /tv_shows/1
  # GET /tv_shows/1.json
  def show
    @tv_show = TvShow.find(params[:id])
    @IMDBrating = Rating.rating("TvShow","tv_shows",params[:id],'IMDB').to_a[0]

    if !@IMDBrating.average.nil?
      @IMDBrating = @IMDBrating.average[0..2]
    else
      @IMDBrating = "N/A"
    end

    require 'open-uri'
    require 'uri'
    require 'json'
    result = JSON.parse(open("http://imdbapi.org/?title="+URI.escape(@tv_show.title.to_s)+"&type=json&plot=simple&episode=0&limit=1&year="+@tv_show.year_released.try(:strftime, "%Y")+"&yg=1&mt=TVS&lang=en-US&offset=&aka=simple&release=simple&business=0&tech=0").read)

    if !result[0].nil?
      @poster = result[0]["poster"]
      @description = result[0]["plot_simple"]
      @IMDBurl = result[0]["imdb_url"].strip
      @actors = result[0]["actors"]
    end

    @reviews = TvShow.reviews(@tv_show.id)
    @seasonCount = TvSeason.where(:tv_show_id => @tv_show.id).count
    @epCount = 0
    @tv_show.tv_seasons.each do |s|
      @epCount = @epCount + TvEpisode.where(:tv_season_id => s.id).count
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tv_show }
    end
  end

  # GET /tv_shows/new
  # GET /tv_shows/new.json
  def new
    @tv_show = TvShow.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tv_show }
    end
  end

  # GET /tv_shows/1/edit
  def edit
    @tv_show = TvShow.find(params[:id])
  end

  # POST /tv_shows
  # POST /tv_shows.json
  def create
    @tv_show = TvShow.new(params[:tv_show])

    respond_to do |format|
      if @tv_show.save
        format.html { redirect_to @tv_show, notice: 'Tv show was successfully created.' }
        format.json { render json: @tv_show, status: :created, location: @tv_show }
      else
        format.html { render action: "new" }
        format.json { render json: @tv_show.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tv_shows/1
  # PUT /tv_shows/1.json
  def update
    @tv_show = TvShow.find(params[:id])

    respond_to do |format|
      if @tv_show.update_attributes(params[:tv_show])
        format.html { redirect_to @tv_show, notice: 'Tv show was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tv_show.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tv_shows/1
  # DELETE /tv_shows/1.json
  def destroy
    @tv_show = TvShow.find(params[:id])
    @tv_show.destroy

    respond_to do |format|
      format.html { redirect_to tv_shows_url }
      format.json { head :no_content }
    end
  end
end
