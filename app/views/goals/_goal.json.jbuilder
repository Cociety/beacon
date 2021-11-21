if goal
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
else
  json.name I18n.t('goals.none')
end
