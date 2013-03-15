require 'test_helper'

class TvSeasonsControllerTest < ActionController::TestCase
  setup do
    @tv_season = tv_seasons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tv_seasons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tv_season" do
    assert_difference('TvSeason.count') do
      post :create, tv_season: @tv_season.attributes
    end

    assert_redirected_to tv_season_path(assigns(:tv_season))
  end

  test "should show tv_season" do
    get :show, id: @tv_season
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tv_season
    assert_response :success
  end

  test "should update tv_season" do
    put :update, id: @tv_season, tv_season: @tv_season.attributes
    assert_redirected_to tv_season_path(assigns(:tv_season))
  end

  test "should destroy tv_season" do
    assert_difference('TvSeason.count', -1) do
      delete :destroy, id: @tv_season
    end

    assert_redirected_to tv_seasons_path
  end
end
