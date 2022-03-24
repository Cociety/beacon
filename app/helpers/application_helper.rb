require 'ostruct'
module ApplicationHelper
  def goal_states
    Goal.states.map { |state, _| OpenStruct.new(value: state, text: t(state)) }
  end

  def title
    "Beacon#{ENV['RAILS_ENV'] == 'production' ? '' : " [#{ENV['RAILS_ENV']}]"}"
  end
end
