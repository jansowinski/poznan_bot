package main

import (
	"./geohelper"
	"encoding/json"
	"fmt"
	"github.com/go-redis/redis"
	// "log"
)

type Message struct {
	Id  string
	Lat float64
	Lng float64
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
			fmt.Println(geohelper.GetName(voievodships, message.Lat, message.Lng))
			fmt.Println(geohelper.GetName(shires, message.Lat, message.Lng))
		}
	}
}
