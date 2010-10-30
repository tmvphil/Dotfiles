import XMonad
import XMonad.Actions.Submap
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Tabbed
import XMonad.Layout.LayoutModifier
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Prompt
import XMonad.Prompt.AppendFile
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import qualified Data.Map as M

--data XConfig l = XConfig {
--    normalBorderColor :: !String
--    focusedBorderColor :: !String
--    terminal :: !String
--    layoutHook :: !(l Window)
--    manageHook :: !ManageHook
--    handleEventHook :: !(Event -> X All)
--    workspaces :: ![String]
--    numlockMask :: !KeyMask
--    modMask :: !KeyMask
--    keys :: !(XConfig Layout -> Map (ButtonMask, KeySym) (X ()))
--    mouseBindings :: !(XConfig Layout -> Map (ButtonMask, Button) (Window -> X ()))
--    borderWidth :: !Dimension
--    logHook :: !(X ())
--    startupHook :: !(X ())
--    focusFollowsMouse :: !Bool
--}

main = xmonad =<< myDzen myconfig

myconfig = defaultConfig
              { normalBorderColor = darkgrey
              , focusedBorderColor= darkgrey
              , terminal          = "urxvt"
              , layoutHook        = mylayout
              , workspaces        = myworkspaces
              , logHook           = myLogHook
              , focusFollowsMouse = False }
              `additionalKeysP` mykeys
              `additionalMouseBindings` mymouse

mylayout = windowNavigation $
                tiled ||| Mirror tiled ||| Full -- ||| tabbedlayout

tiled = Tall nmaster delta ratio
nmaster = 1
ratio = 1/2
delta = 3/100

-- tabbedlayout = addTabs shrinkText myTabTheme tiled

myworkspaces :: [String]
myworkspaces = ["1-todo", "2-code", "3-web", "4-mail", "5-music", "6-go"]

mykeys :: [(String, X())]
mykeys = [
          -----------------------
          -- Window Management --
          -----------------------
          ("M-M4-h", sendMessage $ Go L)
         ,("M-M4-j", sendMessage $ Go D)
         ,("M-M4-k", sendMessage $ Go U)
         ,("M-M4-l", sendMessage $ Go R)
         ,("M-+", spawn "vol up")
         ,("M--", spawn "vol down")
         ,("M4-n", appendFilePrompt myXPConfig "/home/phil/doc/notes")
         ,("M4-x", shellPrompt myXPConfig)
         -------------------
         -- Internet Keys --
         -------------------
         ,("M4-i o", spawn "/usr/bin/firefox")
         ,("M4-i b", launchApp myXPConfig {defaultText="~/.bookmarks/"} "/home/phil/bin/open_bookmark.sh" "Open Bookmark:")
         ,("M4-i g", launchApp myXPConfig "surfraw google -l" "Feeling Lucky:")
         ,("M4-i r", spawn "/usr/bin/firefox www.reddit.com")
         ,("M4-i h", spawn "/usr/bin/firefox news.ycombinator.com")
         ,("M4-i s", launchApp myXPConfig "surfraw" "Surfraw:")
         ,("M4-i a w", launchApp myXPConfig "surfraw ddg !archwiki" "ArchWiki:")
         ,("M4-i a u", launchApp myXPConfig "surfraw aur" "AUR:")
         ,("M4-i a f", spawn "/usr/bin/firefox bbs.archlinux.org")
         ----------------
         -- Music Keys --
         ----------------
         ,("M4-m o", spawn "urxvt -e ncmpcpp")
         ,("M4-m n", spawn "mpc next")
         ,("M4-m b", spawn "mpc prev")
         ,("M4-m p", spawn "mpc toggle")
         ,("M4-m s", launchApp myXPConfig {defaultText="~/.mpd/playlists/"} "mpc load" "Playlist:")
         -- r - web radio cycle
         -------------------
         -- Pianobar Keys --
         -------------------
         , ("M4-p o", spawn "urxvt -e pianobar")
         , ("M4-p p", spawn "echo -n p > /home/phil/.config/pianobar/ctl" )
         , ("M4-p n", spawn "echo -n n > /home/phil/.config/pianobar/ctl" )
         ]




mymouse :: [((ButtonMask, Button), Window -> X())]
mymouse = [((0, button2) , (\w -> spawn "sr g $(xclip -o)"))]

--myDzen :: LayoutClass l Window
 --      => XConfig l -> IO (XConfig (ModifiedLayout AvoidStruts l))
myDzen conf = statusBar ("dzen2 " ++ flags) myDzenPP toggleStrutsKey conf
    where
        fg    = "'" ++ darkred ++ "'"
        bg    = "'" ++ background ++ "'"
        font  = "inconsolata"
        flags = "-e 'onstart=lower' -w 1920 -ta l -fn " ++ font ++ " -fg " ++ fg ++ " -bg " ++ bg

-- dzen :: LayoutClass l Window
--      => XConfig l -> IO (XConfig (ModifiedLayout AvoidStruts l))
-- dzen conf = statusBar ("dzen2 " ++ flags) dzenPP toggleStrutsKey conf
--  where
--     fg      = "'#a8a3f7'" -- n.b quoting
--     bg      = "'#3f3c6d'"
--     flags   = "-e 'onstart=lower' -w 400 -ta l -fg " ++ fg ++ " -bg " ++ bg

myLogHook :: X ()
myLogHook = fadeInactiveLogHook 0.8

------------
-- Themes --
------------
myXPConfig :: XPConfig
myXPConfig = defaultXPConfig
                { font    = "xft:inconsolata:dpi=96:antialias=true"
                , bgColor = background
                , fgColor = green
                , borderColor = darkcyan
                , height = 20}

myTabTheme = defaultTheme
                { activeColor       = lightgrey
                , activeTextColor   = cyan
                , inactiveColor     = background
                , inactiveTextColor = darkblue
                , urgentColor       = background
                , urgentTextColor   = red
                , fontName          = "xft:inconsolata:dpi=96:antialias=true" }

myDzenPP :: PP
myDzenPP = dzenPP
                { ppCurrent         = dzenColor white blue . pad
                , ppVisible         = dzenColor green background . pad
                , ppHidden          = dzenColor darkgreen background . pad
                , ppHiddenNoWindows = dzenColor darkgrey background . pad
                , ppUrgent          = dzenColor black red . pad
                , ppSep             = ""
                , ppWsSep           = ""
                , ppTitle           = dzenColor green background . pad . shorten 30
                , ppLayout          = dzenColor green background . pad
                , ppExtras = [ wrapL "^p(_CENTER)^p(-80)" "" $ dzenColorL red background currentSong
  --                         , padL $ dzenColorL green background aumixVolume
                             , wrapL "^pa(1760)" "" $ dzenColorL green background mydate
                             ]
                }

-------------
-- Loggers --
-------------
mydate      = date "%I:%M %p %a %b %d"
--volume      = logCmd
currentSong = logCmd "mpc current"

------------
-- Colors --
------------
background  = "#111111"
black       = "#333333"
darkgrey    = "#666666"
darkred     = "#d15517"
red         = "#d11723"
darkgreen   = "#36b217"
green       = "#00d56a"
darkyellow  = "#d1b217"
yellow      = "#ffea55"
darkblue    = "#55aaff"
blue        = "#1793d1"
darkmagenta = "#b217d1"
magenta     = "#d11793"
darkcyan    = "#93d1b2"
cyan        = "#17d1b2"
lightgrey   = "#eeeeee"
white       = "#ffffff"


-----------
-- Hacks --
-----------

-- Extra Mouse buttons
button6 = 6 :: Button
button7 = 7 :: Button
button8 = 8 :: Button

-- Revised AppLauncher to customize title text on prompt
data AppPrompt = AppPrompt String
instance XPrompt AppPrompt where
    showXPrompt (AppPrompt n) = n ++ " "

type Application = String
type Parameters = String

{- | Given an application and its parameters, launch the application. -}
launch :: MonadIO m => Application -> Parameters -> m ()
launch app params = spawn ( app ++ " " ++ params )


{- | Get the user's response to a prompt an launch an application using the
   input as command parameters of the application.-}
launchApp :: XPConfig -> Application -> String -> X ()
launchApp config app name = mkXPrompt (AppPrompt name) config (getShellCompl []) $ launch app

-- mydzen dependency
toggleStrutsKey :: XConfig t -> (KeyMask, KeySym)
toggleStrutsKey XConfig{modMask = modm} = (modm, xK_b )
