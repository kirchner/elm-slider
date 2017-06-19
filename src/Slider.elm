module Slider
    exposing
        ( Config
        , Msg
        , State
        , init
        , subscriptions
        , update
        , view
        )

import DOM
import Draggable
import Draggable.Events as Draggable
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode exposing (Decoder)


type alias Config msg =
    { min : Int
    , max : Int
    , step : Int
    , lift : Msg -> msg
    , attrs :
        { left : List (Html.Attribute msg)
        , right : List (Html.Attribute msg)
        , nob : List (Html.Attribute msg)
        , nobPressed : List (Html.Attribute msg)
        }
    , label : Int -> Html msg
    }


type State
    = State
        { value : Int
        , position : Float
        , drag : Draggable.State ()
        , sliderWidth : Int
        , mouseDown : Bool
        }


init : Int -> State
init value =
    State
        { value = value
        , position = toFloat value
        , drag = Draggable.init
        , sliderWidth = 0 -- make this Nothing ??
        , mouseDown = False
        }


type Msg
    = OnDragBy Draggable.Delta
    | StartDrag (Draggable.Msg ()) Float
    | DragMsg (Draggable.Msg ())
    | OnMouseDown ()
    | OnDragEnd
    | OnClick ()


update : Config msg -> Msg -> State -> ( State, Cmd msg )
update config msg (State state) =
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
            State
                { state
                    | position = newPosition
                    , value =
                        round newPosition
                            |> (\p -> p - p % config.step)
                            |> clamp config.min config.max
                }
                ! []

        OnMouseDown _ ->
            State
                { state | mouseDown = True }
                ! []

        OnDragEnd ->
            State
                { state | mouseDown = False }
                ! []

        OnClick _ ->
            State
                { state | mouseDown = False }
                ! []

        StartDrag dragMsg currentSliderWith ->
            let
                ( newState, dragCmd ) =
                    { state
                        | sliderWidth = floor currentSliderWith
                    }
                        |> Draggable.update dragConfig dragMsg
            in
            ( State newState, Cmd.map config.lift dragCmd )

        DragMsg dragMsg ->
            let
                ( newState, dragCmd ) =
                    Draggable.update dragConfig dragMsg state
            in
            ( State newState, Cmd.map config.lift dragCmd )


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.customConfig
        [ Draggable.onDragBy OnDragBy
        , Draggable.onMouseDown OnMouseDown
        , Draggable.onDragEnd OnDragEnd
        , Draggable.onClick OnClick
        ]


subscriptions : Config msg -> State -> Sub msg
subscriptions config (State state) =
    Draggable.subscriptions DragMsg state.drag
        |> Sub.map config.lift


view : Config msg -> State -> Html msg
view config (State state) =
    let
        amount =
            100 * toFloat state.value / toFloat (config.max - config.min)
    in
    div
        [ style
            [ ( "display", "flex" )
            , ( "position", "relative" )
            , ( "margin", "8px" )
            ]
        ]
        [ div
            ([ style [ ( "width", toString amount ++ "%" ) ] ]
                ++ config.attrs.left
            )
            []
        , div
            ([ style [ ( "width", toString (100 - amount) ++ "%" ) ] ]
                ++ config.attrs.right
            )
            []
        , div
            (List.filterMap identity
                [ Just
                    [ style
                        [ ( "position", "absolute" )
                        , ( "left", toString amount ++ "%" )
                        , ( "align-self", "center" )
                        , ( "cursor", "pointer" )
                        , ( "transform", "translate(-8px, 0)" )
                        ]
                    , Draggable.customMouseTrigger mouseOffsetDecoder StartDrag
                        |> Html.Attributes.map config.lift
                    ]
                , Just config.attrs.nob
                , if state.mouseDown then
                    Just config.attrs.nobPressed
                  else
                    Nothing
                ]
                |> List.concat
            )
            []
        , div
            [ style
                [ ( "position", "absolute" )
                , ( "left", toString amount ++ "%" )
                , ( "align-self", "center" )
                , ( "transform", "translate(-8px, 24px)" )
                ]
            ]
            [ config.label state.value ]
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
