# elm-gallows

  elm-gallows is an Elm UI for the Hangman game created in the excellent Elixir for Programmers course by Dave Thomas. elm-gallows assumes that you have developed or downloaded the Hangman game mentioned in the course (https://github.com/pragdave/e4p-code/tree/180-code-channels).    

## Getting it running
  * Install the repository as a sibling directory to hangman directory (elm-gallows assumes that Hangman is located as a sibling. Please update path for hangman in mix.exs if that is not the case)    
  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Install Elm dependencies with `cd elm && elm package install -y`
  * Navigate up to the elm_gallows directory (`cd ../..`)
  * Start Phoenix endpoint with `mix phx.server`

Browse to [`localhost:4000`](http://localhost:4000) to open the Hangman game.
