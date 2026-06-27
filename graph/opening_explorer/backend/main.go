package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	"github.com/neo4j/neo4j-go-driver/v6/neo4j"
)

const initialPFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -"

func (cfg *config) handlerGetMoves(w http.ResponseWriter, r *http.Request) {

}
func (cfg *config) handlerGetGames(w http.ResponseWriter, r *http.Request) {

}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("couldn't load env")
	}

	neo4jUsr := os.Getenv("NEO4J_USER")
	neo4jUri := os.Getenv("NEO4J_URI")
	neo4jPass := os.Getenv("NEO4J_PASS")

	query := `MATCH (p:Position{PFEN: "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq -"})-[:Occurred]->(g:Game) return g.White, g.Black;`

	fmt.Println("trying to connect to", neo4jUri, " ", neo4jUsr)
	driver, err := neo4j.NewDriver(neo4jUri, neo4j.BasicAuth(neo4jUsr, neo4jPass, ""))
	if err != nil {
		log.Fatal("could't connect to the db")
	}
	fmt.Println("connected successfully!")

	defer driver.Close(context.Background())

	cfg := config{
		ctx:     context.Background(),
		neo4jDB: driver,
	}
	_ = cfg

	result, err := neo4j.ExecuteQuery(context.Background(), driver,
		query,
		nil,
		neo4j.EagerResultTransformer,
	)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("the following games played the spanish opening")
	for _, record := range result.Records {
		_, _, err := neo4j.GetRecordValue[string](record, "g.Black")
		if err != nil {
			log.Fatal(fmt.Errorf("could not find node b"))
		}
		fmt.Println(record)

	}

	mux := http.NewServeMux()

	// handle games
	mux.HandleFunc("GET /game", cfg.handlerGetGames)

	// handle moves
	mux.HandleFunc("GET /move", cfg.handlerGetMoves)

	log.Println("Listening on :8081")
	log.Fatal(http.ListenAndServe(":8081", mux))
}
