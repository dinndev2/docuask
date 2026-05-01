class CreateResponseResources < ActiveRecord::Migration[8.0]
  def change
    create_table :response_resources do |t|
      t.float :score
      t.integer :rank
      t.references :chunk, null: false, foreign_key: true
      t.references :response, null: false, foreign_key: true

      t.timestamps
    end
  end
end
