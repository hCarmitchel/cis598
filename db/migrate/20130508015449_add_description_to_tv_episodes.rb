class AddDescriptionToTvEpisodes < ActiveRecord::Migration
  def change
    add_column :tv_episodes, :description, :text

  end
end
