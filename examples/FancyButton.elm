module FancyButton
  exposing
    ( Msg
    , Model
    , Property
    , model
    , update
    , view
    , clickCount
    , any
    , on
    , on1
    , onClick
    )

import Html exposing (..)
import Html.Attributes exposing (style)
import Dispatch
import Json.Decode as Json


-- MODEL
{-| Model is opaque as it contains internal state.
 -}
type Model
  = Model
      { focused : Bool
      , clickCount : Int
      }

{-| Initialize the model
 -}
model : Model
model =
  Model
    { focused = False
    , clickCount = 0
    }


{-| Utility function to access some internal state
 -}
clickCount : Model -> Int
clickCount (Model { clickCount }) =
  clickCount



-- Properties

{-| FancyButton only accepts specific
types of properties
 -}
type Property msg
  = Decoder String (Json.Decoder msg)
  | Any (Html.Attribute msg)


{-| Add an `Html.Event` handler
 -}
on : String -> Json.Decoder msg -> Property msg
on =
  Decoder


{-| Add an `Html.Event` handler.

Equivalent to `FancyButton.on "event" (Json.succeed msg)`
 -}
on1 : String -> msg -> Property msg
on1 evt msg =
  on evt (Json.succeed msg)


{-| Add an onClick handler.
 -}
onClick : msg -> Property msg
onClick msg =
  on1 "click" msg


{-| Map from Html.Attribute to a FancyButton.Property
 -}
any : Html.Attribute msg -> Property msg
any =
  Any



-- UPDATE


type Msg msg
  = Click
  | Focus
  | Blur
    {- This message tells Dispatch how to
    convert a list of messages to a single message
     -}
  | Dispatch (List msg)


update : Msg msg -> Model -> ( Model, Cmd msg )
update msg (Model model) =
  case msg of
    {- Forward all the messages produced by handlers with multiple decoders
       attached to them
    -}
    Dispatch msg' ->
      Model model ! [ Dispatch.forward msg' ]

    Click ->
      Model { model | clickCount = model.clickCount + 1 } ! []

    Focus ->
      Model { model | focused = True } ! []

    Blur ->
      Model { model | focused = False } ! []



-- VIEW


view : (Msg msg -> msg) -> Model -> List (Property msg) -> List (Html msg) -> Html msg
view lift (Model model) props content =
  let
    {- We want to perform internal actions on these events
 -}
    defaultListeners =
      [ on1 "mouseenter" (lift Focus)
      , on1 "mouseleave" (lift Blur)
      , on1 "click" (lift Click)
      ]

    {- Setup the Dispatch configuration using user provided events as well as
       our own internal events
    -}
    config =
      List.foldl
        (\prop acc ->
          case prop of
            Decoder evt d ->
              Dispatch.add evt Nothing d acc

            Any attribute ->
              acc
        )
        (Dispatch.setMsg (Dispatch >> lift) Dispatch.defaultConfig)
        (props ++ defaultListeners)

    {- Don't add listeners here,
       they are already added in the config
    -}
    attributes =
      List.map
        (\prop ->
          case prop of
            Decoder _ _ ->
              Nothing

            Any a ->
              Just a
        )
        props
        |> List.filterMap identity
  in
    button
      ([ normal
       , if model.focused then
          focused
         else
          style []
       ]
        ++ attributes
        ++ (Dispatch.toAttributes config)
      )
      content



-- STYLES


normal : Attribute a
normal =
  style
    [ ( "display", "inline-block" )
    , ( "margin", "0 10px 0 0" )
    , ( "padding", "15px 15px" )
    , ( "font-size", "16px" )
    , ( "line-height", "1.8" )
    , ( "appearance", "none" )
    , ( "box-shadow", "none" )
    , ( "border-radius", "0" )
    ]


focused : Attribute a
focused =
  style
    [ ( "background-color", "#b6d8e4" )
    , ( "text-shadow", "-1px 1px #27496d" )
    , ( "outline", "none" )
    ]
