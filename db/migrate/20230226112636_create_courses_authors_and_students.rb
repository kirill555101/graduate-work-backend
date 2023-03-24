# frozen_string_literal: true

class CreateCoursesAuthorsAndStudents < ActiveRecord::Migration[7.0]
  def change
    create_table :courses_authors do |t|
      t.string :login, null: false
      t.string :email, null: false
      t.string :full_name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    create_table :students do |t|
      t.string :login, null: false
      t.string :email, null: false
      t.string :full_name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    add_reference :courses, :courses_author, index: true
    add_reference :reviews, :student, index: true
  end
end
