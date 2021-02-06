Dir[Rails.root.join('lib/rails_extensions/**/*.rb')].each do |file|
  require file
end
