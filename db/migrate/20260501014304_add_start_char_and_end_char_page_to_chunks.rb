class AddStartCharAndEndCharPageToChunks < ActiveRecord::Migration[8.0]
  def change
    add_column :chunks, :start_char, :integer
    add_column :chunks, :end_char, :integer
    add_column :chunks, :page, :integer
  end
end
