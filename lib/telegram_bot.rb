require "bunny"
require 'telegram/bot'
require 'json'
require './meteo'
require './cinema'

# RabbitMQ config
bunny_connection = Bunny.new
bunny_connection.start

channel = bunny_connection.create_channel
queue  = channel.queue("facebook_posts", :auto_delete => true)
subscribe  = channel.queue("subscription_queue", :auto_delete => true)
exchange  = channel.default_exchange

# Telegram config
config_json = JSON.parse(File.read('../config/config.json'))
token = config_json['telegram']['token']

# Libs
weather = Meteo.new
cinema = Cinema.new

# Code
Telegram::Bot::Client.run(token) do |bot|
  queue.subscribe do |delivery_info, metadata, payload|
    data = JSON.parse(payload)
    bot.api.send_message(chat_id: data['chat_id'], text: data['message'])
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
    when /\/subscribe/
      fanpages = message.text.split(" ") - ["/subscribe"]
      fanpages.each do |fanpage|
        data = {"type"=>"subscribe",
                "user_id"=>"#{message.chat.id}",
                "fanpage"=>fanpage}
        subscribe.publish(JSON.dump(data), :routing_key => subscribe.name)
      end
      bot.api.send_message(chat_id: message.chat.id, text: "success!")
    when /\/unsubscribe/
      fanpages = message.text.split(" ") - ["/unsubscribe"]
      if fanpages.length > 0
        fanpages.each do |fanpage|
          data = {"type"=>"unsubscribe",
                  "user_id"=>"#{message.chat.id}",
                  "fanpage"=>fanpage}
          subscribe.publish(JSON.dump(data), :routing_key => subscribe.name)
        end
      else
        data = {"type"=>"unsubscribe",
                "user_id"=>"#{message.chat.id}",
                "fanpage"=>"all"}
        subscribe.publish(JSON.dump(data), :routing_key => subscribe.name)
      end
    end
  end
end

bunny_connection.close