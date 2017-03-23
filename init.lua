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

local function togglefloat()
  fn = hs.task.new("/usr/local/bin/kwmc", nil, {"window", "-t", "focused"})
  fn:start()
  prefix:exit()
end

local function togglezoom()
  fn = hs.task.new("/usr/local/bin/kwmc", nil, {"window", "-z", "fullscreen"})
  fn:start()
  prefix:exit()
end

local function focusWin(direction)
  fn = hs.task.new("/usr/local/bin/kwmc", nil, {"window", "-f", direction})
  fn:start()
  prefix:exit()
end

local function moveWin(direction)
  fn = hs.task.new("/usr/local/bin/kwmc", nil, {"window", "-s", direction})
  fn:start()
  prefix:exit()
end

local function paste()
  url = hs.pasteboard.readURL()
  paste = hs.pasteboard.getContents()
  if not url and not paste then
    pp = hs.task.new("/usr/local/bin/pngpaste", nil, {home .. "/.paste.png"})
    pp:start()
    fn = hs.task.new("/usr/bin/curl", function(exitCode, stdOut, stdErr) hs.pasteboard.setContents(stdOut:match("url: ([^\n]+)")) end, {"-F", "c=@/Users/"..user.."/.paste.png", "https://ptpb.pw/"})
    hs.alert.show("Image uploaded")
  elseif url then
    -- This isn't currently working due to how ptpb handles URLs and their redirection.
    fn = hs.task.new("/usr/bin/curl", function(exitCode, stdOut, stdErr) hs.pasteboard.setContents(stdOut:match("url: ([^\n]+)")) end, {"-F", "c=@-", "-w "..url, "https://ptpb.pw/u"})
    fn:setInput(url)
    hs.alert.show("URL shortened")
  else
    fn = hs.task.new("/usr/bin/curl", function(exitCode, stdOut, stdErr) hs.pasteboard.setContents(stdOut:match("url: ([^\n]+)")) end, {"-F", "c="..paste, "https://ptpb.pw"})
    hs.alert.show("Text pasted")
  end
  fn:start()
  prefix:exit()
end

local function launchFocusOrSwitchBack(bundleid)
    -- This function will launch appName if it's not running, focus
    -- it if it is running, or if it's already focused, switch back
    -- to whatever the last focused App was
    currentApp = hs.application.frontmostApplication()
    if lastApp and currentApp and (currentApp:bundleID() == bundleid) then
        lastApp:activate()
    else
        hs.application.launchOrFocusByBundleID(bundleid)
    end
    lastApp = currentApp
    prefix:exit()
end

local function popUpApp(bundleid)
  prefix:exit()
end

local function keyStroke(mod, key, bundleid)
  hs.eventtap.event.newKeyEvent(mod, key, true):post(hs.application.get(bundleid))
  hs.eventtap.event.newKeyEvent(mod, key, false):post(hs.application.get(bundleid))
end

local function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    if (appName == "Finder") then
      -- Bring all Finder windows forward when one gets activated
      appObject:selectMenuItem({"Window", "Bring All to Front"})
    end
  end
end

--prefix:bind('', 'Z', function() launchFocusOrSwitchBack("org.mozilla.nightly") hs.eventtap.keyStroke('cmd', '1') hs.eventtap.keyStroke('cmd', '1') end)
prefix:bind('', 'Z', function() launchFocusOrSwitchBack("com.google.Chrome.canary") keyStroke('cmd', '1', "com.google.Chrome.canary") end)
prefix:bind('', 'X', function() launchFocusOrSwitchBack("com.googlecode.iterm2") end)
prefix:bind('', 'C', function() launchFocusOrSwitchBack("com.tdesktop.Telegram") end)
prefix:bind('', 'V', function() launchFocusOrSwitchBack("com.vmware.fusion") end)
--prefix:bind('', 'B', function() launchFocusOrSwitchBack("org.mozilla.nightly") end)
prefix:bind('', 'B', function() launchFocusOrSwitchBack("com.google.Chrome.canary") end)
prefix:bind('', 'N', function() launchFocusOrSwitchBack("com.github.atom") end)
prefix:bind('', 'M', function() launchFocusOrSwitchBack("com.googlecode.iterm2") hs.eventtap.keyStroke('cmd', '1') end)
prefix:bind('', ',', function() launchFocusOrSwitchBack("com.hnc.Discord") end)
prefix:bind('', '.', function() launchFocusOrSwitchBack("com.tinyspeck.slackmacgap") end)
prefix:bind('', 'F', function() launchFocusOrSwitchBack("com.apple.finder") end)
prefix:bind('', 'P', function() launchFocusOrSwitchBack("com.apple.Preview") end)
prefix:bind('', 'G', function() launchFocusOrSwitchBack("com.valvesoftware.steam") end)
prefix:bind('cmd', 'G', function() launchFocusOrSwitchBack("com.gog.galaxy") end)

prefix:bind('', 'H', function() focusWin('west') end)
prefix:bind('', 'J', function() focusWin('north') end)
prefix:bind('', 'K', function() focusWin('south') end)
prefix:bind('', 'L', function() focusWin('east') end)

prefix:bind('', 'left', function() moveWin('west') end)
prefix:bind('', 'up', function() moveWin('north') end)
prefix:bind('', 'down', function() moveWin('south') end)
prefix:bind('', 'right', function() moveWin('east') end)

prefix:bind('', 'escape', function() prefix:exit() end)
prefix:bind('cmd', 'L', function() hs.caffeinate.systemSleep() prefix:exit() end)
prefix:bind('cmd', 'F', togglefloat)
prefix:bind('cmd', 'M', togglezoom)
prefix:bind('cmd', 'P', paste)

-- Information Binds

prefix:bind('cmd', 'B', function() hs.pasteboard.setContents(hs.application.frontmostApplication():bundleID()) hs.alert.show("BundleID Copied") prefix:exit() end)
prefix:bind('cmd', 'D', function() hs.pasteboard.setContents(hs.window.frontmostWindow():title()) hs.alert.show("Window Title Copied") prefix:exit() end)


function azsh(files)
  autoCommit("/.zshrc", "/git/zshrc/")
end

hs.pathwatcher.new(home .. "/.zshrc", azsh):start()

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
