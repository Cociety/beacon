class AddRemainingToGoals < ActiveRecord::Migration[6.1]
  def up
    change_column :goals, :duration, :integer, default: 1
    add_column :goals, :remaining, :integer, default: 1
    Goal.where(duration: nil).update_all duration: 1
  end

  def down
    change_column :goals, :duration, :integer, default: nil
    remove_column :goals, :remaining
  end
end
