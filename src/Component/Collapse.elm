module Component.Collapse exposing (view)

import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr


{-| A CSS-only collapsible section using <details>/<summary>.
For JS-driven collapse, manage visibility with Elm model state instead.
-}
view : { summary : Html msg, body : List (Html msg), open : Bool } -> Html msg
view config =
    Html.details
        (Attr.class "group"
            :: (if config.open then
                    [ Attr.attribute "open" "" ]

                else
                    []
               )
        )
        [ Html.summary
            [ Attr.class "flex cursor-pointer items-center gap-2 select-none list-none py-2 font-medium text-brand hover:text-brand/80" ]
            [ Html.span [ Attr.class "transition-transform group-open:rotate-90 leading-none" ]
                [ FeatherIcons.chevronRight
                    |> FeatherIcons.withSize 16
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                ]
            , config.summary
            ]
        , Html.div [ Attr.class "pt-2 pb-4" ] config.body
        ]
