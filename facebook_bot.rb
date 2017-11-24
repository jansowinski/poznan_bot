require 'sinatra'
require 'json'
require './lib/meteo'
require './lib/cinema'
require './lib/busses'
require 'time'
require 'net/http'
require 'uri'
require 'addressable/uri'
require 'open-uri'

#   / _|_   _ _ __   ___| |_(_) ___  _ __  ___    
#  | |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __|   
#  |  _| |_| | | | | (__| |_| | (_) | | | \__ \   
#  |_|  \__,_|_| |_|\___|\__|__\___/|_| |_|___/  

# def handle_cinema(bot, message)
#   $cinema.seanses("wszystkie", 0).each do |cinema|
#     bot.api.send_message(#       chat_id: message.chat.id, 
#       chat_id: message.chat.id, 
#       text: cinema)
#   end
# end

def send_message(text, recipient)
  request_body = {
    "recipient" => {
    "id" => recipient
   },
   "message" => {
     "text" => text
    }
  }
  puts $config['access_token']
  puts request_body
  uri = URI.parse("https://graph.facebook.com/v2.8/me/messages?access_token=#{$config['access_token']}")
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true
  request = Net::HTTP::Post.new(uri.path)
  request.body = JSON.dump(request_body)
  response = https.request(request)
  puts response.body
end


#  __   ____ _ _ __(_) __ _| |__ | | ___ ___ 
#  \ \ / / _` | '__| |/ _` | '_ \| |/ _ / __|
#   \ V | (_| | |  | | (_| | |_) | |  __\__ \
#    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___|___/


puts "Loading Config..."
$config = JSON.parse(File.read('./config/config.json'))['facebook']
set :bind, $config['server']['ip']
set :port, $config['server']['port']

# $cinema = Cinema.new

#                   _         _                   
#   _ __ ___   __ _(_)_ __   | | ___   ___  _ __  
#  | '_ ` _ \ / _` | | '_ \  | |/ _ \ / _ \| '_ \ 
#  | | | | | | (_| | | | | | | | (_) | (_) | |_) |
#  |_| |_| |_|\__,_|_|_| |_| |_|\___/ \___/| .__/ 
#                                          |_|    
# get '/facebook_webhook' do
#   params['hub.challenge']
# end
post '/facebook_webhook' do
  data = JSON.parse(request.body.read)
  text = "hello world"
  recipient = data['entry'][0]['messaging'][0]['sender']['id']
  send_message(text, recipient)
  return 200
end
