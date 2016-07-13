export PATH="/usr/local/mysql/bin:$PATH"
export PATH=$PATH:/Users/yeqingnan/Developer/mongodb/bin
# Add GHC 7.10.3 to the PATH, via https://ghcformacosx.github.io/
export GHC_DOT_APP="/Applications/ghc-7.10.3.app"
if [ -d "$GHC_DOT_APP" ]; then
    export PATH="${HOME}/.local/bin:${HOME}/.cabal/bin:${GHC_DOT_APP}/Contents/bin:${PATH}"
fi

# for LS/Grep HighLight
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

