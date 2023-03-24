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
require 'rails_helper'

RSpec.describe Lesson, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
