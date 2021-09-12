if goal
  @goal_id_map ||= goal.tree.goals.index_by(&:id)

  json.id goal.id
  json.name goal.name
  json.state goal.state
  json.duration goal.duration
  if @goal_id_map[goal.id]
    if @show_completed_goals
      json.children @goal_id_map[goal.id].children, partial: 'goals/goal', as: :goal
    else
      json.children @goal_id_map[goal.id].children.incomplete, partial: 'goals/goal', as: :goal
    end
  end
else
  json.name I18n.t('goals.none')
end
