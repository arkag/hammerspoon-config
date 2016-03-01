local application = require "hs.application"
local fnutils = require "hs.fnutils"
local grid = require "hs.grid"
local hotkey = require "hs.hotkey"
local mjomatic = require "hs.mjomatic"
local window = require "hs.window"

grid.MARGINX = 0
grid.MARGINY = 0
grid.GRIDHEIGHT = 13
grid.GRIDWIDTH = 13

local mash = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "alt", "ctrl", "shift"}

prefix = hs.hotkey.modal.new('cmd', 'j')
function prefix:entered() hs.alert'Entered mode' end
function prefix:exited() hs.alert'Exited mode' end
prefix:bind('', 'escape', function() prefix:exit() end)

local function openiterm()
  application.launchOrFocus("iTerm 2")
  prefix:exit()
end

local function openbrowser()
  application.launchOrFocus("Firefox")
  prefix:exit()
end

local function openmail()
  application.launchOrFocus("CloudMagic Email")
  prefix:exit()
end

local function openchat()
  application.launchOrFocus("Textual")
  prefix:exit()
end

local function openmusic()
  application.launchOrFocus("Spotify")
  prefix:exit()
end

local function openvm()
  application.launchOrFocus("VMware Fusion")
  prefix:exit()
end

local function openpass()
  application.launchOrFocus("1Password 6")
  prefix:exit()
end

local function openedit()
  application.launchOrFocus("Atom")
  prefix:exit()
end

local function opensteam()
  application.launchOrFocus("Steam")
  prefix:exit()
end

local function opengog()
  application.launchOrFocus("GalaxyClient")
  prefix:exit()
end

--
-- Open Applications
--

prefix:bind('', 'Z', 'Launching...', openmusic)
prefix:bind('', 'X', 'Launching...', openiterm)
prefix:bind('', 'C', 'Launching...', openchat)
prefix:bind('', 'V', 'Launching...', openvm)
prefix:bind('', 'B', 'Launching...', openbrowser)
prefix:bind('', 'N', 'Launching...', openpass)
prefix:bind('', 'M', 'Launching...', openmail)
prefix:bind('', ',', 'Launching...', openedit)

--
-- /Open Applications
--

--
-- toggle push window to edge and restore to screen
--

-- somewhere to store the original position of moved windows
local origWindowPos = {}

-- cleanup the original position when window restored or closed
local function cleanupWindowPos(_,_,_,id)
  origWindowPos[id] = nil
end

-- function to move a window to edge or back
local function movewin(direction)
  local win = hs.window.focusedWindow()
  local res = hs.screen.mainScreen():frame()
  local id = win:id()

  if not origWindowPos[id] then
    -- move the window to edge if no original position is stored in
    -- origWindowPos for this window id
    local f = win:frame()
    origWindowPos[id] = win:frame()

    -- add a watcher so we can clean the origWindowPos if window is closed
    local watcher = win:newWatcher(cleanupWindowPos, id)
    watcher:start({hs.uielement.watcher.elementDestroyed})

    if direction == "left" then f.x = (res.w - (res.w * 2)) + 10 end
    if direction == "right" then f.x = (res.w + res.w) - 10 end
    if direction == "down" then f.y = (res.h + res.h) - 10 end
    win:setFrame(f)
  else
    -- restore the window if there is a value for origWindowPos
    win:setFrame(origWindowPos[id])
    -- and clear the origWindowPos value
    cleanupWindowPos(_,_,_,id)
    prefix:exit()
  end
end

prefix:bind('', 'A', '', function() movewin("left") end)
prefix:bind('', 'D', '', function() movewin("right") end)
prefix:bind('', 'S', '', function() movewin("down") end)

--
-- /toggle push window to edge and restore to screen
--

--
-- Window management
--

prefix:bind('', 'H', function() window.focusedWindow():focusWindowWest() prefix:exit() end)
prefix:bind('', 'L', function() window.focusedWindow():focusWindowEast() prefix:exit() end)
prefix:bind('', 'K', function() window.focusedWindow():focusWindowNorth() prefix:exit() end)
prefix:bind('', 'J', function() window.focusedWindow():focusWindowSouth() prefix:exit() end)

--Move windows
hotkey.bind(mash, 'DOWN', grid.pushWindowDown)
hotkey.bind(mash, 'UP', grid.pushWindowUp)
hotkey.bind(mash, 'LEFT', grid.pushWindowLeft)
hotkey.bind(mash, 'RIGHT', grid.pushWindowRight)

--resize windows
hotkey.bind(mashshift, 'UP', grid.resizeWindowShorter)
hotkey.bind(mashshift, 'DOWN', grid.resizeWindowTaller)
hotkey.bind(mashshift, 'RIGHT', grid.resizeWindowWider)
hotkey.bind(mashshift, 'LEFT', grid.resizeWindowThinner)

hotkey.bind(mash, 'N', grid.pushWindowNextScreen)
hotkey.bind(mash, 'P', grid.pushWindowPrevScreen)

-- hotkey.bind(mashshift, 'M', grid.maximizeWindow)
--
-- /Window management
--


--
-- Monitor and reload config when required
--
function reload_config(files)
  hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")
--
-- /Monitor and reload config when required
--
