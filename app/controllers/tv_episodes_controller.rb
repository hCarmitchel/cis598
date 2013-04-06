class TvEpisodesController < ApplicationController
  # GET /tv_episodes
  # GET /tv_episodes.json
  def index
    @tv_episodes = TvEpisode.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json:  TVEpisodesDatatable.new(view_context) }
    end
  end

  # GET /tv_episodes/1
  # GET /tv_episodes/1.json
  def show
    @tv_episode = TvEpisode.find(params[:id])
    @IMDBrating = Rating.rating("TvEpisode","tv_episodes",params[:id],'IMDB').to_a[0]

    if !@IMDBrating.average.nil?
      @IMDBrating = @IMDBrating.average[0..2]
    else
      @IMDBrating = "N/A"
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tv_episode }
    end
  end

  # GET /tv_episodes/new
  # GET /tv_episodes/new.json
  def new
    @tv_episode = TvEpisode.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tv_episode }
    end
  end

  # GET /tv_episodes/1/edit
  def edit
    @tv_episode = TvEpisode.find(params[:id])
  end

  # POST /tv_episodes
  # POST /tv_episodes.json
  def create
    @tv_episode = TvEpisode.new(params[:tv_episode])

    respond_to do |format|
      if @tv_episode.save
        format.html { redirect_to @tv_episode, notice: 'Tv episode was successfully created.' }
        format.json { render json: @tv_episode, status: :created, location: @tv_episode }
      else
        format.html { render action: "new" }
        format.json { render json: @tv_episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tv_episodes/1
  # PUT /tv_episodes/1.json
  def update
    @tv_episode = TvEpisode.find(params[:id])

    respond_to do |format|
      if @tv_episode.update_attributes(params[:tv_episode])
        format.html { redirect_to @tv_episode, notice: 'Tv episode was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tv_episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tv_episodes/1
  # DELETE /tv_episodes/1.json
  def destroy
    @tv_episode = TvEpisode.find(params[:id])
    @tv_episode.destroy

    respond_to do |format|
      format.html { redirect_to tv_episodes_url }
      format.json { head :no_content }
    end
  end
end
