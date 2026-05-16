class CreatePrograms < ActiveRecord::Migration[8.1]
  def change
    create_table :programs do |t|
      t.string :name

      t.timestamps
    end

    create_join_table :classrooms, :programs do |t|
      t.index :program_id
      t.index :classroom_id
    end
  end
end
