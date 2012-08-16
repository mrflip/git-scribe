require 'rack'

# %w[html docbook epub pdf].each do |dir|
map "/" do
  run Rack::Directory.new("html")
end


run ->(env) do
  [ 200,
    { 'Content-Type'  => 'text/plain', },
    [[Dir['**/*'], env].flatten.join("\n")]
  ]
end
