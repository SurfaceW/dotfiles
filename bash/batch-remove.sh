# remove all node_modules
find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +

# remove all node_modules in trash
npm install --global trash-cli
find . -name node_modules -type d -prune -exec trash {} +

# remove all .stylus file
find . -name '*.styl' -type f -prune -exec rm -f '{}' +