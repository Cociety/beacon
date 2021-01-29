class RenameRemainingToSpent < ActiveRecord::Migration[6.1]
  def up
    rename_column :goals, :remaining, :spent

    Goal.all.each { |g| g.update_columns spent: g.duration - g.spent }

    change_column :goals, :spent, :integer, default: 0
  end

  def down
    rename_column :goals, :spent, :remaining

    Goal.all.each { |g| g.update_columns remaining: g.duration - g.remaining }

    change_column :goals, :remaining, :integer, default: 1
  end
end
