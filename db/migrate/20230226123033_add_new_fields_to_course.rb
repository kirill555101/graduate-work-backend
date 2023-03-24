# frozen_string_literal: true

class AddNewFieldsToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :will_learn, :string
    add_column :courses, :for_whom, :string
  end
end
