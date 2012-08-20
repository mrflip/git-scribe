require 'rack'

# %w[html docbook epub pdf].each do |dir|
map "/" do
  run Rack::Directory.new(".")
end
