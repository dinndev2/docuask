class AddTitleToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :title, :string
  end
end
