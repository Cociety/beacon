require 'ostruct'
module ApplicationHelper
  def goal_states
    Goal.states.map { |state, _| OpenStruct.new(value: state, text: t(state)) }
  end
end
