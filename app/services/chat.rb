require "open-uri"
require "ollama"
require "bundler/setup"
require "openai"
include Ollama

class Chat
  def initialize(q, conversation_id, selected_model = "openai")
    Excon.defaults[:read_timeout] = 1000
    @query = q
    @query_embeddings = EmbeddingExtractor.get_embed(q, selected_model)
    @conversation_id = conversation_id
    @selected_model = selected_model
    @openai = openai = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    @ollama = Ollama::Client.new(base_url: "http://localhost:11434")
  end

  def call
    generate_response
  end


  def generate_response
    # Adding a clearer instruction set helps the LLM understand it's an assistant, not a copier.
    prompt = <<~PROMPT
      [INSTRUCTIONS]
      You are a professional assistant for Din. Use the PROVIDED CONTEXT below to answer the user's QUERY.#{' '}
      - Be concise and direct.
      - If the context doesn't contain the answer, say "I couldn't find that in the documents."
      - Do not repeat the context verbatim; summarize and explain it.

      [CONTEXT]
      #{context}

      [USER QUERY]
      #{@query}

      [ASSISTANT ANSWER]
    PROMPT
    response_by_model(prompt)
  end

  def response_by_model(prompt)
    if @selected_model == "openai"
      response = @openai.responses.create(
        model: "gpt-4o-mini",
        input: prompt
      )
      response.output_text
    elsif @selected_model == "ollama"
      local_response(prompt)["response"]
    end
  end

  def local_response(prompt)
    @ollama.generate(
      model: "qwen3.5:9b",
      prompt: prompt,
      stream: false,
      options: { temperature: 0.7 }
    )
  end

  def context
    related_chunks = Chunk.joins(:document).where(documents: { conversation_id: @conversation_id }).nearest_neighbors(:embedding, @query_embeddings, distance: "cosine").limit(5)
    related_chunks.map(&:content).join("\n\n---\n\n")
  end
end
