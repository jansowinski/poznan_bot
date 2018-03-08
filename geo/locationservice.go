package main

import (
	"./geohelper"
	"encoding/json"
	"github.com/go-redis/redis"
)

type Message struct {
	Id  string
	Lat float64
	Lng float64
}

type MessageOut struct {
	Powiat      string
	Gmina       string
	Wojewodztwo string
}

func main() {
	polska := geohelper.Create()
	client := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})
	for {
		var val string
		var err error
		var message Message
		val, err = client.RPop("locations").Result()
		if err == nil {
			json.Unmarshal([]byte(val), &message)
			locationInfo := geohelper.GetInfo(polska, message.Lat, message.Lng)
			messageOut := MessageOut{
				locationInfo.Powiat,
				locationInfo.Gmina,
				locationInfo.Wojewodztwo,
			}
			toSend, _ := json.Marshal(messageOut)
			_, err = client.Set(message.Id, toSend, 0).Result()
		}
	}
}
