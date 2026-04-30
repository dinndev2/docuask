  class ConversationsController < ApplicationController
    before_action :set_conversation, only: [ :show, :ask ]
    def show
      @responses = @conversation.responses
      @conversations = Conversation.all.order(created_at: :desc)
      count = @conversation.sample_questions.count
      offset = rand(count)
      @sample_questions = @conversation.sample_questions.offset(offset).limit(3)
    end
    def index
    end

    def ask
      question = params[:query]
      return if question.empty?
      selected_model = "openai"
      question_record = Response.create!(content: question, sender: :guest, conversation: @conversation)
      AskAiJob.perform_later(question, @conversation.id, selected_model)

      respond_to do |f|
        f.json { render json: { message: "Asking" }, status: :accepted }
        f.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              "responses",
              partial: "responses/response",
              locals: { response: question_record }
            ),
            turbo_stream.append(
              "thinking-container",
              partial: "responses/thinking",
              locals: { response: question_record }
            )
          ]
        end
        f.html { redirect_to @conversation }
      end
    end

    def create
      @conversation = Conversation.new(conversation_params)
      respond_to do |f|
        if @conversation.save
          f.turbo_stream { redirect_to conversation_path(@conversation) }
          f.html { redirect_to conversation_path(@conversation) }
        else
          @conversations = Conversation.order(created_at: :desc)
          f.turbo_stream do |turbo_stream|
            turbo_stream.replace "context-upload" do
              render partial: "conversations/form", locals: { conversation: @conversation }
            end
          end
        end
      end
    end

    private

    def conversation_params
      params.require(:conversation).permit(documents_attributes: [ :context_file ])
    end

    def set_conversation
      @conversation = Conversation.find(params[:id])
    end
  end
