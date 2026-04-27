class AddConversationReferenceToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_reference :documents, :conversation, foreign_key: true
  end
end
