class TvSeasonsController < ApplicationController
  # GET /tv_seasons
  # GET /tv_seasons.json
  def index
    @tv_seasons = TvSeason.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: TVSeasonsDatatable.new(view_context)  }
    end
  end

  # GET /tv_seasons/1
  # GET /tv_seasons/1.json
  def show
    @tv_season = TvSeason.find(params[:id])
    @top_episodes = TvSeason.rated_episodes(params[:id],'desc',3)
    @bottom_episodes = TvSeason.rated_episodes(params[:id],'asc',3)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tv_season }
    end
  end

  # GET /tv_seasons/new
  # GET /tv_seasons/new.json
  def new
    @tv_season = TvSeason.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tv_season }
    end
  end

  # GET /tv_seasons/1/edit
  def edit
    @tv_season = TvSeason.find(params[:id])
  end

  # POST /tv_seasons
  # POST /tv_seasons.json
  def create
    @tv_season = TvSeason.new(params[:tv_season])

    respond_to do |format|
      if @tv_season.save
        format.html { redirect_to @tv_season, notice: 'Tv season was successfully created.' }
        format.json { render json: @tv_season, status: :created, location: @tv_season }
      else
        format.html { render action: "new" }
        format.json { render json: @tv_season.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tv_seasons/1
  # PUT /tv_seasons/1.json
  def update
    @tv_season = TvSeason.find(params[:id])

    respond_to do |format|
      if @tv_season.update_attributes(params[:tv_season])
        format.html { redirect_to @tv_season, notice: 'Tv season was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tv_season.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tv_seasons/1
  # DELETE /tv_seasons/1.json
  def destroy
    @tv_season = TvSeason.find(params[:id])
    @tv_season.destroy

    respond_to do |format|
      format.html { redirect_to tv_seasons_url }
      format.json { head :no_content }
    end
  end
end
