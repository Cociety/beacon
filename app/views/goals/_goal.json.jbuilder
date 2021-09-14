if goal
  @goal_id_map ||= goal.tree.goals.index_by(&:id)

  json.id goal.id
  json.name goal.name
  json.state goal.state
  json.duration goal.duration
  assignee = goal.assignee
  if assignee
    json.assignee do
      json.avatar_url avatar_url(assignee)
    end
  end
  if @goal_id_map[goal.id]
    children = @show_completed_goals ? @goal_id_map[goal.id].children : @goal_id_map[goal.id].children.incomplete
    json.children children, partial: 'goals/goal', as: :goal
  end
else
  json.name I18n.t('goals.none')
end
