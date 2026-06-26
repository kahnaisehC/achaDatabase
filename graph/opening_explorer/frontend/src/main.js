// NOTE: this example uses the chess.js library:
// https://github.com/jhlywa/chess.js
// import Chess from "chess.js"
// import Chessboard2 from "chessboard2.js"

const game = new Chess()

const boardConfig = {
  draggable: true,
  position: game.fen(),
  onDragStart,
  onDrop
  // onSnapEnd
}
const board = Chessboard2('myBoard', boardConfig)
const statusEl = document.getElementById('gameStatus')
const fenEl = document.getElementById('gameFEN')
const movesEl = document.getElementById('movesEl')
const childrenMovesEl = document.getElementById("childrenMoves")
const gamesEl = document.getElementById("games")

const moves = []
let moveIndex = 0;

const state = {
  game,
  board,
  statusEl,
  fenEl,
  movesEl,
  gamesEl,
  moves,
  moveIndex,
  childrenMovesEl,
}

updateStatus()

async function getMoves(fen){
  let moves = state.game.moves({verbose: true})
  for(let i = 0; i < moves.length; i++){
    moves[i].whitePercent = 40;
    moves[i].blackPercent = 40;
    moves[i].drawPercent = 20;
    moves[i].amountGames = 100;
  }
  return moves
}

//event string
//site string
//date string
//round string
//white string
//black string
//result string


async function renderGames(fen, gamesEl){
  gamesEl.replaceChildren()
  let games = await getGames(fen);
  try{
    games = await getGames(fen)
  }
  catch(e){
    throw e
  }
  console.log(games)

  for(let i = 0; i < games.length; i++){
    let game = games[i]
    let gameEl = document.createElement("p")

    gameEl.innerText = 
      game.white + " vs " +
      game.black + ": " +
      game.result

    gameEl.addEventListener("click", (e)=>{
      alert("going to game!")
    })
    gamesEl.append(gameEl)
  }

}

async function renderChildrenMoves(fen, childrenMovesEl){
  childrenMovesEl.replaceChildren()
  let moves;
  try{
    moves = await getMoves(fen)
  }
  catch(e){
    throw e
  }
  for(let i = 0; i < moves.length; i++){
    let move = moves[i]
    let moveEl = document.createElement("p")
    moveEl.innerText = 
      move.san + " " + 
      move.amountGames + " " +
      move.blackPercent + " " + 
      move.drawPercent + " " +
      move.whitePercent

    moveEl.addEventListener("click", (e)=>{
        game.move(move)
        if(state.moves.length === state.moveIndex){
          state.moves.push(move)
          state.moveIndex++
        }else if(state.moves[state.moveIndex].from === move.from && state.moves[state.moveIndex].to === move.to){
          state.moveIndex++
        }else{
          state.moves.splice(state.moveIndex, Infinity, move)
          state.moveIndex++
        }
        board.fen(game.fen(), () => {
          updateStatus()
        })
      })

    childrenMovesEl.append(moveEl)
  }
}

async function getGames(fen){
  let data = [];
  await fetch("src/games.json")
    .then((res) => res.json())
    .then((games) => {
      for(let game of games){
        let pgnGame = {
          event: "",
          site: "",
          date: "",
          round: "",
          white: game.players.white.user.name,
          black: game.players.black.user.name,
          result: game.winner
        }
        data.push(pgnGame)
      }

     })
    .catch((e) => console.error(e));
  console.log(data)

  return data
}

function onDragStart (dragStartEvt) {
  // do not pick up pieces if the game is over
  if (game.game_over()) return false

  // only pick up pieces for the side to move
  if (game.turn() === 'w' && !isWhitePiece(dragStartEvt.piece)) return false
  if (game.turn() === 'b' && !isBlackPiece(dragStartEvt.piece)) return false

  // what moves are available to from this square?
  const legalMoves = game.moves({
    square: dragStartEvt.square,
    verbose: true
  })

  // place Circles on the possible target squares
  legalMoves.forEach((move) => {
    board.addCircle(move.to)
  })
}

function isWhitePiece (piece) { return /^w/.test(piece) }
function isBlackPiece (piece) { return /^b/.test(piece) }

function onDrop (dropEvt) {
  // see if the move is legal
  const move = game.move({
    from: dropEvt.source,
    to: dropEvt.target,
    promotion: 'q' // NOTE: always promote to a queen for example simplicity
  })
  // remove all Circles from the board
  board.clearCircles()

  // make the move if it is legal
  if (move) {
    // update the board position with the new game position, then update status DOM elements
    board.fen(game.fen(), () => {
      updateStatus()
    })
    if(moves.length === state.moveIndex){
      moves.push(move)
      state.moveIndex++
    }else if(moves[state.moveIndex].from === move.from && moves[state.moveIndex].to === move.to){
      state.moveIndex++
    }else{
      moves.splice(state.moveIndex, Infinity, move)
      state.moveIndex++
    }

  } else {
    return 'snapback'
  }
}

// update the board position after the piece snap
// for castling, en passant, pawn promotion
// function onSnapEnd () {
//   board.position(game.fen())
// }

// update DOM elements with the current game status
function updateStatus () {
  let statusHTML = ''
  const whosTurn = game.turn() === 'w' ? 'White' : 'Black'

  if (!game.game_over()) {
    if (game.in_check()) statusHTML = whosTurn + ' is in check! '
    statusHTML = statusHTML + whosTurn + ' to move.'
  } else if (game.in_checkmate() && game.turn() === 'w') {
    statusHTML = 'Game over: white is in checkmate. Black wins!'
  } else if (game.in_checkmate() && game.turn() === 'b') {
    statusHTML = 'Game over: black is in checkmate. White wins!'
  } else if (game.in_stalemate() && game.turn() === 'w') {
    statusHTML = 'Game is drawn. White is stalemated.'
  } else if (game.in_stalemate() && game.turn() === 'b') {
    statusHTML = 'Game is drawn. Black is stalemated.'
  } else if (game.in_threefold_repetition()) {
    statusHTML = 'Game is drawn by threefold repetition rule.'
  } else if (game.insufficient_material()) {
    statusHTML = 'Game is drawn by insufficient material.'
  } else if (game.in_draw()) {
    statusHTML = 'Game is drawn by fifty-move rule.'
  }

  statusEl.innerHTML = statusHTML
  fenEl.innerHTML = game.fen()

  renderChildrenMoves(game.fen(), state.childrenMovesEl)
  renderGames(game.fen(), state.gamesEl)
  renderMoveArray(state.moves, movesEl)
}

function renderMoveArray(moves, movesEl){
  movesEl.replaceChildren()
  for(let i = 0; i < moves.length; i++){
    let move = moves[i]
    let moveEl = document.createElement("a")
    if(move.color === "w"){
      moveEl.innerText = "" + (i/2+1) + ". "
    }
    moveEl.innerText += move.san + " "
    moveEl.setAttribute("data-fen", move.after)
    moveEl.setAttribute("data-index", i)
    moveEl.setAttribute("active", false)
    if(i === state.moveIndex-1){
      moveEl.setAttribute("active", true)
    }else{
      moveEl.addEventListener("click", (e)=>{
        let moveIdx = i
        if(moveIdx < state.moveIndex-1){
          while(state.moveIndex-1 !== moveIdx){
            game.undo();
            state.moveIndex--;
          }
        }else{
          while(state.moveIndex <= moveIdx){
            game.move(state.moves[state.moveIndex])
            state.moveIndex++
          }
        }
        board.fen(game.fen(), () => {
          updateStatus()
        })
      })
    }

    movesEl.append(moveEl)
  }
}

previous.addEventListener("click", function (e) {
  if(!game.undo())return
  state.moveIndex--
  board.fen(game.fen(), () => {
    updateStatus()
  })
});

next.addEventListener("click", function(e){
  if(state.moveIndex >= moves.length)return
  game.move(moves[state.moveIndex])
  state.moveIndex++

  board.fen(game.fen(), () => {
    updateStatus()
  })
});



