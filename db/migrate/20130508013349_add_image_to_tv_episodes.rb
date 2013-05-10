class AddImageToTvEpisodes < ActiveRecord::Migration
  def change
    add_column :tv_episodes, :image, :string

  end
end
