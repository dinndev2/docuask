class CreateSampleQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :sample_questions do |t|
      t.string :content
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
