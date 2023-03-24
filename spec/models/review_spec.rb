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
require 'rails_helper'

RSpec.describe Review, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
