class RemoveVectorFromDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :documents, :embedding
  end
end
