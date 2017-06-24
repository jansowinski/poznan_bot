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

# Code
Telegram::Bot::Client.run(token) do |bot|
  queue.subscribe do |delivery_info, metadata, payload|
    bot.api.send_message(chat_id: config_json['telegram']['chat_id'], text: payload)
  end
  bot.listen do |message|
    case message.text
    when /\/pogoda/
      bot.api.send_message(chat_id: message.chat.id, text: weather.get)
    when /\/kino/
      cinema.seanses("wszystkie", 0).each do |cinema|
        bot.api.send_message(chat_id: message.chat.id, text: cinema)
      end
      # theatres = []
      # date = 0
      # args = message.text.split(' ') - ["/kino"]
      # args.map(&:downcase)
      # args.each do |argument|
      #   theatres << argument if cinema.theatres.include?(argument)
      # end
      # if args.include?("jutro")
      #   date = 1
      # elsif args.include?("pojutrze")
      #   date = 2
      # end
      # if theatres.length == 0
      #   cinema.seanses("wszystkie", date).each do |cinema|
      #     bot.api.send_message(chat_id: message.chat.id, text: cinema)
      #   end
      # else
      #   theatres.each do |theatre|
      #     cinema.seanses(theatre, 0).each do |cinema|
      #       bot.api.send_message(chat_id: message.chat.id, text: cinema)
      #     end
      #   end
      # end
    end
  end
end

bunny_connection.close