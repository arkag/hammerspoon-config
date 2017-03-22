## Hammerspoon - Config

Here is my hammerspoon config file. I don't have the init.lua split up because most of my methods are pretty simple and self explanatory.

### Requirements

Both of these packages are required to have full functionality of this init.lua.

`brew install pngpaste kwm`

For autocommitting, I've created a script in `/usr/local/bin/`

```
#!/bin/bash

src=$1
dest=$2

# Currently only used for hammerspoon, additional functionality might be added.

cp -r ${src} ${dest}

cd ${dest}

git add .
git commit -m "automated commit"
git push

return $?
```

### Features

* Key chording a la Emacs with `Cmd-J` to enter command mode
* Photo and Text pasting via https://ptpb.pw
* Application shortcuts: hitting a command twice will return you to the previously focused application
* Auto config commits, ensure you check pathnames and your repository is set up ahead of time.
* Window focusing and movement through `kwm`
* Toggle Zoom and Floating Windows with `kwm`
* `Cmd-J Cmd-L` to Sleep Computer

### Bugs

I'm aware of issues with the init.lua: 

* URL Shortening isn't working due to the service I'm using isn't handling the shortening properly
* `Cmd-J Z` doesn't actually switch to Chrome/Firefox and switch to the first tab, this is an issue I'm working on, it might be an issue with Hammerspoon
* Auto commits aren't actually 100% certain. The notification method I'm using relies on `exitCode` from `hs.task` and for some reason it's not actually setting `exitCode`. It's always `nil`.
* Anything you guys find.

