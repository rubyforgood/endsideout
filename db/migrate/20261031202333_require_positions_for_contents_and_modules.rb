class RequirePositionsForContentsAndModules < ActiveRecord::Migration[8.1]
  def change
    change_column_null :content_modules, :position, false
    add_index :content_modules, [ :program_id, :level, :position ]
    change_column_null :contents, :position, false
  end
end
