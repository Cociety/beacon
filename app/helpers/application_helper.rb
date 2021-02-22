require 'ostruct'
module ApplicationHelper
  def popover_tag
    turbo_frame_tag :popover, loading: :eager
  end

  def popover_content_tag(_id, **attributes, &block)
    turbo_frame_tag :popover do
      tag.div(**attributes.merge(data: { controller: 'popover-content' }).compact, &block)
    end
  end

  def goal_states
    Goal.states.map { |state, _| OpenStruct.new(value: state, text: t(state)) }
  end
end
