# frozen_string_literal: true

# == Schema Information
#
# Table name: lessons
#
#  id         :integer          not null, primary key
#  answer     :string
#  code       :text
#  name       :string
#  task       :text
#  theory     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :integer          not null
#
# Indexes
#
#  index_lessons_on_course_id  (course_id)
#
class Lesson < ApplicationRecord
  belongs_to :course
end
