# require "bunny"
# require 'json'

# bunny_connection = Bunny.new
# bunny_connection.start

# channel = bunny_connection.create_channel
# subscribe  = channel.queue("subscription_queue", :auto_delete => true)
# exchange  = channel.default_exchange


# exchange.publish('{"type":"subscribe","user_id":"1","fanpage":"UAP.Poznan"}', :routing_key => subscribe.name)
# exchange.publish('{"type":"subscribe","user_id":"111","fanpage":"meetjspl"}', :routing_key => subscribe.name)

# bunny_connection.close

require "bunny"
require 'json'

bunny_connection = Bunny.new
bunny_connection.start

channel = bunny_connection.create_channel
queue  = channel.queue("facebook_posts", :auto_delete => true)
exchange  = channel.default_exchange
queue.subscribe do |delivery_info, metadata, payload|
  puts payload
end
loop {}