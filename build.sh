# This is an automatic transfer dotfile to  
Dotfiles="~/Developer/dotfiles"

cp ~/.bash_profile ~/Developer/dotfiles/
cp ~/.vimrc ~/Developer/dotfiles/
cp ~/.zshrc ~/Developer/dotfiles/
cp /Users/yeqingnan/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings ~/Developer/dotfiles/
cp ~/.gitconfig ~/Developer/dotfiles/
cp ~/.gitignore ~/Developer/dotfiles/
cp /Users/yeqingnan/Library/Application\ Support/MacDown/Styles/macdown.css ~/Developer/dotfiles/
cp /Users/yeqingnan/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/snippet/*.sublime-snippet ~/Developer/dotfiles/

# Get the sublime plugin lists
cd ~/Developer/dotfiles
rm Sublime_plugin.txt
cd /Users/yeqingnan/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages/
ls >> ~/Developer/dotfiles/Sublime_plugin.txt


