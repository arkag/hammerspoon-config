local application = require "hs.application"
local fnutils = require "hs.fnutils"
local grid = require "hs.grid"
local hotkey = require "hs.hotkey"
local mjomatic = require "hs.mjomatic"
local window = require "hs.window"
local home = os.getenv("HOME")

prefix = hs.hotkey.modal.new('cmd', 'J')
lastApp = nil

function prefix:entered()
  alerted = hs.alert.show("Command mode", true)
end

function prefix:exited()
  hs.alert.closeSpecific(alerted)
end

function acNotify(exitCode, stdOut, stdErr, path)
  if exitCode == nil then
    hs.notify.show("Autocommit Success", path, "Your path has been commited to GitHub.")
  else
    hs.notify.show("Autocommit Fail", path, "Your path failed to commit.")
  end
end

function autoCommit(src, dest)
  hs.task.new("/usr/local/bin/autocommit", acNotify(exitCode, stdOut, stdErr, src), {home..src, home..dest}):start()
end

local function launchFocusOrSwitchBack(bundleid)
    -- This function will launch appName if it's not running, focus
    -- it if it is running, or if it's already focused, switch back
    -- to whatever the last focused App was
    currentApp = hs.application.frontmostApplication()
    if lastApp and currentApp and (currentApp:bundleID() == bundleid) then
        lastApp:activate(true)
    else
        hs.application.launchOrFocusByBundleID(bundleid)
    end
    lastApp = currentApp
    currentWindow = hs.window.focusedWindow()
    currentFrame = currentWindow:frame()
    cfx = currentFrame.x + (currentFrame.w / 2)
    cfy = currentFrame.y + (currentFrame.h / 2)
    cfp = hs.geometry.point(cfx, cfy)
    hs.mouse.setAbsolutePosition(cfp)

    prefix:exit()
end

local function keyStroke(mod, key, bundleid)
  app = hs.application.get(bundleid)
  hs.eventtap.event.newKeyEvent(mod, key, true):post(app)
  hs.eventtap.event.newKeyEvent(mod, key, false):post(app)
end

local function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    if (appName == "Finder") then
      -- Bring all Finder windows forward when one gets activated
      appObject:selectMenuItem({"Window", "Bring All to Front"})
    end
  end
end

-- Work Application Binds
prefix:bind('', 'W', function() launchFocusOrSwitchBack("com.vivaldi.Vivaldi") end)
prefix:bind('', 'R', function() launchFocusOrSwitchBack("com.microsoft.rdc.macos") end)
prefix:bind('', 'T', function() launchFocusOrSwitchBack("com.microsoft.teams") end)
prefix:bind('', 'O', function() launchFocusOrSwitchBack("com.microsoft.Outlook") end)

-- General Application Binds
prefix:bind('', 'B', function() launchFocusOrSwitchBack("org.mozilla.nightly") end)
prefix:bind('', 'Z', function() launchFocusOrSwitchBack("com.tidal.desktop") end)
prefix:bind('', 'X', function() launchFocusOrSwitchBack("com.googlecode.iterm2") end)
prefix:bind('', 'C', function() launchFocusOrSwitchBack("com.tdesktop.Telegram") end)
prefix:bind('', 'N', function() launchFocusOrSwitchBack("com.github.atom") end)
prefix:bind('', 'M', function() launchFocusOrSwitchBack("com.googlecode.iterm2") keyStroke('cmd', '1', "com.googlecode.iterm2") end)
prefix:bind('', ',', function() launchFocusOrSwitchBack("com.hnc.DiscordPTB") end)
prefix:bind('', 'F', function() launchFocusOrSwitchBack("com.apple.finder") end)
prefix:bind('', 'P', function() launchFocusOrSwitchBack("com.apple.Preview") end)
prefix:bind('', 'V', function() launchFocusOrSwitchBack("com.vmware.fusion") end)

-- System Binds
prefix:bind('', 'escape', function() prefix:exit() end)
prefix:bind('cmd', 'L', function() hs.caffeinate.lockScreen() prefix:exit() end)
prefix:bind('cmd', 'S', function() hs.caffeinate.systemSleep() prefix:exit() end)
prefix:bind('cmd', 'C', function() hs.pasteboard.clearContents() hs.alert.show("Clipboard Cleared") prefix:exit() end)

-- Information Binds
prefix:bind('cmd', 'B', function() hs.pasteboard.setContents(hs.application.frontmostApplication():bundleID()) hs.alert.show("BundleID Copied") prefix:exit() end)
prefix:bind('cmd', 'D', function() hs.pasteboard.setContents(hs.application.frontmostApplication():title()) hs.alert.show("Title Copied") prefix:exit() end)

--
-- Monitor and reload config when required
--
function reload_config(files)
  hs.reload()
end
hs.pathwatcher.new(home .. "/.hammerspoon/", reload_config):start()
autoCommit("/.hammerspoon/", "/git/hammerspoon-config/")
hs.alert.show("Config loaded")
--
-- /Monitor and reload config when required
--
