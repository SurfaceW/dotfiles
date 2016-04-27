# dotfiles

This is a dotfiles which I keep to improve my efficiency.

run `bash build.sh` on MacOSX to update files.

## File and Description

- `.bash_profile`: bash config file, not recommended use.
- `.zshrc`: zsh configuration file
- `.gitconfig`
- `gitignore.txt`: basic contents a ignore file should be held.
- `.vimrc`: vim configuration file
- `Preferences.sublime-settings`: Preferences of sublime editor.
- `Sublime_plugin.txt`: installed sublime plugins
- `build.sh`: build current directory from elsewhere of my disc.
- `macdown.css`: .md file render to HTML's stylesheet.

## Oh My ZSH plugin

- `git`: [git plugin guide](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugin:git)
- `osx`: **Maintainers:** [robbyrussell](https://github.com/robbyrussell) [sorin-ionescu](https://github.com/sorin-ionescu)

| Command       | Description                                    |
|:--------------|:-----------------------------------------------|
| _tab_         | open the current directory in a new tab        |
| _pfd_         | return the path of the frontmost Finder window |
| _pfs_         | return the current Finder selection            |
| _cdf_         | cd to the current Finder directory             |
| _pushdf_      | pushd to the current Finder directory          |
| _quick-look_  | quick Look a specified file                    |
| _man-preview_ | open a specified man page in Preview           |

-  Enables [autojump](https://github.com/joelthelion/autojump/wiki/) if installed with homebrew, macports or debian/ubuntu package.

## Alias and Commands with oh\_my\_zsh

> More details see the `.zshrc` file.

Easy-Use Functionalities:

- `sublime FILENAME` open a file on sublime editor

### File System:

File and Directory

- `ll`: show all the details of such directory
- `..` | `...` | `.3` | `.4` | `.5` | `.6` : back to n level of directory
- `sublime`: edit file/directory in sublime editor
- `f`: open current directory in finder
- `which`: find all executables
- `path`: show all executable path
- `trash FILENAME`: move a file to MacOS Trash
- `j`: jump to the directory you've visited before
- `jo`: open a file explorer window (Mac Finder, Windows Explorer, GNOME Nautilus, etc.) to the directory.
- `jc`: jump to the child of current directory.
- `lr`:  Full Recursive Directory Listing
- `zipf FILE/DIR_NAME`: To create a ZIP archive of a folder
- `extract ARCHIVE`: Extract mainstream archive like: \*.tra.bz2 \*.tar.gz and etc.
- `size`: Show the current directory's sub-tree size

Searching

- `ff`: find the file under the current directory
- `ffs`: find the file whose name starts with a given string
- `ffe`: find the file whose name starts with a given string
- `spotlight`: use Mac Spotlight's metadata to search file 

Process Management

- `findPid`: find out the pid of a specified process
- `my_ps`: list the process owned by the current user

Networking

- `myip`
- `netCons`: show all open TCP/IP sockets
- `ii`: display useful host-related information

Git Shortcuts

- `co`: git checkout
- `ci`: git commit -a
- `br`: git branch
- `gs`: git status
- `rebase`: git rebase
- `reset`: git reset

Help

- `tldr`: simplified man page 

OSX Series:

- `man-preview` - open a specified man page in Preview
- `trash` - move a specified file to the Trash
- `open` - Open directory in Finder of Mac

Tools:

- `jekyll` - static blog generator
    - `jekyll build | serve`
- `jumbo` - Baidu Package Manager
- `mongo` - Mongo DB
- `mysql` - MySQL CLI tools
- `brew` - Mac version of `apt-get`

Node Tools:

- `browserify`
- `express`
- `npm`
- `gulp`
- `grunt`
- `tldr`

---

## Alfred enhancement

### Quick Search Tips

- `open` quickly open doc or folder
- 「←」「→」go inside or outside of a folder
- After searching, click「Ctrl」 to get more operations on the searched item
- After searching, click「Shift」to preview the document.
- 「cmd」+ 「enter」open current file or directory on Finder
- 「ctrl」+ 「enter」search the web with default search engine.

Web Search：

- 「google」「translate」「maps」「wolfram」… Web Search quick commands

### Tools

- Dictionary:「define」
- Calculator:「15*5/2.3」

### Workflow

- Chrome
    - 「ch」Search Chrome History and open it
    - 「chrome」Search Chrome bookmarks and open it
- Evernote
    - 「ent」Evernote note search with node title
    - 「ens」Evernote note search with node title and its content
        - 「end #」Search note with tag name
    - 「end」Evernote search the notebook

### Global Hotkeys

- `cmd + alt + control + T` Search Evernote with Title
- `cmd + alt + control + E` Launch / Switch to Evernote
- `cmd + alt + control + F` Launch / Switch to OmniFocus
- `cmd + alt + control + G` Switch to GlobalFocus File
- `cmd + alt + control + I` Launch / Switch to iTerm
