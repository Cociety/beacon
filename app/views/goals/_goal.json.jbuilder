@goal_id_map ||= goal.tree.goals.index_by(&:id)

json.id goal.id
json.name goal.name
json.state goal.state
json.duration goal.duration
json.children @goal_id_map[goal.id].children, partial: 'goals/goal', as: :goal if @goal_id_map[goal.id]
