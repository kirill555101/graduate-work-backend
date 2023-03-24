# frozen_string_literal: true

# == Schema Information
#
# Table name: courses_authors
#
#  id              :integer          not null, primary key
#  email           :string           not null
#  full_name       :string           not null
#  login           :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class CoursesAuthor < ApplicationRecord
  has_secure_password

  has_many :courses

  def as_json(args = {})
    super(
      args.merge(
        except: %i[login password_digest created_at updated_at],
        methods: %i[type]
      )
    )
  end

  private

  def type
    'courses_author'
  end
end
