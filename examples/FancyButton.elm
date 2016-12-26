module FancyButton
    exposing
        ( Msg
        , Model
        , Handler
        , model
        , update
        , view
        , onMouseEnter
        , onMouseLeave
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
        { hovered : Bool
        , hoverCount : Int
        }


{-| Initialize the model
-}
model : Model
model =
    Model
        { hovered = False
        , hoverCount = 0
        }



-- Options


{-| An event handler for FancyButton
-}
type Handler msg
    = Handler String (Json.Decoder msg)


{-|
-}
onMouseEnter : msg -> Handler msg
onMouseEnter msg =
    Handler "mouseenter" (Json.succeed msg)


{-|
-}
onMouseLeave : msg -> Handler msg
onMouseLeave msg =
    Handler "mouseleave" (Json.succeed msg)



-- UPDATE


type Msg msg
    = Hover
    | Leave {- Batch a list of messages for `Dispatch` -}
    | Batch (List msg)


update : Msg msg -> Model -> ( Model, Cmd msg )
update msg (Model model) =
    case msg of
        {- Forward all the messages produced by event-handlers
           with multiple decoders attached to them
        -}
        Batch msg_ ->
            Model model ! [ Dispatch.forward msg_ ]

        Hover ->
            Model
                { model
                    | hovered = True
                    , hoverCount = model.hoverCount + 1
                }
                ! []

        Leave ->
            Model { model | hovered = False } ! []



-- VIEW


view : (Msg msg -> msg) -> Model -> List (Handler msg) -> List (Attribute msg) -> List (Html msg) -> Html msg
view lift (Model model) handlers attributes content =
    let
        {- We want to perform internal actions on these events -}
        defaultListeners =
            [ onMouseEnter (lift Hover)
            , onMouseLeave (lift Leave)
            ]

        {- Setup the Dispatch configuration using user-provided event-handlers
           plus our own internal event-handlers
        -}
        config =
            List.foldl
                (\handler acc ->
                    case handler of
                        Handler evt d ->
                            Dispatch.add evt Nothing d acc
                )
                (Dispatch.setMsg (Batch >> lift) Dispatch.defaultConfig)
                (handlers ++ defaultListeners)
    in
        button
            ([ normal
             , if model.hovered then
                hovered model.hoverCount
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


hovered : Int -> Attribute a
hovered count =
    let
        colors =
            [ ( "background-color", "#b6d8e4" )
            , ( "background-color", "#e4a8a8" )
            , ( "background-color", "#f6a8e4" )
            ]

        nrColors =
            List.length colors

        color =
            List.drop (count % nrColors) colors
                |> List.head
                |> Maybe.withDefault ( "background-color", "#b6d8e4" )
    in
        style
            [ color
            , ( "outline", "none" )
            ]
