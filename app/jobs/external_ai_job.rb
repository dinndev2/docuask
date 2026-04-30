class ExternalAiJob < ApplicationJob
  queue_as :default

  def perform(document, model, conversation_id)
    EmbeddingExtractor.new(document: document, model: "openai", conversation_id: conversation_id).call()
  end
end
