class RemoveContentModuleFromLinksAndGames < ActiveRecord::Migration[8.1]
  def up
    remove_reference :links, :content_module, foreign_key: true, index: true
    remove_column :links, :position
    remove_reference :games, :content_module, foreign_key: true, index: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
