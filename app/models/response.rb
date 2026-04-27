class Response < ApplicationRecord
  belongs_to :conversation
  enum :sender, [ :ai, :guest ]

  broadcasts_to ->(response) { "responses" }, inserts_by: :append
end
