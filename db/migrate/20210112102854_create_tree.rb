class CreateTree < ActiveRecord::Migration[6.1]
  def up
    create_table :trees, id: :uuid do |t|
      t.timestamps
    end

    add_reference :goals, :tree, **{ type: :uuid, foreign_key: true }

    Goal.parents.each do |g|
      link_tree_to_goal g, Tree.create
    end

    change_column :goals, :tree_id, :uuid, **{ null: false }
  end

  def down
    remove_reference :goals, :tree
    drop_table :trees
  end

  private

  def link_tree_to_goal(goal, tree)
    goal.update tree: tree
    goal.children.each { |c| link_tree_to_goal c, tree }
  end
end
