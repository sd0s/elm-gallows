module Main exposing (main)

import Data.Tally exposing (..)
import Views.GameState exposing (..)
import Views.Gallows exposing (..)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (onClick)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode as JE
import Json.Decode as JD exposing (..)


type Msg
    = Guess String
    | NewGame
    | GetTally
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | JoinChannel
    | ReceiveGameMessage JE.Value


type alias Model =
    { tally : Tally
    , phxSocket : Phoenix.Socket.Socket Msg
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


hangmanChannel : String
hangmanChannel =
    "hangman:game"


charsList : List String
charsList =
    String.split "" "abcdefghijklmnopqrstuvwxyz"


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        --  |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "tally" hangmanChannel ReceiveGameMessage


initModel : Model
initModel =
    { tally = initTally
    , phxSocket = initPhxSocket
    }


init : ( Model, Cmd Msg )
init =
    update JoinChannel initModel



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        GetTally ->
            let
                push_ =
                    Phoenix.Push.init "tally" hangmanChannel

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                ( { model
                    | phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init hangmanChannel
                        |> Phoenix.Channel.onJoin (always (GetTally))

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        NewGame ->
            let
                push_ =
                    Phoenix.Push.init "new_game" hangmanChannel

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                ( { model
                    | phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

        Guess sel ->
            let
                payload =
                    JE.string sel

                push_ =
                    Phoenix.Push.init "make_move" hangmanChannel
                        |> Phoenix.Push.withPayload payload

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                ( { model
                    | phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

        ReceiveGameMessage val ->
            case JD.decodeValue gameMessageDecoder val of
                Ok tally ->
                    ( { model | tally = tally }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )


drawNewButton : Tally -> Html Msg
drawNewButton model =
    div [ class "new-game-button-container" ]
        [ button
            [ class "new-game-button"
            , onClick NewGame
            ]
            [ Html.text "New Game" ]
        ]


correctGuessClass : Tally -> String -> String
correctGuessClass model guess =
    if correctGuess model guess then
        "correct"
    else
        ""


drawTurnsLeft : Tally -> Html Msg
drawTurnsLeft model =
    p [ class "turns-left" ] [ Html.text ("Turns left: " ++ (toString model.turns_left)) ]


onButtonClick : (String -> msg) -> Html.Attribute msg
onButtonClick tagger =
    Html.Events.on "click" (JD.map tagger Html.Events.targetValue)


charsButtons : Tally -> List (Html Msg)
charsButtons model =
    List.map
        (\x ->
            button
                [ class (correctGuessClass model x)
                , onButtonClick Guess
                , HA.value x
                , disabled
                    (alreadyGuessed model x)
                ]
                [ Html.text x ]
        )
        charsList


drawGuessButtons : Tally -> Html Msg
drawGuessButtons model =
    Html.div [ class "guess-buttons" ]
        (charsButtons
            model
        )


drawControls : Tally -> Html Msg
drawControls tally =
    Html.div []
        [ (if game_over tally then
            drawNewButton tally
           else
            drawGuessButtons tally
          )
        ]


view : Model -> Html Msg
view model =
    Html.div [ id "app" ]
        [ drawGameState model.tally
        , div
            [ class "row" ]
            [ div [ class "col-md-4" ]
                [ drawGallows model.tally
                , drawTurnsLeft
                    model.tally
                ]
            , div [ class "col-md-7 offset-md-1" ]
                [ drawStatus model.tally
                , drawControls model.tally
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
