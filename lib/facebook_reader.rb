require "bunny"
require 'koala'
require 'json'

# RabbitMQ config
bunny_connection = Bunny.new
bunny_connection.start

channel = bunny_connection.create_channel
queue  = channel.queue("facebook_posts", :auto_delete => true)
subscription = channel.queue("subscription_queue", :auto_delete => true)
exchange  = channel.default_exchange

# Facebook config
config_json = JSON.parse(File.read('../config/config.json'))
Koala.configure do |config|
   config.app_id = config_json['facebook']['app_id']
   config.app_access_token = config_json['facebook']['app_access_token']
   config.app_secret = config_json['facebook']['app_secret']
   config.access_token = config_json['facebook']['access_token']
end

# Data class
class FacebookMemory
  attr_reader :data
  def initialize
    @data = JSON.parse(File.read('../memory/memory.json'))
    return nil
  end
  def add_user(user_id)
    @data[user_id] = {}
    save_data
    return nil
  end
  def unsubscribe_user(user_id)
    @data.delete(user_id)
    save_data
    return nil
  end
  def add_fanpage(user_id, fanpage)
    add_user(user_id) if !data.include?(user_id)
    @data[user_id][fanpage] = ""
    save_data
    return nil
  end
  def unsubscribe_fanpage(user_id, fanpage)
    if fanpage == "all"
      unsubscribe_user(user_id)
    else
      @data[user_id].delete(fanpage)
    end
    save_data
    return nil
  end
  def add_last_post(user_id, fanpage, post_id)
    @data[user_id.to_s][fanpage] = post_id.to_s
    save_data
    return nil
  end
  def save_data
    File.open('../memory/memory.json', 'w+') do |file| 
      file.write(JSON.dump(@data))
    end
    return nil
  end
end


# app config
memory = FacebookMemory.new
graph = Koala::Facebook::API.new()

subscription.subscribe do |delivery_info, metadata, payload|
  request = JSON.parse(payload)
  case request['type']
  when "subscribe"
    memory.add_fanpage(request['user_id'], request['fanpage'])
  when "unsubscribe"
    memory.unsubscribe_fanpage(request['user_id'], request['fanpage'])
  end
end

loop do
  memory.data.clone.each do |user_key, fanpages|
    fanpages.clone.each do |fanpage_key, last_message|
      begin
        connection = graph.get_connection(fanpage_key, 'posts', {
          limit: 1,
          fields: ['message', 'id', 'from', 'type', 'picture', 'link', 'created_time', 'updated_time', 'attachments']
          })
        if connection[0]['id'] != memory.data[user_key][fanpage_key]
          data = {"chat_id"=>user_key, "message"=>connection[0]['message']}
          exchange.publish(JSON.dump(data), :routing_key => queue.name)
          memory.add_last_post(user_key, fanpage_key, connection[0]['id'])
        end
      rescue
        # rescue code
      end
    end
  end
end

bunny_connection.close