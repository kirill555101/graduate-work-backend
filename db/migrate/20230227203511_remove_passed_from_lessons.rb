# frozen_string_literal: true

class RemovePassedFromLessons < ActiveRecord::Migration[7.0]
  def change
    remove_column :lessons, :passed
  end
end
