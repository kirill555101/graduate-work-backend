# frozen_string_literal: true

# == Schema Information
#
# Table name: admins
#
#  id              :integer          not null, primary key
#  login           :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Admin < ApplicationRecord
  has_secure_password

  def as_json(args = {})
    super(
      args.merge(
        except: %i[password_digest created_at updated_at],
        methods: %i[type]
      )
    )
  end

  private

  def type
    'admin'
  end
end
