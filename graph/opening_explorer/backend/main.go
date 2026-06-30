package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/freeeve/pgn/v3"
	"github.com/joho/godotenv"
	"github.com/neo4j/neo4j-go-driver/v6/neo4j"
)

const initialPFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -"
const initialFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
const spanishPFEN = "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq -"

func toPFEN(fen string) string {
	splitted := strings.Split(fen, " ")
	return strings.Join(splitted[:len(splitted)-2], " ")
}

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
	query := `MATCH (p:Position{PFEN: $pfen})-[:Occurred]->(g:Game) 
		return g.Event,
		g.Date,
		g.Round,
		g.White,
		g.Black,
		g.Result,
		g.Site
	;`

	result, err := neo4j.ExecuteQuery(context.Background(), cfg.neo4jDB,
		query,
		map[string]any{
			"pfen": pfen,
		},
		neo4j.EagerResultTransformer)
	if err != nil {
		panic(err)
	}

	games := make([]Game, 0, len(result.Records))
	for _, record := range result.Records {

		fmt.Println(record.AsMap())
		game := Game{
			Event:  record.AsMap()["g.Event"].(string),
			Site:   record.AsMap()["g.Site"].(string),
			Date:   record.AsMap()["g.Date"].(string),
			Round:  record.AsMap()["g.Round"].(string),
			White:  record.AsMap()["g.White"].(string),
			Black:  record.AsMap()["g.Black"].(string),
			Result: record.AsMap()["g.Result"].(string),
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
	UCI         string
	NextPFEN    string
	AmountWhite int64
	AmountBlack int64
	AmountDraw  int64
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
	m.UCI AS UCI,
	p2.PFEN AS NextPFEN, 
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

	moves := make([]Move, 0, len(result.Records))

	for _, record := range result.Records {
		move := Move{
			UCI:         record.AsMap()["UCI"].(string),
			NextPFEN:    record.AsMap()["NextPFEN"].(string),
			AmountWhite: record.AsMap()["AmountWhite"].(int64),
			AmountBlack: record.AsMap()["AmountBlack"].(int64),
			AmountDraw:  record.AsMap()["AmountDraw"].(int64),
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

func (cfg *config) handlerPostGames(w http.ResponseWriter, r *http.Request) {

	parser := pgn.GamesFromReader(r.Body)
	ses := cfg.neo4jDB.NewSession(cfg.ctx, neo4j.SessionConfig{})
	defer ses.Close(cfg.ctx)
	_, err := ses.ExecuteWrite(cfg.ctx,
		func(tx neo4j.ManagedTransaction) (any, error) {
			for game := range parser.Games {
				result, err := tx.Run(cfg.ctx,
					`
					MERGE(g:Game{
						Event: $event,
						Site: $site,
						Date: $date,
						Round: $round,
						White: $white,
						Black: $black,
						Result: $result
					})
					RETURN elementId(g) AS id`,
					map[string]any{
						"event":  game.Tags["Event"],
						"site":   game.Tags["Site"],
						"date":   game.Tags["Date"],
						"round":  game.Tags["Round"],
						"white":  game.Tags["White"],
						"black":  game.Tags["Black"],
						"result": game.Tags["Result"],
					})
				if err != nil {
					return nil, err
				}
				rec, err := result.Single(cfg.ctx)
				if err != nil {
					log.Fatal(err)
				}

				id := rec.AsMap()["id"].(string)
				prevPFEN := initialPFEN

				_, err = tx.Run(cfg.ctx,
					`MERGE(p:Position{
						PFEN: $pfen
					})
					MERGE(g:Game) FILTER elementId(g) = $id
					MERGE (p)-[:Occurred{play:$moveCounter}]->(g)
					RETURN * 
					`,
					map[string]any{
						"pfen":        prevPFEN,
						"id":          id,
						"moveCounter": 0,
					})
				if err != nil {
					log.Fatal(err)
				}

				postPFEN := ""
				gameState := pgn.NewStartingPosition()
				for i, move := range game.Moves {
					pgn.MakeMove(gameState, move)
					fmt.Println(gameState.ToFEN())
					fmt.Println(move.String())
					postPFEN = toPFEN(gameState.ToFEN())
					/*fmt.Printf(`
						prevFEN: %s,
						postFEN: %s,
						move: %s,
					`, prevPFEN, postPFEN, move.String())
					*/

					_, err = tx.Run(cfg.ctx,
						`MERGE(p:Position{
						PFEN: $pfen
					})
					MERGE(g:Game) FILTER elementId(g) = $id
					MERGE (p)-[:Occurred{play:$moveCounter}]->(g)
					`,
						map[string]any{
							"pfen":        postPFEN,
							"id":          id,
							"moveCounter": i + 1,
						})
					if err != nil {
						log.Fatal(err)
					}

					_, err = tx.Run(cfg.ctx,
						`MERGE(prev:Position{
							PFEN:$prevpfen
						})
						MERGE(post:Position{
							PFEN:$postpfen
						})
						MERGE (prev)-[:Move{
							UCI: $uci
						}]->(post)
						`,
						map[string]any{
							"prevpfen": prevPFEN,
							"postpfen": postPFEN,
							"uci":      move.String(),
						})
					if err != nil {
						println("its me!")
						log.Fatal(err)
					}
					prevPFEN = postPFEN
				}
			}
			return nil, nil
		})

	if err != nil {
		log.Fatal(err)
	}
	w.WriteHeader(200)
	w.Write([]byte("that works"))
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("couldn't load env")
	}

	neo4jUsr := os.Getenv("NEO4J_USER")
	neo4jUri := os.Getenv("NEO4J_URI")
	neo4jPass := os.Getenv("NEO4J_PASS")

	fmt.Println("trying to connect to", neo4jUri, " ", neo4jUsr)
	driver, err := neo4j.NewDriver(neo4jUri, neo4j.BasicAuth(neo4jUsr, neo4jPass, ""))
	if err != nil {
		log.Fatal("could't connect to neo4j")
	}

	fmt.Println("connected successfully!")

	defer driver.Close(context.Background())

	cfg := config{
		ctx:     context.Background(),
		neo4jDB: driver,
	}

	mux := http.NewServeMux()

	// handle games
	mux.HandleFunc("GET /game", cfg.handlerGetGames)

	// handle moves
	mux.HandleFunc("GET /move", cfg.handlerGetMoves)

	// handle post game
	mux.HandleFunc("POST /game", cfg.handlerPostGames)

	log.Println("Listening on 127.0.0.1:8081")
	log.Fatal(http.ListenAndServe("127.0.0.1:8081", mux))

}
