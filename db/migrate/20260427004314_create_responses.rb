class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.integer :sender, default: 0
      t.string :content
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
