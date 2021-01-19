class AddDurationToGoals < ActiveRecord::Migration[6.1]
  def change
    add_column :goals, :duration, :integer
  end
end
