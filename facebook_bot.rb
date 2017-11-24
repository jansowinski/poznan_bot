# require 'sinatra'
require 'json'
require './lib/meteo'
require './lib/cinema'
require './lib/busses'
require 'time'
require 'facebook/messenger'

#    ___
#   / _|_   _ _ __   ___| |_(_) ___  _ __  ___    
#  | |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __|   
#  |  _| |_| | | | | (__| |_| | (_) | | | \__ \   
#  |_|  \__,_|_| |_|\___|\__|__\___/|_| |_|___/  

def handle_cinemas(message)
  cinemas = []
  $cinema.seanses('wszystkie', 0).each do |cinema|
    cinemas << cinema
  end
  cinemas.each do |cinema|
    message.reply(text: cinema)
  end
end

#  __   ____ _ _ __(_) __ _| |__ | | ___ ___ 
#  \ \ / / _` | '__| |/ _` | '_ \| |/ _ / __|
#   \ V | (_| | |  | | (_| | |_) | |  __\__ \
#    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___|___/

include Facebook::Messenger
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

$cinema = Cinema.new
$time_table = TimeTable.new

#                   _         _                   
#   _ __ ___   __ _(_)_ __   | | ___   ___  _ __  
#  | '_ ` _ \ / _` | | '_ \  | |/ _ \ / _ \| '_ \ 
#  | | | | | | (_| | | | | | | | (_) | (_) | |_) |
#  |_| |_| |_|\__,_|_|_| |_| |_|\___/ \___/| .__/ 
#                                          |_|    

Bot.on :message do |message|
  puts message.attachments 
  if message.text.include?('kina')
    handle_cinemas(message)
  end
end
