class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :votes 
      t.decimal :total_rating
      t.string :rating_website
      t.references :rateable, :polymorphic => true

      t.timestamps
    end
  end
end
