class Document < ApplicationRecord
  has_one_attached :context_file
  after_commit :generate_embeddings, on: [ :create, :update ]
  validate :pdf_only_context_file
  has_many :chunks, dependent: :destroy
  belongs_to :conversation


  private

  def pdf_only_context_file
    return unless context_file.attached?
    unless context_file.content_type == "application/pdf"
      errors.add(:context_file, "must be a PDF file")
    end
  end

  def generate_embeddings
    EmbeddingExtractor.new(self).call()
  end
end
