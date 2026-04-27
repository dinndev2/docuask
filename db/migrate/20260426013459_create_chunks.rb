class CreateChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :chunks do |t|
      t.vector :embedding, limit: 768
      t.references :document, null: false, foreign_key: true
      t.timestamps
    end
  end
end
