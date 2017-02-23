module Main exposing (..)

import Html exposing (Html, div, text, p)
import Html.Attributes exposing (style)
import FancyButton


type alias Model =
    { button : FancyButton.Model
    , isHovered : Bool
    }


model : Model
model =
    { button = FancyButton.model
    , isHovered = False
    }


type Msg
    = SetHover Bool
    | FancyButton (FancyButton.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetHover value ->
            { model | isHovered = value } ! []

        FancyButton msg_ ->
            let
                ( u, c ) =
                    FancyButton.update msg_ model.button
            in
                { model | button = u } ! [ c ]


view : Model -> Html Msg
view model =
    div
        [ style [ ( "margin", "20px" ) ]
        ]
        [ FancyButton.view (FancyButton)
            model.button
            [ FancyButton.onMouseEnter (SetHover True)
            , FancyButton.onMouseLeave (SetHover False)
            ]
            []
            [ text "FancyButton" ]
        , div
            []
            [ text <| "Mouse is over the button: " ++ (toString model.isHovered)
            ]
        , p []
            [ text "Hover over the button" ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


init : ( Model, Cmd Msg )
init =
    model ! []
