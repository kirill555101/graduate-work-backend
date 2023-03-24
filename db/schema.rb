# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_02_27_203511) do
  create_table "admins", force: :cascade do |t|
    t.string "login", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "courses_author_id", null: false
    t.string "will_learn"
    t.string "for_whom"
    t.index ["courses_author_id"], name: "index_courses_on_courses_author_id"
  end

  create_table "courses_authors", force: :cascade do |t|
    t.string "login", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "course_id", null: false
    t.string "name"
    t.text "theory"
    t.text "task"
    t.string "answer"
    t.text "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "course_id", null: false
    t.text "description", null: false
    t.integer "stars", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "student_id", null: false
    t.index ["course_id"], name: "index_reviews_on_course_id"
    t.index ["student_id"], name: "index_reviews_on_student_id"
  end

  create_table "student_courses", force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "student_id", null: false
    t.boolean "passed", default: false
    t.integer "lessons_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_student_courses_on_course_id"
    t.index ["lessons_id"], name: "index_student_courses_on_lessons_id"
    t.index ["student_id"], name: "index_student_courses_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "login", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
