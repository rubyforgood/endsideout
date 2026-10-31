class AddPositionToContents < ActiveRecord::Migration[8.1]
  def change
    add_column :contents, :position, :integer
    add_index :contents, [ :content_module_id, :position ]
    add_index :contents, [ :content_module_id, :contentable_type, :contentable_id ], unique: true, name: "index_contents_on_module_and_contentable"

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE contents SET position = (
            SELECT COUNT(*) FROM contents earlier
            WHERE earlier.content_module_id = contents.content_module_id AND earlier.id <= contents.id
          )
        SQL
      end
    end
  end
end
