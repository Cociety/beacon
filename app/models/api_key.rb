class ApiKey < ApplicationRecord
  belongs_to :customer
  # avoid loading keys into memory by default
  default_scope { select(ApiKey.column_names.map(&:to_sym) - [:key]) }

  def initialize(*args, **kwargs)
    super(*args, **kwargs)
    self.id ||= generate_key
    self.key ||= generate_key
  end

  private

  def generate_key
    SecureRandom.hex(20)
  end
end
