# frozen_string_literal: true

# == Schema Information
#
# Table name: reviews
#
#  id          :integer          not null, primary key
#  description :text             not null
#  stars       :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  course_id   :integer          not null
#  student_id  :integer          not null
#
# Indexes
#
#  index_reviews_on_course_id   (course_id)
#  index_reviews_on_student_id  (student_id)
#
class Review < ApplicationRecord
  belongs_to :student
  belongs_to :course

  def as_json(args = {})
    super(
      args.merge(
        except: %i[updated_at],
        methods: %i[student_full_name]
      )
    )
  end

  private

  def student_full_name
    student.full_name
  end
end
