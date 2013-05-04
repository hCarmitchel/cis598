class AddSentimentsToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :positives, :int

    add_column :reviews, :negatives, :int

  end
end
