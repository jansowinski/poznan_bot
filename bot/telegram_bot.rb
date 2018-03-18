require 'telegram/bot'
require 'json'
require './lib/meteo'
require './lib/cinema'
require './lib/busses'
require 'time'
require 'securerandom'

#   / _|_   _ _ __   ___| |_(_) ___  _ __  ___    
#  | |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __|   
#  |  _| |_| | | | | (__| |_| | (_) | | | \__ \   
#  |_|  \__,_|_| |_|\___|\__|__\___/|_| |_|___/  

def handle_location(bot, message)
   buttons = [
    Telegram::Bot::Types::InlineKeyboardButton.new(
      text: 'przystanek', 
      callback_data: {
        'type' => 'bus',
        'lat' => message.location.latitude, 
        'lng' => message.location.longitude
      }.to_json
    ),
    Telegram::Bot::Types::InlineKeyboardButton.new(
      text: 'pogoda', 
      callback_data: {
        'type' => 'weather',
        'lat' => message.location.latitude, 
        'lng' => message.location.longitude
      }.to_json
    ),
    Telegram::Bot::Types::InlineKeyboardButton.new(
      text: 'rowery miejskie', 
      callback_data: {
        'type' => 'bikes',
        'lat' => message.location.latitude, 
        'lng' => message.location.longitude
      }.to_json
    ),
  ]
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
  bot.api.send_message(
    chat_id: message.chat.id, 
    text: 'Co chcesz uzyskać?', 
    reply_markup: markup)
end

def handle_cinema(bot, message)
  date = 0
  args = message.text.split(' ') - ["/kino"]
  args.map(&:downcase)
  if args.include?("jutro")
    date = 1
    bot.api.send_message(
      chat_id: message.chat.id, 
      text: "*REPERTUAR NA JUTRO*", 
      parse_mode: 'Markdown')
  elsif args.include?("pojutrze")
    date = 2
    bot.api.send_message(
      chat_id: message.chat.id, 
      text: "*REPERTUAR NA POJUTRZE*", 
      parse_mode: 'Markdown')
  else
    bot.api.send_message(
      chat_id: message.chat.id, 
      text: "*REPERTUAR NA DZIŚ*", 
      parse_mode: 'Markdown')
  end
  $cinema.seanses("wszystkie", date).each do |cinema|
    bot.api.send_message(
      chat_id: message.chat.id, 
      text: cinema)
  end
end

def handle_google_maps_link(bot, message)
    location_from_link = /(!?@)(\d*.\d*),(\d*.\d*)/.match(message.text)
  if location_from_link != nil
    lat = location_from_link[2]
    lng = location_from_link[3]
    if lng != nil and lat != nil
      location = Location.new(
        location_from_link[2].to_f, 
        location_from_link[3].to_f)
      forecast = $weather.get_image(location)
      if forecast.class != Array
        bot.api.send_message(
          chat_id: message.chat.id, 
          text: forecast)
      else
        bot.api.send_photo(
          chat_id: message.chat.id, 
          photo: forecast[1], 
          caption: forecast[0])
      end
    end
  end
end

def handle_weather(bot, message)
  location = Location.new(52.469656, 16.953536)
  forecast = $weather.get_image(location)
  if forecast.class != Array
    bot.api.send_message(
      chat_id: message.chat.id,
      text: forecast)
  else
    bot.api.send_photo(
      chat_id: message.chat.id,
      photo: forecast[1],
      caption: forecast[0])
  end
end

def handle_movies(bot, message)
  all_movies = $movies.movies
  bot.api.send_message(
    chat_id: message.chat.id, 
    text: all_movies, 
    parse_mode: 'Markdown')
end

def handle_movie(bot, message)
  searched_movie = message.text.split(" ") - ["/film"]
  searched_movie = searched_movie.join(" ")
  if searched_movie.gsub(" ","").length > 0
    found = $movies.seanses(searched_movie)
    if found.length > 0
      bot.api.send_message(
        chat_id: message.chat.id, 
        text: found, 
        parse_mode: 'Markdown')
    else
      bot.api.send_message(
        chat_id: message.chat.id, 
        text: "Niestety, nie znalazłem twojego filmu #{$emoji.failure}")
    end
  end
end

def handle_callback(bot, message)
  order = JSON.parse(message.data)
  if order['type'] == 'bus'
    bot_message = $time_table.from_coordinates(
      order['lat'], 
      order['lng'])
    bot.api.send_message(
      chat_id: message.from.id, 
      text: bot_message)
  elsif order['type'] == 'bikes'
    key = SecureRandom.hex(10)
    request = { 
      'id' => key,
      'lat' => order['lat'],
      'lng' => order['lng']
    }
    $redis.rpush('rowery', request.to_json)
    anwser = $redis.get(key)
    while anwser == nil
      anwser = $redis.get(key)
    end
    $redis.del(key)
    bot.api.send_message(
      chat_id: message.from.id, 
      text: anwser)
  elsif order['type'] == 'weather'
    location = Location.new(order['lat'], order['lng'])
    begin
      forecast = $weather.get_image(location)
      if forecast.class != Array
        bot.api.send_message(
          chat_id: message.from.id, 
          text: forecast)
      else
        bot.api.send_photo(
          chat_id: message.from.id, 
          photo: forecast[1], 
          caption: forecast[0])
      end
    end
  end
end

def check_for_updates
  now = Time.now
  if now.day > $last_update_time.day or now.month > $last_update_time.month
    $last_update_time = now
    movie.update
  end
end

def log_users(message)
  $cache["#{message.chat.id}"] = {
    "id"=>"#{message.from.id}",
    "first_name"=>"#{message.from.first_name}",
    "last_name"=>"#{message.from.last_name}",
    "username"=>"#{message.from.username}"}
  File.open('./cache/users.json', 'w+') do |file| 
    file.write(JSON.dump($cache))
  end
end

#  __   ____ _ _ __(_) __ _| |__ | | ___ ___ 
#  \ \ / / _` | '__| |/ _` | '_ \| |/ _ / __|
#   \ V | (_| | |  | | (_| | |_) | |  __\__ \
#    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___|___/

timestamp_start = Time.now
$stdout.puts "Loading Config..."
token = JSON.parse(File.read('./config/config.json'))['telegram']['token']
$stdout.puts "Initializing objects..."
$weather = Meteo.new
$cinema = Cinema.new
$movies = Movies.new
$emoji = Emoji.new
$time_table = TimeTable.new
$last_update_time = Time.now
$stdout.puts "Loading cache..."
$cache = JSON.parse(File.read('./cache/users.json'))
$stdout.puts "starting main loop!"
$redis = Redis.new(host: 'redis', port: 6379)
timestamp_stop = Time.now
$stdout.puts "Startup time: #{timestamp_stop - timestamp_start} s."

#                   _         _                   
#   _ __ ___   __ _(_)_ __   | | ___   ___  _ __  
#  | '_ ` _ \ / _` | | '_ \  | |/ _ \ / _ \| '_ \ 
#  | | | | | | (_| | | | | | | | (_) | (_) | |_) |
#  |_| |_| |_|\__,_|_|_| |_| |_|\___/ \___/| .__/ 
#                                          |_|    

Telegram::Bot::Client.run(token) do |bot|
  check_for_updates
  begin
    bot.listen do |message|
      if message.class != Telegram::Bot::Types::CallbackQuery and !$cache.include?(message.chat.id)
        log_users(message)
      end
      case message
      when Telegram::Bot::Types::CallbackQuery
        handle_callback(bot, message)
      when Telegram::Bot::Types::Message
        if message.location != nil
          handle_location(bot, message)
        end
        case message.text
        when '/start', '/help'
          bot.api.send_message(chat_id: message.chat.id, text: "*POGODA:*\nwyślij swoją lokalizację a otrzymasz obecną prognozę z meteo\n/pogoda w Poznaniu\n\n*REPERTUARY:*\n/kino - repertuar na dziś\n/kino jutro - repertuar na jutro\n/kino pojutrze - repertuar na pojutrze\n/film <nazwa filmu> - bot postara się znaleźć repertuar twojego filmu. Fragment tytułu wystarczy\n/filmy - lista filmów granych dzisiaj w Poznaniu\n\n*POWIADOMIENIA Z FANPAGE*\n/subscribe <nazwa / link fanpage> - np. /subscribe Reuters albo /subscribe https://m.facebook.com/Reuters/\n/unsubscribe <nazwa / link fanpage> - analogicznie do /subscribe\n/unsubscribe - odsubskrybuj wszystkie fanpage", parse_mode: 'Markdown')
        when /google(.*?)maps/, /maps(.*?)google/
          handle_google_maps_link(bot, message)
        when /\/pogoda/
          handle_weather(bot, message)
        when /\/kino/
          handle_cinema(bot, message)
        when '/filmy'
          handle_movies(bot, message)
        when /\/film/
          handle_movie(bot, message)
        end
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    if e.error_code.to_s == "502"
      $stdout.puts "Telegram 502 error"
    end
    retry
  end
end
