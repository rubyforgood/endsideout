class AddPositionToContents < ActiveRecord::Migration[8.1]
  def change
    add_column :contents, :position, :integer
    add_index :contents, [ :content_module_id, :position ]
    add_index :contents, [ :content_module_id, :contentable_type, :contentable_id ], unique: true, name: "index_contents_on_module_and_contentable"
  end
end
