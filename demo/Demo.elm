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
