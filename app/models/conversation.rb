class Conversation < ApplicationRecord
  has_many :documents, dependent: :destroy
  accepts_nested_attributes_for :documents
  validate :documents_must_be_valid
  has_many :responses
  has_many :sample_questions

  AI_MODELS = %w[openai]

  private
  def documents_must_be_valid
    documents.each do |doc|
      next if doc.valid?
      doc.errors.each do |error|
        errors.add(:base, "Document error: #{error.full_message}")
      end
    end
  end
end
