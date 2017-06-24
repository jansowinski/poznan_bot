require "bunny"
# require 'telegram/bot'
require 'koala'
require 'json'
require 'net/http'


# RabbitMQ config
bunny_connection = Bunny.new
bunny_connection.start

ch = bunny_connection.create_channel
queue  = ch.queue("facebook_posts", :auto_delete => true)
exchange  = ch.default_exchange

# Facebook config
config_json = JSON.parse(File.read('config'))
subscribed = config_json['facebook']['subscribed']
Koala.configure do |config|
   config.app_id = config_json['facebook']['app_id']
   config.app_access_token = config_json['facebook']['app_access_token']
   config.app_secret = config_json['facebook']['app_secret']
   config.access_token = config_json['facebook']['access_token']
end

# Code
counter = 0
@graph = Koala::Facebook::API.new()
previous_messages = Array.new(subscribed.length, 0)
loop do
  subscribed.each_with_index do |fanpage, index|
    begin
      connection = @graph.get_connection(fanpage, 'posts', {
        limit: 1,
        fields: ['message', 'id', 'from', 'type', 'picture', 'link', 'created_time', 'updated_time', 'attachments']
        })
      if connection[0]['id'] != previous_messages[index]
        exchange.publish(connection[0]['message'], :routing_key => queue.name)
        previous_messages[index] = connection[0]['id']
      end
    rescue
      puts "error"
      previous_messages[index] = connection[0]['id']
    end
  end
  # sleep 60
  puts counter
  counter = counter+1
end

bunny_connection.close