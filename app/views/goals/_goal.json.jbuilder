json.id goal.id
json.name goal.name
json.state goal.state
json.children goal.children, partial: 'goals/goal.json', as: :goal
