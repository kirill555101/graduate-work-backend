# frozen_string_literal: true

class CreateLessons < ActiveRecord::Migration[7.0]
  def change
    create_table :lessons do |t|
      t.references :course, null: false
      t.string :name
      t.text :theory
      t.text :task
      t.string :answer
      t.text :code
      t.boolean :passed, default: false

      t.timestamps
    end
  end
end
