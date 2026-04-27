require "open-uri"
require "ollama"
include Ollama

class EmbeddingExtractor
  CHUNK_SIZE = 1000
  OVERLAP = 200
  def initialize(document)
    @document = document
    @ollama = Ollama::Client.new(base_url: "http://localhost:11434")
  end

  def call
    extract_text
  end

  private
  def chunk_creation(text)
    vector = embed(text)
    ActiveRecord::Base.transaction do
      @document.chunks.create!(
        content: text,
        embedding: vector
      )
    end
  end

  def extract_text
    @document.context_file.open do |file|
      reader = PDF::Reader.new(file.path)
      text = reader.pages.map(&:text).join("\n").scrub
      start_bit = 0
      while start_bit < text.length
        end_bit = start_bit + CHUNK_SIZE
        chunk_text = text[start_bit...end_bit]
        next if chunk_text.blank?
        chunk_creation(chunk_text)
        start_bit += (CHUNK_SIZE - OVERLAP)
      end
    end
  rescue PDF::Reader::MalformedPDFError => e
    Rails.logger.error "PDF parsing failed: #{e.message}"
    nil
  end

  def embed(text)
    @ollama.embed(model: "nomic-embed-text", input: text)["embeddings"].first
  end

  def self.get_embed(q)
    @ollama = Ollama::Client.new(base_url: "http://localhost:11434")
    @ollama.embed(model: "nomic-embed-text", input: q)["embeddings"].first
  end
end
