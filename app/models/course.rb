# frozen_string_literal: true

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
class Course < ApplicationRecord
  belongs_to :courses_author

  has_many :lessons
  has_many :reviews

  def as_json(args = {})
    super(
      args.merge(
        except: %i[courses_author_id updated_at],
        methods: %i[stars author_full_name]
      )
    )
  end

  def stars
    # reviews.sum(:stars)
    rand(0..5)
  end

  private

  def author_full_name
    courses_author.full_name
  end
end
