cd lib
rabbitmq-server &
nohup ruby facebook_reader.rb &
nohup ruby telegram_bot.rb &