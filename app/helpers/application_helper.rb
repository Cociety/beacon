require "ostruct"
module ApplicationHelper
  def sign_in_url
    cociety_url(Rails.application.config.cociety[:sign_in_path])
  end

  def sign_out_url
    cociety_url(Rails.application.config.cociety[:sign_out_path])
  end

  private

  def cociety_url(path = '/')
    cociety = Rails.application.config.cociety
    protocol = cociety[:protocol] == :http ? URI::HTTP : URI::HTTPS
    protocol.build(
      host:  cociety[:host],
      port:  cociety[:port],
      path:  path,
      query: { redirect_to: request.original_url }.to_query
    ).to_s
  end

  def popover_tag
    turbo_frame_tag :popover, loading: :eager
  end

  def popover_content_tag(id, **attributes, &block)
    turbo_frame_tag :popover do
      turbo_frame_tag "#{dom_id(id)}_popover" do
        tag.div(**attributes.merge(data: { controller: 'popover-content' }).compact, &block)
      end
    end
  end

  def goal_states
    Goal.states.map { |state, _| OpenStruct.new(value: state, text: t(state)) }
  end

  def attribute_errors(model, attribute)
    model.errors.select { |e| e.attribute == attribute }
  end
end
