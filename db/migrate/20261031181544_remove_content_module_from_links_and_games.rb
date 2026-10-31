class RemoveContentModuleFromLinksAndGames < ActiveRecord::Migration[8.1]
  def up
    remove_reference :links, :content_module, foreign_key: true, index: true
    remove_column :links, :position
    remove_reference :games, :content_module, foreign_key: true, index: true
  end

  def down
    add_reference :links, :content_module, foreign_key: true, index: true
    add_column :links, :position, :integer
    add_reference :games, :content_module, foreign_key: true, index: true

    execute <<~SQL
      UPDATE links SET
        content_module_id = (SELECT content_module_id FROM contents WHERE contentable_type = 'Link' AND contentable_id = links.id),
        position = (SELECT position FROM contents WHERE contentable_type = 'Link' AND contentable_id = links.id)
    SQL

    # A game can be in many modules, but the old column held one, so pick the lowest content id.
    execute <<~SQL
      UPDATE games SET
        content_module_id = (SELECT content_module_id FROM contents WHERE contentable_type = 'Game' AND contentable_id = games.id ORDER BY id LIMIT 1)
    SQL

    change_column_null :links, :content_module_id, false
  end
end
