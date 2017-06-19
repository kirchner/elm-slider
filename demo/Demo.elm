module Demo exposing (main)

import DOM
import Draggable
import Draggable.Events as Draggable
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Slider


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { slider : Slider.State }


initialModel : Model
initialModel =
    { slider = Slider.init 40 }


type Msg
    = SliderMsg Slider.Msg


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SliderMsg sliderMsg ->
            let
                ( newSlider, cmd ) =
                    Slider.update sliderConfig sliderMsg model.slider
            in
            { model | slider = newSlider }
                ! [ cmd ]


sliderConfig : Slider.Config Msg
sliderConfig =
    { min = 0
    , max = 80
    , step = 10
    , lift = SliderMsg
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Slider.subscriptions sliderConfig model.slider


view : Model -> Html Msg
view model =
    Slider.view sliderConfig model.slider



--type alias Model =
--    { value : Int
--    , min : Int
--    , max : Int
--    , step : Int
--    , position : Float
--    , drag : Draggable.State ()
--    , sliderWidth : Int
--    }
--
--
--initialModel : Model
--initialModel =
--    { value = 40
--    , min = 0
--    , max = 90
--    , step = 10
--    , position = 40
--    , drag = Draggable.init
--    , sliderWidth = 0
--    }
--
--
--type Msg
--    = OnDragBy Draggable.Delta
--    | StartDrag (Draggable.Msg ()) Float
--    | DragMsg (Draggable.Msg ())
--
--
--type alias Position =
--    { x : Float
--    , y : Float
--    }
--
--
--dragConfig : Draggable.Config () Msg
--dragConfig =
--    Draggable.basicConfig OnDragBy
--
--
--init : ( Model, Cmd Msg )
--init =
--    ( initialModel, Cmd.none )
--
--
--update : Msg -> Model -> ( Model, Cmd Msg )
--update msg model =
--    case msg of
--        OnDragBy ( dx, _ ) ->
--            let
--                range =
--                    toFloat (model.max - model.min)
--
--                oldRatio =
--                    model.position / range
--
--                deltaRatio =
--                    dx / toFloat model.sliderWidth
--
--                newPosition =
--                    (oldRatio + deltaRatio) * range
--            in
--            { model
--                | position = newPosition
--                , value =
--                    (floor newPosition |> (\p -> p - p % model.step))
--                        |> clamp model.min model.max
--            }
--                ! []
--
--        StartDrag dragMsg currentSliderWith ->
--            { model
--                | sliderWidth = floor currentSliderWith
--            }
--                |> Draggable.update dragConfig dragMsg
--
--        DragMsg dragMsg ->
--            Draggable.update dragConfig dragMsg model
--
--
--subscriptions : Model -> Sub Msg
--subscriptions model =
--    Draggable.subscriptions DragMsg model.drag
--
--
--view : Model -> Html Msg
--view model =
--    let
--        amount =
--            100 * toFloat model.value / toFloat (model.max - model.min)
--    in
--    div
--        [ style
--            [ ( "width", "400px" )
--            , ( "height", "30px" )
--            ]
--        ]
--        [ div
--            [ style
--                [ ( "display", "flex" )
--                , ( "position", "relative" )
--                , ( "margin", "8px" )
--                ]
--            ]
--            [ div
--                [ style
--                    [ ( "width", toString amount ++ "%" )
--                    , ( "height", "2px" )
--                    , ( "background-color", "green" )
--                    ]
--                ]
--                []
--            , div
--                [ style
--                    [ ( "width", toString (100 - amount) ++ "%" )
--                    , ( "height", "2px" )
--                    , ( "background-color", "red" )
--                    ]
--                ]
--                []
--            , div
--                [ style
--                    [ ( "position", "absolute" )
--                    , ( "left", toString amount ++ "%" )
--                    , ( "border-radius", "50%" )
--                    , ( "background-color", "green" )
--                    , ( "width", "16px" )
--                    , ( "height", "16px" )
--                    , ( "align-self", "center" )
--                    , ( "cursor", "pointer" )
--                    , ( "transform", "translate(-8px, 0)" )
--                    ]
--                , Draggable.customMouseTrigger mouseOffsetDecoder StartDrag
--                ]
--                []
--            ]
--        ]
--
--
--mouseOffsetDecoder : Decoder Float
--mouseOffsetDecoder =
--    DOM.target
--        :> DOM.parentElement
--        :> DOM.offsetWidth
--
--
--(:>) : (a -> b) -> a -> b
--(:>) f x =
--    f x
