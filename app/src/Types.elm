module Types exposing (..)

import Xml exposing (Value)


type Uri
    = Uri String


type XmlInstance
    = XmlInstance Value
