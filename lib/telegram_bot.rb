require 'telegram/bot'
require 'json'
require './meteo'
require './cinema'
require 'time'
require 'thread'

puts "Loading Config..."
# Telegram config
config_json = JSON.parse(File.read('../config/config.json'))
token = config_json['telegram']['token']

puts "Initializing objects..."
# Objects
weather = Meteo.new
cinema = Cinema.new
movie = Movie.new
emoji = Emoji.new

puts "Loading cache..."
# Cache
cache = JSON.parse(File.read('../cache/users.json'))

# Code
puts "starting threads"
threads = []
mutex = Mutex.new

threads << Thread.new do
  loop do
    now = Time.now
    if now.hour == 2 and now.min == 1
      mutex.synchronize do
        movie.update
      end
    end
    sleep 40
  end
end

threads << Thread.new do
  puts "starting main loop!"
  loop do
    begin
      Telegram::Bot::Client.run(token) do |bot|
        bot.listen do |message|
          if !cache.include?(message.chat.id)
            cache["#{message.chat.id}"] = {
                                            "id"=>"#{message.from.id}",
                                            "first_name"=>"#{message.from.first_name}",
                                            "last_name"=>"#{message.from.last_name}",
                                            "username"=>"#{message.from.username}"
                                          }
            File.open('../cache/users.json', 'w+') do |file| 
              file.write(JSON.dump(cache))
            end
          end
          if message.location != nil
            location = Location.new(message.location.latitude, message.location.longitude)
            begin
              forecast = weather.get_image(location)
              if forecast.class != Array
                bot.api.send_message(chat_id: message.chat.id, text: forecast)
              else
                bot.api.send_photo(chat_id: message.chat.id, photo: forecast[1], caption: forecast[0])
              end
            end
          end
          case message.text
          when '/start', '/help'
            bot.api.send_message(chat_id: message.chat.id, text: "*POGODA:*\nwyślij swoją lokalizację a otrzymasz obecną prognozę z meteo\n/pogoda w Poznaniu\n\n*REPERTUARY:*\n/kino - repertuar na dziś\n/kino jutro - repertuar na jutro\n/kino pojutrze - repertuar na pojutrze\n/film <nazwa filmu> - bot postara się znaleźć repertuar twojego filmu. Fragment tytułu wystarczy\n/filmy - lista filmów granych dzisiaj w Poznaniu\n\n*POWIADOMIENIA Z FANPAGE*\n/subscribe <nazwa / link fanpage> - np. /subscribe Reuters albo /subscribe https://m.facebook.com/Reuters/\n/unsubscribe <nazwa / link fanpage> - analogicznie do /subscribe\n/unsubscribe - odsubskrybuj wszystkie fanpage", parse_mode: 'Markdown')
          when /google(.*?)maps/, /maps(.*?)google/
            location_from_link = /(!?@)(\d*.\d*),(\d*.\d*)/.match(message.text)
            if location_from_link != nil
              lat = location_from_link[2]
              lng = location_from_link[3]
              if lng != nil and lat != nil
                location = Location.new(location_from_link[2].to_f, location_from_link[3].to_f)
                forecast = weather.get_image(location)
                if forecast.class != Array
                  bot.api.send_message(chat_id: message.chat.id, text: forecast)
                else
                  bot.api.send_photo(chat_id: message.chat.id, photo: forecast[1], caption: forecast[0])
                end
              end
            end
          when /\/pogoda/
            location = Location.new(52.469656, 16.953536)
            forecast = weather.get_image(location)
            bot.api.send_photo(chat_id: message.chat.id, photo: forecast[1], caption: forecast[0])
            # bot.api.send_message(chat_id: message.chat.id, text: "send location")
            # bot.listen do |m|
            #   if m.location != nil
            #     bot.api.send_message(chat_id: message.chat.id, text: "#{m.location.latitude}, #{m.location.longitude}")
            #     break
            #   end
            # end
          when /\/kino/
            date = 0
            args = message.text.split(' ') - ["/kino"]
            args.map(&:downcase)
            if args.include?("jutro")
              date = 1
              bot.api.send_message(chat_id: message.chat.id, text: "*REPERTUAR NA JUTRO*", parse_mode: 'Markdown')
            elsif args.include?("pojutrze")
              date = 2
              bot.api.send_message(chat_id: message.chat.id, text: "*REPERTUAR NA POJUTRZE*", parse_mode: 'Markdown')
            else

              bot.api.send_message(chat_id: message.chat.id, text: "*REPERTUAR NA DZIŚ*", parse_mode: 'Markdown')
            end
            cinema.seanses("wszystkie", date).each do |cinema|
              bot.api.send_message(chat_id: message.chat.id, text: cinema)
            end
          when '/filmy'
            all_movies = mutex.synchronize{movie.movies}
            bot.api.send_message(chat_id: message.chat.id, text: all_movies, parse_mode: 'Markdown')
          when /\/film/
            searched_movie = message.text.split(" ") - ["/film"]
            searched_movie = searched_movie.join(" ")
            if searched_movie.gsub(" ","").length > 0
              found = mutex.synchronize{movie.seanses(searched_movie)}
              if found.length > 0
                bot.api.send_message(chat_id: message.chat.id, text: found, parse_mode: 'Markdown')
              else
                bot.api.send_message(chat_id: message.chat.id, text: "Niestety, nie znalazłem twojego filmu #{emoji.failure}")
              end
            end
          when /\/subscribe/
            fanpages = message.text.split(" ") - ["/subscribe"]
            fanpages.each do |fanpage|
              fanpage = fanpage[/com\/(.*)/,1].gsub(/\/(.*)/, '') if fanpage.include?('http')
              data = {"type"=>"subscribe",
                      "user_id"=>"#{message.chat.id}",
                      "fanpage"=>fanpage}
              subscribe.publish(JSON.dump(data), :routing_key => subscribe.name)
              bot.api.send_message(chat_id: message.chat.id, text: "sukces! Zasubskrybowano #{fanpage}! #{emoji.success}")
            end
            bot.api.send_message(chat_id: message.chat.id, text: "Ups! Zapomniałeś podać fanpage #{emoji.error}") if fanpages.length == 0
          when /\/unsubscribe/
            fanpages = message.text.split(" ") - ["/unsubscribe"]
            if fanpages.length > 0
              fanpages.each do |fanpage|
                fanpage = fanpage[/com\/(.*)/,1].gsub(/\/(.*)/, '') if fanpage.include?('http')
                data = {"type"=>"unsubscribe",
                        "user_id"=>"#{message.chat.id}",
                        "fanpage"=>fanpage}
                subscribe.publish(JSON.dump(data), :routing_key => subscribe.name)
                bot.api.send_message(chat_id: message.chat.id, text: "Sukces! Odsubskrybowano #{fanpage}! #{emoji.success}")
              end
            else
              data = {"type"=>"unsubscribe",
                      "user_id"=>"#{message.chat.id}",
                      "fanpage"=>"all"}
              subscribe.publish(JSON.dump(data), :routing_key => subscribe.name)
            end
            bot.api.send_message(chat_id: message.chat.id, text: "Sukces! Odsubskrybowano wszystko! #{emoji.success}")
          end
        end
      end
    rescue => error
      puts error.backtrace
    end
  end
end

threads.each{|thread| thread.join}