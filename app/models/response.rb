class Response < ApplicationRecord
  belongs_to :conversation
  enum :sender, [ :ai, :guest ]

  broadcasts_to ->(response) { "responses" }, inserts_by: :append
  has_many :response_resources
  has_many :chunks, through: :response_resources
end
