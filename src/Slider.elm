module Slider exposing (..)

import DOM
import Draggable
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode exposing (Decoder)


type alias Config msg =
    { min : Int
    , max : Int
    , step : Int
    , lift : Msg -> msg
    }


type alias State =
    { value : Int
    , position : Float
    , drag : Draggable.State ()
    , sliderWidth : Int
    }


init : Int -> State
init value =
    { value = value
    , position = toFloat value
    , drag = Draggable.init
    , sliderWidth = 0 -- make this Nothing ??
    }


type Msg
    = OnDragBy Draggable.Delta
    | StartDrag (Draggable.Msg ()) Float
    | DragMsg (Draggable.Msg ())


update : Config msg -> Msg -> State -> ( State, Cmd msg )
update config msg state =
    case msg of
        OnDragBy ( dx, _ ) ->
            let
                range =
                    toFloat (config.max - config.min)

                oldRatio =
                    state.position / range

                deltaRatio =
                    dx / toFloat state.sliderWidth

                newPosition =
                    (oldRatio + deltaRatio) * range
            in
            { state
                | position = newPosition
                , value =
                    floor newPosition
                        |> (\p -> p - p % config.step)
                        |> clamp config.min config.max
            }
                ! []

        StartDrag dragMsg currentSliderWith ->
            let
                ( newState, dragCmd ) =
                    { state
                        | sliderWidth = floor currentSliderWith
                    }
                        |> Draggable.update dragConfig dragMsg
            in
            ( newState, Cmd.map config.lift dragCmd )

        DragMsg dragMsg ->
            let
                ( newState, dragCmd ) =
                    Draggable.update dragConfig dragMsg state
            in
            ( newState, Cmd.map config.lift dragCmd )


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig OnDragBy


subscriptions : Config msg -> State -> Sub msg
subscriptions config state =
    Draggable.subscriptions DragMsg state.drag
        |> Sub.map config.lift


view : Config msg -> State -> Html msg
view config state =
    let
        amount =
            100 * toFloat state.value / toFloat (config.max - config.min)
    in
    div
        [ style
            [ ( "width", "400px" )
            , ( "height", "30px" )
            ]
        ]
        [ div
            [ style
                [ ( "display", "flex" )
                , ( "position", "relative" )
                , ( "margin", "8px" )
                ]
            ]
            [ div
                [ style
                    [ ( "width", toString amount ++ "%" )
                    , ( "height", "2px" )
                    , ( "background-color", "green" )
                    ]
                ]
                []
            , div
                [ style
                    [ ( "width", toString (100 - amount) ++ "%" )
                    , ( "height", "2px" )
                    , ( "background-color", "red" )
                    ]
                ]
                []
            , div
                [ style
                    [ ( "position", "absolute" )
                    , ( "left", toString amount ++ "%" )
                    , ( "border-radius", "50%" )
                    , ( "background-color", "green" )
                    , ( "width", "16px" )
                    , ( "height", "16px" )
                    , ( "align-self", "center" )
                    , ( "cursor", "pointer" )
                    , ( "transform", "translate(-8px, 0)" )
                    ]
                , Draggable.customMouseTrigger mouseOffsetDecoder StartDrag
                    |> Html.Attributes.map config.lift
                ]
                []
            ]
        ]


mouseOffsetDecoder : Decoder Float
mouseOffsetDecoder =
    DOM.target
        :> DOM.parentElement
        :> DOM.offsetWidth


infixr 5 :>
(:>) : (a -> b) -> a -> b
(:>) f x =
    f x
