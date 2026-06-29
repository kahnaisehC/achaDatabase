package main

import (
	"context"
	"fmt"
	"log"

	"github.com/neo4j/neo4j-go-driver/v6/neo4j"
)

func initConfig(neo4jUsr, neo4jPass, neo4jUri string) config {

	fmt.Println("trying to connect to", neo4jUri, " ", neo4jUsr)
	driver, err := neo4j.NewDriver(neo4jUri, neo4j.BasicAuth(neo4jUsr, neo4jPass, ""))
	if err != nil {
		log.Fatal("could't connect to the db")
	}
	fmt.Println("connected successfully!")

	return config{
		neo4jDB: driver,
	}
}

type config struct {
	neo4jDB neo4j.Driver
	ctx     context.Context
}
