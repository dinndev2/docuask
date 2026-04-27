require "open-uri"
require "ollama"
include Ollama

class Chat
  def initialize(q, conversation_id)
    @query = q
    @query_embeddings = EmbeddingExtractor.get_embed(q)
    @conversation_id = conversation_id
    Excon.defaults[:read_timeout] = 400
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

    # Pro-tip: Qwen 3.5 is great, but ensure your temperature is around 0.7 for "natural" feeling answers.
    response = @ollama.generate(
      model: "qwen3.5:9b",
      prompt: prompt,
      stream: false,
      options: { temperature: 0.7 }
    )
    response["response"]
  end

  def context
    related_chunks = Chunk.joins(:document).where(documents: { conversation_id: @conversation_id }).nearest_neighbors(:embedding, @query_embeddings, distance: "cosine").limit(5)
    related_chunks.map(&:content).join("\n\n---\n\n")
  end
end
