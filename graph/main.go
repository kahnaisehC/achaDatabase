package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/freeeve/pgn/v3"
	"github.com/joho/godotenv"
	"github.com/neo4j/neo4j-go-driver/v6/neo4j"
)

func main() {

	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	ctx := context.Background()
	dbUri := os.Getenv("NEO4J_URI")
	neo4jUser := os.Getenv("NEO4J_USER")
	neo4jPass := os.Getenv("NEO4J_PASS")
	driver, err := neo4j.NewDriver(
		dbUri,
		neo4j.BasicAuth(neo4jUser, neo4jPass, ""))
	defer driver.Close(ctx)

	err = driver.VerifyConnectivity(ctx)
	if err != nil {
		panic(err)
	}
	fmt.Println("Connection to neo4j established.")

	// Parse any PGN file (handles .zst compression automatically)

	idx := 0
	for game := range pgn.Games("../png/Candidates 2018.pgn").Games {
		prevFEN := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -"
		query := ""
		query += fmt.Sprintf(`
		MERGE (p%d:Position{
			PFEN: "%s"
		})
		MERGE(g:Game{
			Event: "%s",
			Site: "%s",
			Date: "%s",
			Round: "%s",
			White: "%s",
			Black: "%s",
			Result: "%s"
		})<-[:Occurred]-(p%d)`,
			idx,
			prevFEN,
			game.Tags["Event"],
			game.Tags["Site"],
			game.Tags["Date"],
			game.Tags["Round"],
			game.Tags["White"],
			game.Tags["Black"],
			game.Tags["Result"],
			idx,
		)

		// Replay the game
		gs := pgn.NewStartingPosition()
		for _, move := range game.Moves {
			idx++
			pgn.MakeMove(gs, move)
			fen := strings.Split(gs.ToFEN(), " ")
			pfen := strings.Join(fen[:len(fen)-2], " ")
			_ = pfen

			query += fmt.Sprintf(`
			MERGE (g)<-[:Occurred]-(p%d:Position{
				PFEN: "%s"
			})`, idx, pfen)

			query += fmt.Sprintf(`
			MERGE
			(p%d)-[:Move{
				From: %d,
				To: %d
			}]->(p%d)
			`,
				idx-1,
				move.From,
				move.To,
				idx,
			)

			prevFEN = pfen
		}
		_, err := neo4j.ExecuteQuery(context.Background(), driver,
			query,
			nil,
			neo4j.EagerResultTransformer,
		)
		if err != nil {
			log.Fatal(err)
		} else {
			println("added successfully!")
			println(gs.ToFEN())
		}
	}
}
