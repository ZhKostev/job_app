class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :title
      t.text :body
      t.string :web_source
      t.string :product_id

      t.timestamps null: false
    end
    add_index :reviews, [:product_id], :name => "product_id_index"
    add_index :reviews, [:web_source], :name => "web_source_index"
  end
end
