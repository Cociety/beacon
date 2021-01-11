class AddStateToGoal < ActiveRecord::Migration[6.1]
  def change
    add_column :goals, :state, :integer, null: false, default: 0
  end
end
