# frozen_string_literal: true

class CreateStudentCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :student_courses do |t|
      t.references :course, null: false
      t.references :student, null: false
      t.boolean :passed, default: false
      t.references :lessons

      t.timestamps
    end
  end
end
