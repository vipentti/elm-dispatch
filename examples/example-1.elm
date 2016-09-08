module Main exposing (..)

import Html exposing (Html, div, text)
import Html.App as App
import Html.Attributes exposing (style)
import Dict exposing (Dict)
import FancyButton


main : Program Never
main =
  App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = always Sub.none
    }


init : ( Model, Cmd Msg )
init =
  model ! []


type alias Model =
  { buttons : Dict Int FancyButton.Model
  , activeButton : Int
  , lastClick : Int
  }


model : Model
model =
  { buttons = Dict.empty
  , activeButton = -1
  , lastClick = -1
  }


get : Int -> Dict Int FancyButton.Model -> FancyButton.Model
get idx dict =
  Dict.get idx dict
    |> Maybe.withDefault FancyButton.model


button :
  Int
  -> { a | buttons : Dict Int FancyButton.Model }
  -> Html Msg
button idx model =
  let
    buttonModel =
      (get idx model.buttons)

    clicks =
      FancyButton.clickCount buttonModel
        |> toString
  in
    FancyButton.view (FancyButton idx)
      buttonModel
      [ FancyButton.on1 "mouseenter" (MouseEnter idx)
      , FancyButton.on1 "mouseleave" (MouseLeave idx)
      , FancyButton.onClick (Click idx)
      ]
      [ text <| "FancyButton " ++ (toString idx) ++ " (Internal Click Count " ++ clicks ++ ")" ]


type Msg
  = Click Int
  | MouseEnter Int
  | MouseLeave Int
  | FancyButton Int (FancyButton.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Click idx ->
      { model | lastClick = idx } ! []

    MouseEnter index ->
      { model | activeButton = index } ! []

    MouseLeave _ ->
      { model | activeButton = -1 } ! []

    FancyButton index msg' ->
      let
        ( u, c ) =
          FancyButton.update msg' (get index model.buttons)
      in
        { model | buttons = Dict.insert index u model.buttons } ! [ c ]


view : Model -> Html Msg
view model =
  div
    [ style [ ( "margin", "20px" ) ]
    ]
    [ button 0 model
    , button 1 model
    , button 2 model
    , div
        []
        [ if model.activeButton >= 0 then
            text ("Mouse is over button: " ++ toString model.activeButton)
          else
            text "\xA0" -- Maps to &nbsp;
        ]
    , div
        []
        [ if model.lastClick >= 0 then
            text ("Last button clicked: " ++ toString model.lastClick)
          else
            text "\xA0" -- Maps to &nbsp;
        ]
    ]
