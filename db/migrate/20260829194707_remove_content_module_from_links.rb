class RemoveContentModuleFromLinks < ActiveRecord::Migration[8.1]
  def change
    remove_reference :links, :content_module, null: false, foreign_key: true
  end
end
