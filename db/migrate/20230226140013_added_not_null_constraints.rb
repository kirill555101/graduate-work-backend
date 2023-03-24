# frozen_string_literal: true

class AddedNotNullConstraints < ActiveRecord::Migration[7.0]
  def change
    change_column_null :reviews, :student_id, false
    change_column_null :courses, :courses_author_id, false
  end
end
