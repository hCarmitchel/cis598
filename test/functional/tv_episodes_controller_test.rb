require 'test_helper'

class TvEpisodesControllerTest < ActionController::TestCase
  setup do
    @tv_episode = tv_episodes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tv_episodes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tv_episode" do
    assert_difference('TvEpisode.count') do
      post :create, tv_episode: @tv_episode.attributes
    end

    assert_redirected_to tv_episode_path(assigns(:tv_episode))
  end

  test "should show tv_episode" do
    get :show, id: @tv_episode
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tv_episode
    assert_response :success
  end

  test "should update tv_episode" do
    put :update, id: @tv_episode, tv_episode: @tv_episode.attributes
    assert_redirected_to tv_episode_path(assigns(:tv_episode))
  end

  test "should destroy tv_episode" do
    assert_difference('TvEpisode.count', -1) do
      delete :destroy, id: @tv_episode
    end

    assert_redirected_to tv_episodes_path
  end
end
