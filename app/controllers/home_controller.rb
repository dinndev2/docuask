class HomeController < ApplicationController
  # app/controllers/home_controller.rb
  def index
    @conversations = Conversation.order(created_at: :desc)
    @conversation = Conversation.new
  end
end
