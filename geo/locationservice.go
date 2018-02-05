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
	Powiat string
	Wojewodztwo string
}

func main() {
	shires, voievodships := geohelper.Create()
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
			voievodshipName := geohelper.GetName(voievodships, message.Lat, message.Lng)
			shireName := geohelper.GetName(shires, message.Lat, message.Lng)
			messageOut := MessageOut{shireName, voievodshipName}
			toSend, _ := json.Marshal(messageOut)
			_, err = client.Set(message.Id, toSend, 0).Result()
		}
	}
}
