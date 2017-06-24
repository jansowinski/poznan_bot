require "bunny"
require 'telegram/bot'
require 'json'
require 'net/http'

# RabbitMQ config
bunny_connection = Bunny.new
bunny_connection.start

ch = bunny_connection.create_channel
queue  = ch.queue("facebook_posts", :auto_delete => true)
exchange  = ch.default_exchange

# Telegram config
config_json = JSON.parse(File.read('config'))
token = config_json['telegram']['token']

#code
Telegram::Bot::Client.run(token) do |bot|
  queue.subscribe do |delivery_info, metadata, payload|
    bot.api.send_message(chat_id: config_json['telegram']['chat_id'], text: payload)
  end
  loop {}
end

bunny_connection.close