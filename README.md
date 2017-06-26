# Poznan Bot 💥

Telegram chatbot for telegram power-users from Poznan/Poland.

to make use of it:

- ```git clone https://github.com/iansowinski/poznan_bot.git```
- create bot and get bot token [here](http://telegram.me/BotFather)
- somehow get facebook graph api long-term token [here](developers.facebook.com)
- ```cp config/config config/config.json```
- and paste all required tokens to  ```config/config.json```
- install [RabbitMQ](rabbitmq.com)
- ```sh start.sh```

## Ideas for new functions
  
  - [ ] make filmweb parser city - agnostic
  - [ ] add configuration functions - for setting default city for user
  - [ ] get weather from yr.no (emojis could have some great use here)