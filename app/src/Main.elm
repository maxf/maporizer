module Main exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (src)
import Http
import Xml exposing (Value(..))
import Xml.Encode exposing (null)
import Xml.Decode exposing (decode)
import Xml.Query exposing (tags)


---- MODEL ----


type alias Model =
    { mapSourceUrl : Uri
    , mapSource : XmlInstance
    , message : String
    }


initialModel : Model
initialModel =
    Model
        (Uri "http://localhost:3000/montpelier.xml")
        (XmlInstance (StrNode ""))
        ""


init : ( Model, Cmd Msg )
init =
    ( { initialModel | message = "Fetching XML" }
    , fetchSourceMap initialModel.mapSourceUrl
    )



---- UPDATE ----


type Msg
    = SourceMapLoaded (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SourceMapLoaded (Ok string) ->
            let
                xml : Value
                xml =
                    string
                        |> decode
                        |> Result.toMaybe
                        |> Maybe.withDefault null
            in
                ( { model | mapSource = XmlInstance xml, message = "OK" }
                , Cmd.none
                )

        SourceMapLoaded (Err err) ->
            ( { model | message = "Error" }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        , h2 [] [ text model.message ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }



---- MISC ----


fetchSourceMap : Uri -> Cmd Msg
fetchSourceMap (Uri url) =
    Http.send SourceMapLoaded (Http.getString url)


naturalThings : Value -> List Value
naturalThings xml =
    tags "way" xml
