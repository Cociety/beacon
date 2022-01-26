class ExplicitTopLevelGoal < ActiveRecord::Migration[6.1]
  def change
    add_column :goals, :top_level, :boolean, default: false

    Tree.all.each do |tree|
      tree.top_level_goal&.update! top_level: true
    end

    # only allow one top level goal per tree
    add_index :goals, %i[tree_id top_level], unique: true, where: "top_level"
  end
end
