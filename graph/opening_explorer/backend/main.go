package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	"github.com/neo4j/neo4j-go-driver/v6/neo4j"
)

const initialPFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -"

type Game struct {
	Event  string
	Site   string
	Date   string
	Round  string
	White  string
	Black  string
	Result string
	Moves  string
}

func (cfg *config) handlerGetGames(w http.ResponseWriter, r *http.Request) {
	pfen := r.URL.Query().Get("pfen")
	if pfen == "" {
		pfen = initialPFEN
	}
	query := `MATCH (p:Position{PFEN: $pfen})-[:Occurred]->(g:Game) return g;`

	result, err := neo4j.ExecuteQuery(context.Background(), cfg.neo4jDB,
		query,
		map[string]any{
			"pfen": pfen,
		},
		neo4j.EagerResultTransformer)
	if err != nil {
		panic(err)
	}

	// Loop through results and do something with them

	games := make([]Game, 0, len(result.Records))
	for _, record := range result.Records {
		game := Game{
			Event:  record.AsMap()["event"].(string),
			Site:   record.AsMap()["site"].(string),
			Date:   record.AsMap()["date"].(string),
			Round:  record.AsMap()["round"].(string),
			White:  record.AsMap()["white"].(string),
			Black:  record.AsMap()["black"].(string),
			Result: record.AsMap()["result"].(string),
			Moves:  record.AsMap()["moves"].(string),
		}
		games = append(games, game)
	}

	println(games)

	w.Header().Set("Content-Type", "application/json")
	gameData, err := json.Marshal(games)
	if err != nil {
		log.Fatal("couldnt marshal games")
	}
	w.Write(gameData)
}

type Move struct {
	SAN         string
	NextPFEN    string
	AmountWhite int
	AmountBlack int
	AmountDraw  int
}

func (cfg *config) handlerGetMoves(w http.ResponseWriter, r *http.Request) {
	pfen := r.URL.Query().Get("pfen")
	if pfen == "" {
		pfen = initialPFEN
	}

	query := `
	MATCH (p:Position{PFEN: $pfen})
	-[m:Move]->
	(p2:Position) 
	RETURN
	m.SAN AS SAN,
	p2.PFEN AS PFEN, 
	COUNT{(p2)-[:Occurred]->(g:Game) WHERE g.Result = "1/2-1/2"} AS AmountDraw, 
	COUNT{(p2)-[:Occurred]->(g:Game) WHERE g.Result = "0-1"} AS AmountBlack, 
	COUNT{(p2)-[:Occurred]->(g:Game) WHERE g.Result = "1-0"} AS AmountWhite;`

	result, err := neo4j.ExecuteQuery(context.Background(), cfg.neo4jDB,
		query,
		map[string]any{
			"pfen": pfen,
		},
		neo4j.EagerResultTransformer)
	if err != nil {
		panic(err)
	}

	// Loop through results and do something with them

	moves := make([]Move, 0, len(result.Records))

	for _, record := range result.Records {
		move := Move{
			SAN:         record.AsMap()["SAN"].(string),
			NextPFEN:    record.AsMap()["NextFEN"].(string),
			AmountWhite: record.AsMap()["AmountWhite"].(int),
			AmountBlack: record.AsMap()["AmountBlack"].(int),
			AmountDraw:  record.AsMap()["AmountDraw"].(int),
		}
		moves = append(moves, move)
	}

	w.Header().Set("Content-Type", "application/json")
	gameData, err := json.Marshal(moves)
	if err != nil {
		log.Fatal("couldnt marshal moves")
	}
	w.Write(gameData)

}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("couldn't load env")
	}

	neo4jUsr := os.Getenv("NEO4J_USER")
	neo4jUri := os.Getenv("NEO4J_URI")
	neo4jPass := os.Getenv("NEO4J_PASS")

	query := `MATCH (p:Position{PFEN: "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq -"})-[m:Move]->(p2:Position) return m;`

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
