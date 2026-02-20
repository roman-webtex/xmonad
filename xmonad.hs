import System.IO
import System.Exit

import XMonad
import qualified XMonad.Prompt as P

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers(composeOne, doFullFloat, doCenterFloat, isFullscreen, isDialog)
import XMonad.Hooks.Place

import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.SpawnOnce

import XMonad.Layout.MultiColumns
import XMonad.Layout.ThreeColumns
import XMonad.Layout.PerWorkspace

import XMonad.Actions.NoBorders
import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicProjects

import qualified XMonad.Actions.Search as S
import qualified XMonad.Actions.Submap as SM

import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified Data.ByteString as B

myWorkspaces            = ["1","2","3","4","5","6","7","8","9"]
myTerm                  = "urxvt -fade 35 +sb"
myFM                    = "urxvt -name mc -e mc"
myRanger                = "urxvt -name ranger -e ranger"
mySublime               = "subl"
myCalc                  = "urxvt -e bc -ql"

myPlacement             = withGaps (20, 0, 0, 0) (underMouse (0, 0))

myLayout                = Full ||| onWorkspace "9" (Mirror (multiCol [0] 1 0.01 (-0.5))) (ThreeColMid 1 (3/100) (1/2)) ||| tiled
   where
       tiled = Tall nmaster delta ratio
       nmaster = 1
       ratio   = 1/2
       delta   = 3/100

myCenterFloatHookClass = [ "Gimp"
                         , "Gimp-2.10"
                         , "feh"
                         , "Pavucontrol"
                         , "atari800"
                         ]
myCenterFloatHookTitle = [ "Downloads"
                         , "Save As..."
                         , "bc"
                         , "Вхід"
                         , "Event Tester"
                         ]
myFloatAtMouseHookTitle= [ "CalShow"
                         , "TopShow"
                         , "DfShow"
                         , "MemShow"
                         ]

myManageHook = composeAll . concat $
    [ [isDialog                     --> doCenterFloat ]
    , [className =? c               --> doCenterFloat | c <- myCenterFloatHookClass ]
    , [title =? c                   --> doCenterFloat | c <- myCenterFloatHookTitle ]
    , [title =? c                   --> placeHook myPlacement <+> doFloat | c <- myFloatAtMouseHookTitle ]
    , [resource =? "desktop_window" --> doIgnore]
    ]

searchEngineMap method = M.fromList $
      [ ((0, xK_g), method S.google)
      , ((0, xK_d), method S.duckduckgo)
      , ((0, xK_w), method S.wikipedia)
      , ((0, xK_y), method S.youtube)
      , ((0, xK_h), method S.hackage)
      ]

main :: IO ()
main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/...../.xmonad/xmobar"
    xmonad  $ docks def
        { layoutHook = myLayout }
        { manageHook = manageHook def <+> myManageHook <+> manageDocks
            , terminal           = myTerm
            , focusedBorderColor = "green"
            , normalBorderColor  = "black"
            , workspaces         = myWorkspaces
            , layoutHook         = avoidStruts myLayout
            , startupHook        = spawnOnce "feh --no-xinerama --bg-center /home/....../wall/269413-4096x1743.jpg"
            , logHook            = dynamicLogWithPP $ xmobarPP
                {
                    ppOutput = hPutStrLn xmproc
                  , ppTitle  = xmobarColor "green" "" . shorten 75
                }
            , modMask = mod4Mask
        } `additionalKeys`
        [   ((mod4Mask, xK_f),                 spawn myFM )
          , ((controlMask, xK_Print),          spawn "sleep 0.3; scrot -s '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/images/shots/'" )
          , ((0, 0x1008ff13),                  spawn "~/bin/SetVolume 5")
          , ((0, 0x1008ff11),                  spawn "~/bin/SetVolume -5")
          , ((0, xK_Print),                    spawn "scrot '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/images/shots/'" )
          , ((0, xF86XK_Mail),                 spawn "google-chrome https://gmail.com/" )
          , ((0, xF86XK_AudioPlay),            spawn "pavucontrol" )
          , ((0, xF86XK_AudioMute),            spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle" )
          , ((0, xF86XK_Favorites),            spawn "gimp" )
          , ((0, xF86XK_HomePage),             spawn "google-chrome" )
          , ((0, xF86XK_Calculator),           spawn myCalc )
          , ((0, xF86XK_Launch5),              spawn "libreoffice26.2" )
          , ((0, xF86XK_Launch6),              spawn "scribus" )
          , ((0, xF86XK_Search),               SM.submap $ searchEngineMap $ S.promptSearch P.def )
          , ((0, xF86XK_Forward),              nextWS )
          , ((0, xF86XK_Back),                 prevWS )
          , ((mod4Mask, xF86XK_Forward),       shiftToNext >> nextWS )
          , ((mod4Mask, xF86XK_Back),          shiftToPrev >> prevWS )
          , ((mod4Mask, xK_b),                 sendMessage ToggleStruts )
          , ((mod4Mask, xK_s),                 switchProjectPrompt def )
          , ((mod4Mask .|. shiftMask, xK_b),   withFocused toggleBorder)
          , ((mod4Mask .|. shiftMask, xK_g),   goToSelected def)
          , ((mod4Mask .|. shiftMask, xK_s),   spawnSelected def [ "nemo", "gnome-terminal", "google-chrome", "scribus", "subl", "gimp", "Inkscape.AppImage", "libreoffice26.2" ])
         ]        

        