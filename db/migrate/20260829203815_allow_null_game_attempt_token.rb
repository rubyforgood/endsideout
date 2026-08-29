class AllowNullGameAttemptToken < ActiveRecord::Migration[8.1]
  def up
    change_column :game_attempts, :token, :text, null: true
  end

  def down
    change_column :game_attempts, :token, :string, null: false
  end
end
