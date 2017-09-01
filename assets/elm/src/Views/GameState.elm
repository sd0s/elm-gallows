module Views.GameState exposing (drawStatus, drawGameState)

import Data.Tally exposing (Tally)
import Data.GameState exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


drawStatus : Tally -> Html msg
drawStatus model =
    p []
        [ span [ class "so-far" ]
            [ Html.text
                (model.letters
                    |> String.join " "
                )
            ]
        ]


drawGameState : Tally -> Html msg
drawGameState model =
    let
        state =
            gameStateInfo model.game_state
    in
        Html.div
            [ class
                (case state of
                    Just state ->
                        "alert alert-" ++ state.class

                    Nothing ->
                        ""
                )
            ]
            [ Html.text
                (case state of
                    Just state ->
                        state.msg

                    Nothing ->
                        ""
                )
            ]
