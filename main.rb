require 'telegram/bot'
require 'koala'
require 'json'
require 'net/http'

config_json = JSON.parse(File.read('config'))
token = config_json['telegram']['token']
subscribed = config_json['facebook']['subscribed']

Koala.configure do |config|
   config.app_id = config_json['facebook']['app_id']
   config.app_access_token = config_json['facebook']['app_access_token']
   config.app_secret = config_json['facebook']['app_secret']
   config.access_token = config_json['facebook']['access_token']
end


counter = 0
@graph = Koala::Facebook::API.new()
Telegram::Bot::Client.run(token) do |bot|
  previous_messages = Array.new(subscribed.length, 0)
  loop do
    subscribed.each_with_index do |fanpage, index|
      begin
        connection = @graph.get_connection(fanpage, 'posts', {
          limit: 1,
          fields: ['message', 'id', 'from', 'type', 'picture', 'link', 'created_time', 'updated_time', 'attachments']
          })
        if connection[0]['id'] != previous_messages[index]
          if connection[0]['type'] == 'photo'
            bot.api.send_photo(chat_id: config_json['telegram']['chat_id'], photo: connection[0]['attachments']['data'][0]['media']['image']['src'])
          end
          bot.api.send_message(chat_id: config_json['telegram']['chat_id'], text: connection[0]['message'])
          previous_messages[index] = connection[0]['id']
        end
      rescue
        puts "error"
        previous_messages[index] = connection[0]['id']
      end
    end
    sleep 60
    puts counter
    counter = counter+1
  end
end
