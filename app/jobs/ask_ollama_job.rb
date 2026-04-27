class AskOllamaJob < ApplicationJob
  queue_as :default

  # app/jobs/ask_ollama_job.rb
  def perform(question, conversation_id)
    begin
      answer = Chat.new(question, conversation_id).call

      # Clear thinking state and create AI response
      clear_thinking_state(conversation_id)
      Response.create!(content: answer, sender: :ai, conversation_id: conversation_id)

    rescue Ollama::Errors::TimeoutError
      clear_thinking_state(conversation_id)
      Response.create!(
        content: "Error: The AI took too long to respond. Try a shorter question or check Ollama status.",
        sender: :ai,
        conversation_id: conversation_id
      )
    end
  end

  private

  def clear_thinking_state(conversation_id)
    Turbo::StreamsChannel.broadcast_update_to(
      "thinking_stream_container",
      target: "thinking-container",
      html: ""
    )
  end
end
