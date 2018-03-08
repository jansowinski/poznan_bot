# Poznan Bot 💥

Telegram chatbot for telegram power-users from Poznan/Poland.

to make use of it:

- install docker
- ```git clone https://github.com/iansowinski/poznan_bot.git```
- create bot and get bot token [here](http://telegram.me/BotFather)
- ```cp bot/config/config bot/config/config.json```
- and paste all required tokens to  ```bot/config/config.json```
- ```docker-compose up```

Facebook:

run:

```
export ACCESS_TOKEN='blahblahblab'
export APP_SECRET='blahblahblab'
export VERIFY_TOKEN='12345|blahblahblab'
```

and then 

```rackup -p 5050```
