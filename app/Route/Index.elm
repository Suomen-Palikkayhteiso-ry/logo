module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Guide.Colors as Colors
import Guide.Logos as Logos
import Component.ColorSwatch as ColorSwatch
import Component.LogoCard as LogoCard
import Component.SectionHeader as SectionHeader
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StaticPayload)
import Shared
import SiteMeta
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


route : RouteBuilder.StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = SiteMeta.organizationName
        , image =
            { url = Pages.Url.external "https://logo.palikkaharrastajat.fi/logo/horizontal/png/horizontal-full.png"
            , alt = SiteMeta.organizationName
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = SiteMeta.description
        , locale = Nothing
        , title = SiteMeta.siteTitle
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = SiteMeta.siteTitle
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-8 sm:py-12 space-y-14 sm:space-y-20" ]
            [ viewPageHeader
            , viewLogotSection
            , viewVaritSection
            , viewTypografiaSection
            ]
        ]
    }



-- ── Page header ───────────────────────────────────────────────────────────────


viewPageHeader : Html msg
viewPageHeader =
    Html.div [ Attr.class "space-y-2" ]
        [ Html.h1 [ Attr.class "text-2xl sm:text-3xl font-bold text-brand" ]
            [ Html.text "Suomen Palikkaharrastajat ry" ]
        , Html.p [ Attr.class "text-sm sm:text-base text-gray-500" ]
            [ Html.text "Logot, värit ja typografia — visuaalinen yleiskatsaus. Tekninen käyttöohje: "
            , Html.a
                [ Attr.href "/kayttoohje"
                , Attr.class "underline hover:text-brand transition-colors"
                ]
                [ Html.text "Käyttöohje" ]
            , Html.text "."
            ]
        ]



-- ── Logot ─────────────────────────────────────────────────────────────────────


viewLogotSection : Html msg
viewLogotSection =
    Html.section [ Attr.id "logot", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Logot" ]
        , viewSquareLogos
        , viewSquareFullLogos
        , viewHorizontalLogos
        ]


viewSquareLogos : Html msg
viewSquareLogos =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub
            { title = "Neliö"
            , description = Just "Hymyilevä minihahmon pää rakennuspalikoista koottuna. Sopii someen ja sovelluskuvakkeisiin."
            }
        , Html.div [ Attr.class "grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4" ]
            (List.map LogoCard.view Logos.squareVariants)
        ]


viewSquareFullLogos : Html msg
viewSquareFullLogos =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub
            { title = "Neliö tekstillä"
            , description = Just "Hymyilevä logo kahdella tekstirivillä alla. Käytä kun tarvitset täydellisen tunnuksen pystysuuntaisessa asettelussa."
            }
        , Html.div [ Attr.class "grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4" ]
            (List.map LogoCard.view Logos.squareFullVariants)
        ]


viewHorizontalLogos : Html msg
viewHorizontalLogos =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub
            { title = "Vaakasuuntainen"
            , description = Just "Neljä minihahmon päätä vierekkäin. Vaakaversio tekstillä sopii esitteisiin ja nettisivuille."
            }
        , Html.div [ Attr.class "grid grid-cols-1 sm:grid-cols-2 gap-4" ]
            (List.map LogoCard.view Logos.horizontalVariants)
        ]



-- ── Värit ─────────────────────────────────────────────────────────────────────


viewVaritSection : Html msg
viewVaritSection =
    Html.section [ Attr.id "varit", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Värit" ]
        , viewBrandColors
        ]


viewBrandColors : Html msg
viewBrandColors =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub { title = "Merkkivärit", description = Just "Yhdistyksen viralliset päävärit." }
        , Html.div [ Attr.class "grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4" ]
            (List.map
                (\c -> ColorSwatch.view { hex = c.hex, name = c.name, description = c.description, usageTags = c.usage })
                Colors.brandColors
            )
        ]



-- ── Typografia ────────────────────────────────────────────────────────────────


viewTypografiaSection : Html msg
viewTypografiaSection =
    Html.section [ Attr.id "typografia", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Typografia" ]
        , viewFontCard
        , viewWeightSpecimens
        ]


viewFontCard : Html msg
viewFontCard =
    Html.div [ Attr.class "bg-white border border-gray-200 rounded-xl p-4 sm:p-6 space-y-3" ]
        [ Html.div [ Attr.class "flex items-start justify-between flex-wrap gap-4" ]
            [ Html.div []
                [ Html.p [ Attr.class "text-2xl font-bold text-brand" ] [ Html.text "Outfit" ]
                , Html.p [ Attr.class "text-gray-500 mt-0.5" ]
                    [ Html.text "Variable font · paino 100–900 · SIL Open Font License 1.1" ]
                ]
            , Html.a
                [ Attr.href "/fonts/Outfit-VariableFont_wght.ttf"
                , Attr.download ""
                , Attr.class "inline-flex items-center gap-2 bg-brand-yellow text-brand px-4 py-2 rounded font-semibold hover:opacity-90 transition-opacity text-sm"
                ]
                [ Html.text "Lataa TTF" ]
            ]
        , Html.p [ Attr.class "text-gray-600 text-sm" ]
            [ Html.text "Outfit on moderni geometrinen groteski, joka toimii hyvin sekä otsikoissa että leipätekstissä. Google Fonts / SIL OFL." ]
        ]


viewWeightSpecimens : Html msg
viewWeightSpecimens =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub { title = "Painovariannit", description = Nothing }
        , Html.div [ Attr.class "space-y-2" ]
            (List.map
                (\( weight, label ) ->
                    Html.div
                        [ Attr.class "flex items-baseline gap-4 border-l-4 border-brand-yellow pl-4 py-2 bg-white rounded-r" ]
                        [ Html.span
                            [ Attr.class "text-xs text-gray-400 w-20 sm:w-28 flex-shrink-0 font-mono" ]
                            [ Html.text (String.fromInt weight ++ " · " ++ label) ]
                        , Html.span
                            [ Attr.style "font-weight" (String.fromInt weight)
                            , Attr.class "text-lg text-brand"
                            ]
                            [ Html.text "Nopea ruskea kettu hyppää laiskan koiran yli" ]
                        ]
                )
                [ ( 100, "Ohut" )
                , ( 200, "Erittäin ohut" )
                , ( 300, "Kevyt" )
                , ( 400, "Normaali" )
                , ( 500, "Keskipaksu" )
                , ( 600, "Puolilihava" )
                , ( 700, "Lihava" )
                , ( 800, "Erittäin lihava" )
                , ( 900, "Musta" )
                ]
            )
        ]
