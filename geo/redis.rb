require "redis"

redis = Redis.new()

loop do
  redis.lpush('locations', '{"Id":"teqew","Lat":54.065045,"Lng":22.318790}')
  puts redis.get('teqew')
  # redis.del('teqew')
end