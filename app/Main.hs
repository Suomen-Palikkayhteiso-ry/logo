module Main where

import Brand.Colors (darkBg)
import Brand.ElmGen (generateBrandModule)
import Brand.Json (generateDesignGuide)
import Brand.JsonLd (generateJsonLd)
import Control.Monad (forM_, when)
import Logo.Animate (assembleGif, assembleWebp)
import Logo.BrickLayout
    ( BrickLayout (..)
    , layoutToSvg
    , layoutsToHorizontalSvg
    , parseBrickLayout
    , writeBrickLayout
    )
import Logo.Blockify (blockifyToLayout)
import Logo.Compose (composeLogo)
import Logo.Config (Config (..), parseConfig)
import Logo.Designs (generateAllDesigns)
import Logo.Favicons (generateFavicons)
import Logo.Raster (exportPng, exportWebp)
import System.Directory (createDirectoryIfMissing)
import System.FilePath (takeDirectory)
import qualified Data.Text.IO as TIO

main :: IO ()
main = do
    cfg <- parseConfig

    let sqSvg = cfgSqSvgDir cfg
        hzSvg = cfgHzSvgDir cfg
        sqPng = cfgSqPngDir cfg
        hzPng = cfgHzPngDir cfg
        dDir  = cfgDesignDir cfg
        lDir  = cfgLayoutDir cfg

    mapM_ (createDirectoryIfMissing True)
          [dDir, lDir, sqSvg, hzSvg, sqPng, hzPng]

    -- Stage 1 (skip with --from-blay true)
    when (not (cfgFromBlay cfg)) $ do
        putStrLn "==> designs"
        generateAllDesigns (cfgSourceSvg cfg) dDir
        runStage1 cfg

    -- Stage 2 always runs (reads .blay files produced by Stage 1)
    runStage2 cfg

    putStrLn "Done."

-- | Stage 1: rasterise design SVGs → .blay files.
-- Skip this with @--from-blay true@ to re-render after hand-editing a .blay.
runStage1 :: Config -> IO ()
runStage1 cfg = do
    let dDir = cfgDesignDir cfg
        lDir = cfgLayoutDir cfg
    putStrLn "==> logos (stage 1: blockify → .blay)"
    forM_ allSingleVariants $ \stem -> do
        let (px, pTop, pBot) = variantPadding cfg stem
        layout <- blockifyToLayout
            (dDir ++ "/" ++ stem ++ ".svg")
            px (cfgBlkW cfg) (cfgBlkH cfg)
            (cfgPad cfg) pTop pBot
        writeBrickLayout (lDir ++ "/" ++ stem ++ ".blay") layout

-- | Stage 2: .blay → SVG → PNG/WebP → GIF/WebP → favicons + codegen.
runStage2 :: Config -> IO ()
runStage2 cfg = do
    let sqSvg = cfgSqSvgDir cfg
        hzSvg = cfgHzSvgDir cfg
        sqPng = cfgSqPngDir cfg
        hzPng = cfgHzPngDir cfg

    -- 2a. Square SVGs from individual .blay files
    putStrLn "==> logos (stage 2a: .blay → square SVGs)"
    forM_ squareVariants $ \stem -> do
        bl <- readBlayFile cfg stem
        writeSvg (sqSvg ++ "/" ++ stem ++ ".svg") (layoutToSvg bl)

    -- 2b. Horizontal skin-tone SVGs: compose 4 square layouts side by side
    putStrLn "==> logos (stage 2b: 4 × .blay → horizontal skin-tone SVGs)"
    let mkHz stems = do
            ls <- mapM (readBlayFile cfg) stems
            return $ layoutsToHorizontalSvg gapBricks (map (withHzPad cfg) ls)
    hzSvg0 <- mkHz squareSkinTones
    writeSvg (hzSvg ++ "/horizontal.svg") hzSvg0
    forM_ (zip [1 :: Int ..] horizontalSkinToneRots) $ \(i, stems) -> do
        svg <- mkHz stems
        writeSvg (hzSvg ++ "/horizontal-rot" ++ show i ++ ".svg") svg

    -- 2c. Rainbow horizontal SVGs from their own .blay files
    putStrLn "==> logos (stage 2c: rainbow .blay → horizontal SVGs)"
    forM_ rainbowHzVariants $ \stem -> do
        bl <- readBlayFile cfg stem
        writeSvg (hzSvg ++ "/" ++ stem ++ ".svg") (layoutToSvg bl)

    -- Compose: add subtitle text
    putStrLn "==> compose (add subtitle)"
    forM_ allHorizontalVariants $ \stem -> do
        composeLogo (cfgFontPath cfg)
            (hzSvg ++ "/" ++ stem ++ ".svg")
            (hzSvg ++ "/" ++ stem ++ "-full.svg")
            (cfgTxtSize cfg) Nothing
        composeLogo (cfgFontPath cfg)
            (hzSvg ++ "/" ++ stem ++ ".svg")
            (hzSvg ++ "/" ++ stem ++ "-full-dark.svg")
            (cfgTxtSize cfg) (Just darkBg)

    -- Raster: SVG → PNG + WebP
    putStrLn "==> raster (PNG + WebP)"
    let rasterTargets =
            [(sqSvg, sqPng, s) | s <- squareVariants]
                ++ [(hzSvg, hzPng, s) | s <- allHorizontalVariants]
                ++ [(hzSvg, hzPng, s ++ "-full") | s <- allHorizontalVariants]
                ++ [(hzSvg, hzPng, s ++ "-full-dark") | s <- allHorizontalVariants]
    forM_ rasterTargets $ \(svgDir, pngDir, stem) -> do
        exportPng  (svgDir ++ "/" ++ stem ++ ".svg")
                   (pngDir ++ "/" ++ stem ++ ".png")  (cfgRasterW cfg)
        exportWebp (svgDir ++ "/" ++ stem ++ ".svg")
                   (pngDir ++ "/" ++ stem ++ ".webp") (cfgRasterW cfg)

    -- Animate: PNG frames → GIF + WebP
    putStrLn "==> animate (GIF + WebP)"
    let mkFrames dir stems ext = map (\s -> dir ++ "/" ++ s ++ ext) stems
        ms = cfgAnimMs cfg

    assembleGif  (mkFrames sqPng squareSkinTones ".png")  (sqPng ++ "/square-animated.gif")  ms
    assembleWebp (mkFrames sqPng squareSkinTones ".png")  (sqPng ++ "/square-animated.webp") ms

    assembleGif  (mkFrames hzPng horizontalSkinTones ".png")  (hzPng ++ "/horizontal-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones ".png")  (hzPng ++ "/horizontal-animated.webp") ms

    assembleGif  (mkFrames hzPng horizontalSkinTones "-full.png")
                 (hzPng ++ "/horizontal-full-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones "-full.png")
                 (hzPng ++ "/horizontal-full-animated.webp") ms

    assembleGif  (mkFrames hzPng horizontalSkinTones "-full-dark.png")
                 (hzPng ++ "/horizontal-full-dark-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones "-full-dark.png")
                 (hzPng ++ "/horizontal-full-dark-animated.webp") ms

    assembleGif  (mkFrames hzPng rainbowHzVariants ".png")
                 (hzPng ++ "/horizontal-rainbow-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants ".png")
                 (hzPng ++ "/horizontal-rainbow-animated.webp") ms

    assembleGif  (mkFrames hzPng rainbowHzVariants "-full.png")
                 (hzPng ++ "/horizontal-rainbow-full-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants "-full.png")
                 (hzPng ++ "/horizontal-rainbow-full-animated.webp") ms

    assembleGif  (mkFrames hzPng rainbowHzVariants "-full-dark.png")
                 (hzPng ++ "/horizontal-rainbow-full-dark-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants "-full-dark.png")
                 (hzPng ++ "/horizontal-rainbow-full-dark-animated.webp") ms

    -- Favicons
    putStrLn "==> favicons"
    generateFavicons (sqSvg ++ "/square.svg") (cfgFaviconDir cfg)

    -- Design guide JSON + JSON-LD
    putStrLn "==> design-guide.json"
    generateDesignGuide
    putStrLn "==> design-guide/*.jsonld"
    generateJsonLd

    -- Elm codegen
    putStrLn "==> elm codegen (Brand.Tokens)"
    let elmBrandSrc = "src/Brand"
    createDirectoryIfMissing True elmBrandSrc
    TIO.writeFile (elmBrandSrc <> "/Tokens.elm") generateBrandModule
    putStrLn "Wrote src/Brand/Tokens.elm"

-- ── Helpers ───────────────────────────────────────────────────────────────────

writeSvg :: FilePath -> String -> IO ()
writeSvg path svg = do
    createDirectoryIfMissing True (takeDirectory path)
    writeFile path svg
    putStrLn $ "  Saved " ++ path

readBlayFile :: Config -> String -> IO BrickLayout
readBlayFile cfg stem = do
    txt <- TIO.readFile (cfgLayoutDir cfg ++ "/" ++ stem ++ ".blay")
    case parseBrickLayout txt of
        Left  err -> error $ "readBlayFile: " ++ stem ++ ".blay: " ++ err
        Right bl  -> return bl

withHzPad :: Config -> BrickLayout -> BrickLayout
withHzPad cfg bl = bl { blPadTop = cfgHzPadTop cfg, blPadBottom = 0 }

variantPadding :: Config -> String -> (Int, Int, Int)
variantPadding cfg stem
    | stem `elem` squareVariants = (cfgSqPx cfg, cfgSqPadV cfg, cfgSqPadV cfg)
    | otherwise                  = (cfgHzPx cfg, cfgHzPadTop cfg, 0)

gapBricks :: Int
gapBricks = 2

-- ── File lists ────────────────────────────────────────────────────────────────

squareSkinTones :: [String]
squareSkinTones = ["square", "square-light-nougat", "square-nougat", "square-dark-nougat"]

squareVariants :: [String]
squareVariants = squareSkinTones ++ ["minifig-colorful", "minifig-rainbow"]

horizontalSkinToneRots :: [[String]]
horizontalSkinToneRots =
    [ drop i squareSkinTones ++ take i squareSkinTones | i <- [1, 2, 3] ]

horizontalSkinTones :: [String]
horizontalSkinTones = ["horizontal", "horizontal-rot1", "horizontal-rot2", "horizontal-rot3"]

rainbowHzVariants :: [String]
rainbowHzVariants =
    "horizontal-rainbow"
        : ["horizontal-rainbow-rot" ++ show i | i <- [1 .. 6 :: Int]]

allHorizontalVariants :: [String]
allHorizontalVariants = horizontalSkinTones ++ rainbowHzVariants

-- All variants that are individually blockified (have their own .blay file)
allSingleVariants :: [String]
allSingleVariants = squareVariants ++ rainbowHzVariants
