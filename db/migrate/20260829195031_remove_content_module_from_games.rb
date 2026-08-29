class RemoveContentModuleFromGames < ActiveRecord::Migration[8.1]
  def change
    remove_reference :games, :content_module, foreign_key: true
  end
end
