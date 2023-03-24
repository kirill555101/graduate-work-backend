# frozen_string_literal: true

# == Schema Information
#
# Table name: student_courses
#
#  id         :integer          not null, primary key
#  passed     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :integer          not null
#  lessons_id :integer
#  student_id :integer          not null
#
# Indexes
#
#  index_student_courses_on_course_id   (course_id)
#  index_student_courses_on_lessons_id  (lessons_id)
#  index_student_courses_on_student_id  (student_id)
#
class StudentCourse < ApplicationRecord
  belongs_to :student
  belongs_to :course

  before_create :set_lessons_id

  def as_json(args = {})
    super(
      args.merge(
        except: %i[created_at],
        methods: %i[course_name student_full_name]
      )
    )
  end

  private

  def set_lessons_id
    self.lessons_id = course.lessons.first&.id
  end

  def course_name
    course.name
  end

  def student_full_name
    student.full_name
  end
end
