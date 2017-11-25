
require './facebook_bot'
map("/facebook_webhook") do
  run Facebook::Messenger::Server
end
