# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Make sure we use the latest Homebrew
brew update
brew upgrade

# Get more recent versions of OSX Tools
brew install bash
brew install bash-completion
brew install homebrew/dupes/grep
brew install homebrew/depes/openssh
brew install homebrew/depes/screen
brew install homebrew/php/php55 --with-gmp


brew install vim --overide-system-vi

# Install some useful tools
brew install git

