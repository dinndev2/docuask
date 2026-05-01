class AddContentToResponseResources < ActiveRecord::Migration[8.0]
  def change
    add_column :response_resources, :content, :string
  end
end
