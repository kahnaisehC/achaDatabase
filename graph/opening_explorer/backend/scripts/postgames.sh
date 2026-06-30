# Source - https://stackoverflow.com/a/6409028
# Posted by Richard J, modified by community. See post 'Timeline' for change history
# Retrieved 2026-06-27, License - CC BY-SA 4.0

curl -i -X POST localhost:8081/game \
  -H "Content-Type: application/x-chess-pgn" \
  --data-binary "@pgn/multisample2.pgn"

