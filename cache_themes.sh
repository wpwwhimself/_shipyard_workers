# plan:
# - pull latest release version of shipyard
# - if nothing changed, stop
# - go through all scss files without _ in name
# - for each of them:
#   - stitch them together with _base.scss
#   - call sasscompiler
#   - save results in /var/www/wpww/shipyard_themes as css

#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### START ####

heading "💄 Shipyard Theme Caching started" 1

if [ ! -d "./raw" ]; then
  mkdir ./raw
fi
if [ ! -d "./stitched" ]; then
  mkdir ./stitched
fi
if [ ! -d "./ready" ]; then
  mkdir ./ready
fi

heading "🔎 Checking for updates..." 2

latest_release=$(curl -s https://api.github.com/repos/wpwwhimself/shipyard/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]*)".*/\1/' | tr -d '"')
cached_latest_release=$(<./latest_version)
if [ "$latest_release" == "$cached_latest_release" ]; then
  heading "🚨 Themes are up to date" 2
  exit
fi

echo "$latest_release" > ./latest_version

heading "📦 Downloading themes..." 2

curl -s https://api.github.com/repos/wpwwhimself/shipyard/contents/files/scss | jq -r '.[] | [.name, .download_url] | @tsv' |
while IFS=$ '\t' read -r name url; do
  heading "$name..." 3
  curl -sSL "$url" -o "./raw/$name"
done

heading "♻️ Stitching raw files..." 2

for file in ./raw/*; do
  name=$(basename "$file")
  if [ "$name" != "_base.scss" ]; then
    heading "$name..." 3
    cat ./raw/_base.scss "$file" > "./stitched/$(basename "$file")"
  fi
done

heading "🔨 Compiling..." 2

for file in ./stitched/*; do
  name=$(basename "$file")
  heading "$name..." 3
  sass "$file" "./ready/${name%.*}.css"
done

heading "🚚 Copying to public..." 2

cp ./ready/* /var/www/wpww/shipyard_themes
rm -rf ./ready/* ./stitched/* ./raw/*

heading "✅ All done!" 1
