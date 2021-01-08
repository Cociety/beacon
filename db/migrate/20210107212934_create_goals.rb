class CreateGoals < ActiveRecord::Migration[6.1]
  def change
    create_table :goals, id: :uuid do |t|
      t.string :name

      t.timestamps
    end

    create_join_table :parent, :child, column_options: {type: :uuid}, table_name: 'goal_relationships' do |t|
      t.index :parent_id
      t.index :child_id

      t.foreign_key :goals, column: :parent_id
      t.foreign_key :goals, column: :child_id
    end
  end
end
