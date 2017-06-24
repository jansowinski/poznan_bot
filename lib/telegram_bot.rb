require "bunny"
require 'telegram/bot'
require 'json'
# require 'net/http'
require './meteo'
require './cinema'
# RabbitMQ config
bunny_connection = Bunny.new
bunny_connection.start

ch = bunny_connection.create_channel
queue  = ch.queue("facebook_posts", :auto_delete => true)
exchange  = ch.default_exchange

# Telegram config
config_json = JSON.parse(File.read('config'))
token = config_json['telegram']['token']

# Libs
weather = Meteo.new
cinema = Cinema.new

#code
Telegram::Bot::Client.run(token) do |bot|
  queue.subscribe do |delivery_info, metadata, payload|
    bot.api.send_message(chat_id: config_json['telegram']['chat_id'], text: payload)
  end
  bot.listen do |message|
    case message.text
    when '/pogoda'
      bot.api.send_message(chat_id: message.chat.id, text: weather.get)
    when '/kino'
      cinema.seanses("wszystkie", 0).each do |cinema|
        bot.api.send_message(chat_id: message.chat.id, text: cinema)
      end
    end
  end
end

bunny_connection.close