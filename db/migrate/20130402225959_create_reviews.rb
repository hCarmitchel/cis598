class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.text :content
      t.date :year_reviewed
      t.string :title
      t.string :author
      t.string :link
      t.decimal :rating
      t.string :website
      t.references :reviewable, :polymorphic => true

    end
  end
end
