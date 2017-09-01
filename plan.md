# Plan for elm Gallows

## Model

```

Model =
{ turns_left: Int
, letters: List Char
, game_state: GameState
, used: List Char
, time??? - add
}
```

TODO: Actions:
Msg =
  LetterSelected
  | TimeLeft
  | TallyReceived


view:
* Main view function
  * Current selection state
  * Gallows
    * svg hangman
  * Guess
    * letters
    * Possible selections keyboard
  
