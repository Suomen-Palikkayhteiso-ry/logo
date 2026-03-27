module Component.CloseButton exposing (view)

import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view : { onClick : msg, label : String } -> Html msg
view config =
    Html.button
        [ Attr.type_ "button"
        , Attr.class "inline-flex items-center justify-center w-11 h-11 rounded text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2"
        , Attr.attribute "aria-label" config.label
        , Events.onClick config.onClick
        ]
        [ FeatherIcons.x |> FeatherIcons.withSize 18 |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
        ]
