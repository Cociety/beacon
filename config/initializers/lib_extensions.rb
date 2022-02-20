[
  'rails_extensions',
  'ruby_extensions'
].each do |ext|
  Dir[Rails.root.join("lib/#{ext}/**/*.rb")].each do |file|
    require file
  end
end
