class CreateTvSeasons < ActiveRecord::Migration
  def change
    create_table :tv_seasons do |t|
      t.integer :tv_show_id
      t.integer :number

    end
  end
end
