class AskAiJob < ApplicationJob
  queue_as :default

  def perform(question, conversation_id, selected_model)
    answer = Chat.new(question, conversation_id, selected_model).call
    clear_thinking_state(conversation_id)
    Response.create!(content: answer, sender: :ai, conversation_id: conversation_id)
    rescue OpenAI::Errors::APIConnectionError => e
        handle_error(conversation_id, "The server could not be reached", e)

    rescue OpenAI::Errors::RateLimitError => e
      handle_error(conversation_id, "Rate limit hit. Backing off a bit.", e)

    rescue OpenAI::Errors::APIStatusError => e
      handle_error(conversation_id, "Unexpected API error occurred", e)
  end

  private

  def error_callback(conversation_id, msg)
    clear_thinking_state(conversation_id)
      Response.create!(
        content: msg,
        sender: :ai,
        conversation_id: conversation_id
      )
  end

  def handle_error(conversation_id, message, exception)
    Rails.logger.error("[AI ERROR] #{exception.class}: #{exception.message}")

    error_callback(conversation_id, message)
  end

  def clear_thinking_state(conversation_id)
    Turbo::StreamsChannel.broadcast_update_to(
      "thinking_stream_container",
      target: "thinking-container",
      html: ""
    )
  end
end
