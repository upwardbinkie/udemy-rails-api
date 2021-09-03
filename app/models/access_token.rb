# frozen_string_literal: true
class AccessToken < ApplicationRecord
  validates :token, presence: true, uniqueness: true
  validates :user, presence: true

  belongs_to :user

  after_initialize :generate_token

  private

  def generate_token
    loop do
      break if token.present? && !AccessToken.where.not(id: id).exists?(token: token)
      self.token = SecureRandom.hex(10)
    end
  end
end
