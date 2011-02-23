import XMonad
import XMonad.Actions.Submap
import XMonad.Actions.SpawnOn
import XMonad.Actions.CopyWindow
import XMonad.Actions.DynamicWorkspaces
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Tabbed
import XMonad.Layout.BoringWindows 
import XMonad.Layout.LayoutModifier
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.NoBorders
import XMonad.Prompt
import XMonad.Prompt.AppendFile
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import qualified Text.Regex.Posix as RE

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

main = do -- xmonad =<< myDzen myconfig
  sp <- mkSpawner
  conf <- myDzen ((myconfig sp) { manageHook = manageSpawn sp <+> manageHook defaultConfig })
  xmonad conf


myconfig sp = defaultConfig
              { normalBorderColor = darkgrey
              , focusedBorderColor= darkgrey
              , terminal          = "urxvt"
              , layoutHook        = mylayout
              , manageHook        = manageSpawn sp <+> mymanagehook
              , workspaces        = myworkspaces
              , logHook           = myLogHook
              , focusFollowsMouse = False }
              `additionalKeysP` mykeys (myconfig sp) sp
              `additionalMouseBindings` mymouse

mylayout = smartBorders $ windowNavigation $ subTabbed $ boringWindows $
                    tiled ||| Mirror tiled ||| Full -- ||| tabbedlayout

tiled = Tall nmaster delta ratio
nmaster = 1
ratio = 1/2
delta = 3/100

-- tabbedlayout = addTabs shrinkText myTabTheme tiled

myworkspaces :: [String]
myworkspaces = ["Hello"] -- , "2-code", "3-music", "4-config", "5-pdf", "6-go"] ++ (map show [7..9])

mykeys :: XConfig l -> Spawner -> [(String, X())]
mykeys conf sp =  [
          -----------------------
          -- Window Management --
          -----------------------
          ("M-j", focusDown)
         ,("M-k", focusUp)
         ,("M-Tab", onGroup W.focusDown')
         ,("M-S-Tab", onGroup W.focusUp')
         ,("M-M4-h", sendMessage $ pushWindow L)
         ,("M-M4-j", sendMessage $ pushWindow D)
         ,("M-M4-k", sendMessage $ pushWindow U)
         ,("M-M4-l", sendMessage $ pushWindow R)
         ,("M-M4-u", withFocused $ (sendMessage . UnMerge))
         ,("M-M4-m", withFocused $ (sendMessage . MergeAll))
         ,("M-S-c", kill1)
         ,("M-+", spawn "vol up")
         ,("M--", spawn "vol down")
         ,("M4-n", appendFilePrompt myXPConfig "/home/phil/doc/notes")
         ,("M4-x", shellPrompt myXPConfig)
         -------------------
         -- Internet Keys --
         -------------------
         ,("M4-i o", runOrCopy "/usr/bin/firefox" (className =? "Namoroka"))
         ,("M4-i n", spawn "/usr/bin/firefox")
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
         ,("M4-m o", runOrCopy "urxvt -e ncmpcpp" (title =? "ncmpc++ ver. 0.5.5"))
         ,("M4-m n", spawn "mpc next")
         ,("M4-m b", spawn "mpc prev")
         ,("M4-m p", spawn "mpc toggle")
         ,("M4-m s", launchApp myXPConfig {defaultText="~/.mpd/playlists/"} "mpc load" "Playlist:")
         -- r - web radio cycle
         -------------------
         -- Pianobar Keys --
         -------------------
         , ("M4-r o", spawn "urxvt -e pianobar")
         , ("M4-r p", spawn "echo -n p > /home/phil/.config/pianobar/ctl" )
         , ("M4-r n", spawn "echo -n n > /home/phil/.config/pianobar/ctl" )
         , ("M4-r +", spawn "echo -n + > /home/phil/.config/pianobar/ctl" )
         , ("M4-r -", spawn "echo -n - > /home/phil/.config/pianobar/ctl" )
         ----------------
         -- Other Apps --
         ----------------
         , ("M4-p", launchApp myXPConfig {defaultText="~/doc/pdf/"} "zathura" "PDF:")
         ] ++
         ------------------
         -- Copy Windows --
         ------------------
         [("M-S-M4-" ++ (show n), cmd) 
         | (n,cmd) <- zip [1..] [windows $ copy ws | ws <- workspaces conf]] ++
         ------------------------
         -- Prepare Workspaces --
         ------------------------
         [ ("M-p d", removeWorkspace)
         , ("M-p n", addWorkspace "new" >> renameWorkspace myXPConfig)
         , ("M-p r", renameWorkspace myXPConfig)
         , ("M-p w", selectWorkspace myXPConfig)] ++
         [("M-"++(show n), withNthWorkspace W.greedyView (n - 1)) | n <- [1..9]] ++
         [("M-S-"++(show n), withNthWorkspace W.shift (n - 1)) | n <- [1..9]] ++
         
--         [("M4-w c", W.greedyView (workspaces conf !! 2) >>
         [("M4-w i", spawnOn' 0 "/usr/bin/firefox" >> 
                     spawnOn' 0 "/usr/bin/urxvt -e mutt" >>
                     spawnOn' 0 "/usr/bin/urxvt -e irssi" >>
                     spawnOn' 2 "/usr/bin/urxvt -e config" >>
                     spawnOn' 3 "/usr/bin/mendeleydesktop" >>
                     spawnOn' 4 "/usr/bin/urxvt -e ncmpcpp" >>
                     spawnOn' 4 "/usr/bin/urxvt -e pianobar" >>
                     spawnOn' 5 "/usr/bin/cgoban3" )]
        where spawnOn' n cmd = spawnOn sp (workspaces conf !! n) cmd
                     


mymouse :: [((ButtonMask, Button), Window -> X())]
mymouse = [((0, button2) , (\w -> spawn "sr g $(xclip -o)"))]

myDzen conf = statusBar ("dzen2 " ++ flags) myDzenPP toggleStrutsKey conf
    where
        fg    = "'" ++ darkred ++ "'"
        bg    = "'" ++ background ++ "'"
        font  = "inconsolata"
        flags = "-e 'onstart=lower' -w 1920 -ta l -fn " ++ font ++ " -fg " ++ fg ++ " -bg " ++ bg

myLogHook :: X ()
myLogHook = fadeInactiveLogHook 0.8

mymanagehook :: ManageHook
--mymanagehook = manageHook defaultConfig
mymanagehook = manageHook defaultConfig <+> 
               composeAll [(className `contains` "CGoban" --> doShift "6-go")
                          ,(appName `contains` "KGS" --> doShift "6-go")
                          ,(isFullscreen --> doFullFloat)
                          ] 


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

contains :: Query String -> String -> Query Bool
contains q s = fmap (RE.=~ s) q
