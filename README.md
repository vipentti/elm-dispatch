# elm-dispatch

Makes it easier to dispatch multiple messages from a single `Html.Event`. 

The library was developed for the purpose of allowing UI component libraries, such as [elm-mdl](http://package.elm-lang.org/packages/debois/elm-mdl/latest), to have stateful components that perform some internal actions on `Html.Events` such as `click`, `focus` and `blur` while still allowing users to have their own event handlers for those particular events as well.


## Install

```shell
elm package install vipentti/elm-dispatch
```

## Examples 

To see the library in action see [elm-mdl](http://package.elm-lang.org/packages/debois/elm-mdl/latest) specifically [Material.Options.Internal](https://github.com/debois/elm-mdl/blob/master/src/Material/Options/Internal.elm). 

An example may also be found in `examples/`

## Basic Usage

To add support for Dispatch:

Add a dispatch message to your `Msg`
```elm
type Msg
    = ...
    | Dispatch (List Msg)
    ...
```

Add call to `Dispatch.forward` in update
```elm
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
    ...

    Dispatch messages ->
        model ! [ Dispatch.forward messages ]

    ...
```

Add a call to `Dispatch.on` on an element
```elm
view : Model -> Html Msg
view model =
    let
        decoders =
            [ Json.Decode.succeed Click
            , Json.Decode.succeed PerformAnalytics
            , Json.Decode.map SomeMessage
                (Json.at ["target", "offsetWidth"] Json.float) ]
    in
        Html.button
            [ Dispatch.on "click" Dispatch decoders ]
            [ text "Button" ]
```

For more advanced use see `examples/`. 