class Chunk < ApplicationRecord
  belongs_to :document
  has_neighbors :embedding
  belongs_to :response, optional: true

  has_many :response_resources
  has_many :responses, through: :response_sources
end
