require "open-uri"
require "ollama"
include Ollama

class EmbeddingExtractor
  CHUNK_SIZE = 1000
  OVERLAP = 200
  def initialize(document, model = "openai")
    @document = document
    @model = model
    @ollama = Ollama::Client.new(base_url: "http://localhost:11434")
    @openai = openai = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
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
    if @model == "ollama"
      @ollama.embed(model: "nomic-embed-text", input: text)["embeddings"].first
    else
      @openai.embeddings.create(
        model: "text-embedding-3-small",
        input: text,
        dimensions: 768
      ).data[0].embedding
    end
  end

  def self.get_embed(q, model)
    @ollama = Ollama::Client.new(base_url: "http://localhost:11434")
    @openai = openai = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    if model == "ollama"
      @ollama.embed(model: "nomic-embed-text", input: q)["embeddings"].first
    else
      @openai.embeddings.create(
        model: "text-embedding-3-small",
        input: q,
        dimensions: 768
      ).data[0].embedding
    end
  end
end
