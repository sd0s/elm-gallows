module Data.Tally exposing (..)

import Data.GameState exposing (..)
import Json.Decode as JD exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional)


type alias Tally =
    { turns_left : Int
    , letters : List String
    , game_state : GameState
    , letters_used : List String
    }


initTally : Tally
initTally =
    { turns_left = 7
    , letters = [ "_", "_", "_" ]
    , game_state = Initializing
    , letters_used = []
    }


alreadyGuessed : Tally -> String -> Bool
alreadyGuessed model guess =
    List.any (\x -> x == guess) model.letters_used


correctGuess : Tally -> String -> Bool
correctGuess model guess =
    alreadyGuessed model guess && (List.member guess model.letters)


game_over : Tally -> Bool
game_over model =
    model.game_state == Won || model.game_state == Lost


gameMessageDecoder : JD.Decoder Tally
gameMessageDecoder =
    decode Tally
        |> required "turns_left" int
        |> required "letters" (list JD.string)
        |> required "game_state" gameStateDecoder
        |> required "used" (list JD.string)
