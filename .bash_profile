export PATH="/usr/local/mysql/bin:$PATH":/Users/yeqingnan/.nowa-gui/installation/node_modules/.bin:/Applications/NowaGUI.app/Contents/Resources/app/nodes
export PATH=$PATH:/Users/yeqingnan/Developer/mongodb/bin:/Users/yeqingnan/.nowa-gui/installation/node_modules/.bin:/Applications/NowaGUI.app/Contents/Resources/app/nodes
# Add GHC 7.10.3 to the PATH, via https://ghcformacosx.github.io/
export GHC_DOT_APP="/Applications/ghc-7.10.3.app"
if [ -d "$GHC_DOT_APP" ]; then
    export PATH="${HOME}/.local/bin:${HOME}/.cabal/bin:${GHC_DOT_APP}/Contents/bin:${PATH}":/Users/yeqingnan/.nowa-gui/installation/node_modules/.bin:/Applications/NowaGUI.app/Contents/Resources/app/nodes
fi

# for LS/Grep HighLight
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

