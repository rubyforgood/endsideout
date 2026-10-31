class RequirePositionsForContentsAndModules < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        # Number modules from 1 within each program and level: current position first (NULLs last), then id.
        execute <<~SQL
          UPDATE content_modules SET position = (
            SELECT ranked.row_number FROM (
              SELECT id, ROW_NUMBER() OVER (
                PARTITION BY program_id, level
                ORDER BY position IS NULL, position, id
              ) AS row_number
              FROM content_modules
            ) ranked
            WHERE ranked.id = content_modules.id
          )
        SQL
      end
    end

    change_column_null :content_modules, :position, false
    add_index :content_modules, [ :program_id, :level, :position ]
    change_column_null :contents, :position, false
  end
end
