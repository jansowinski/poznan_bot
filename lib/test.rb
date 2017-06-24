require "bunny"
require 'json'

class FacebookMemory
  attr_reader :data
  def initialize
    @data = JSON.parse(File.read('../memory/memory.json'))
  end
  def add_user(user_id)
    @data[user_id] = []
    save_data
  end
  def add_fanpage(user_id, fanpage)
    add_user(user_id) if !data.include?(user_id)
    @data[user_id] << fanpage
    save_data
  end
  def save_data
    File.open('../memory/memory.json', 'w+') do |file| 
      file.write(JSON.dump(@data))
    end
  end
end

bunny_connection = Bunny.new
bunny_connection.start

channel = bunny_connection.create_channel
subscribe  = channel.queue("subscribe", :auto_delete => true)
exchange  = channel.default_exchange


# exchange.publish('{"user":35124,"fanpage":"meetjs"}', :routing_key => sub.name)
memory = FacebookMemory.new
subscribe.subscribe do |delivery_info, metadata, payload|
  data = JSON.parse(payload)
  puts payload
  memory.add_fanpage(data['user'], data['fanpage'])
end
loop{}

bunny_connection.close