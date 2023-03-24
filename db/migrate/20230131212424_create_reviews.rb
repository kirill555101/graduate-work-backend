# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :course, null: false
      t.text :description, null: false
      t.integer :stars, null: false

      t.timestamps
    end
  end
end
