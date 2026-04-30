require "open-uri"
require "ollama"
include Ollama

class EmbeddingExtractor
  CHUNK_SIZE = 1000
  OVERLAP = 200
  def initialize(document:, model: "openai", conversation_id:)
    @document = document
    @model = model
    @conversation = Conversation.find(conversation_id)
    @ollama = Ollama::Client.new(base_url: "http://localhost:11434")
    @openai = openai = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  end

  def call
    # 1 generate chunks
    extract_text
    # 2 generate questions out of chunks generated above
    question_generator
  end

  private

  def chunk_creation(text)
    vector = embed(text)
    chunk_record_generator(vector, text)
  end

  def chunk_record_generator(vector, text)
    clean_text = text.to_s.delete("\u0000")
    @document.chunks.create!(
      content: clean_text,
      embedding: vector
    )
  end

  def question_generator
    result = generate_document_sample_questions

    questions = result["questions"]

    return if questions.blank?

    ActiveRecord::Base.transaction do
      questions.each do |q|
        @conversation.sample_questions.create!(content: q)
      end
    end
    fill_question_container
  end

  def generate_document_sample_questions
    first_5_chunks = @document.chunks
                               .limit(5)
                               .pluck(:content)
                               .join("\n\n")

    response = @openai.responses.create(
      model: "gpt-4o-mini",
      input: [
        {
          role: "system",
          content: "You return ONLY valid JSON. No explanation, no markdown."
        },
        {
          role: "user",
          content: <<~TEXT
            Generate 3 sample questions based only on this document:

            #{first_5_chunks}

            Format:
            {
              "questions": ["...", "..."]
            }
          TEXT
        }
      ]
    )

    JSON.parse(response.output_text)
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

  def self.get_embed(q, model = "openai")
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

  private
  def fill_question_container
    Turbo::StreamsChannel.broadcast_update_to(
      "questions_container",
      target: "questions",
      partial: "sample_questions/sample_question",
      collection: @conversation.sample_questions,
      locals: { conversation: conversation }
    )
  end
end
