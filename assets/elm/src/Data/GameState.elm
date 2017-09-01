module Data.GameState exposing (..)

import Json.Decode as JD exposing (..)


type GameState
    = Initializing
    | Won
    | Lost
    | GoodGuess
    | BadGuess
    | AlreadyUsed


type alias GameStateMsg =
    { game_state : GameState
    , class : String
    , msg : String
    }


stateMessages : List GameStateMsg
stateMessages =
    [ { game_state = Initializing, class = "info", msg = "Let's play!" }
    , { game_state = Won, class = "success", msg = "You won!" }
    , { game_state = Lost, class = "danger", msg = "You lost!" }
    , { game_state = GoodGuess, class = "success", msg = "Good guess!" }
    , { game_state = BadGuess, class = "warning", msg = "Bad guess!" }
    , { game_state = AlreadyUsed, class = "info", msg = "You already guessed that" }
    ]


gameStateInfo : GameState -> Maybe GameStateMsg
gameStateInfo game_state =
    List.filter (\item -> item.game_state == game_state) stateMessages
        |> List.head


gameStateDecoder : JD.Decoder GameState
gameStateDecoder =
    JD.map toGameState JD.string


toGameState : String -> GameState
toGameState str =
    case str of
        "initializing" ->
            Initializing

        "won" ->
            Won

        "lost" ->
            Lost

        "good_guess" ->
            GoodGuess

        "bad_guess" ->
            BadGuess

        "already_guessed" ->
            AlreadyUsed

        _ ->
            Lost
