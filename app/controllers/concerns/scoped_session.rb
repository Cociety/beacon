module ScopedSession
  extend ActiveSupport::Concern

  included do
    def scope_session
      session[scoped_session] ||= {}
    end
  end
end
