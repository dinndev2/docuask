class AddContentToChunks < ActiveRecord::Migration[8.0]
  def change
    add_column :chunks, :content, :string
  end
end
