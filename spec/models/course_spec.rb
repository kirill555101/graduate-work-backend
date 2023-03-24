# == Schema Information
#
# Table name: courses
#
#  id                :integer          not null, primary key
#  description       :text
#  for_whom          :string
#  name              :string           not null
#  will_learn        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  courses_author_id :integer          not null
#
# Indexes
#
#  index_courses_on_courses_author_id  (courses_author_id)
#
require 'rails_helper'

RSpec.describe Course, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
