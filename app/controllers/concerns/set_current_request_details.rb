module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.url = request.original_url
    end
  end
end
