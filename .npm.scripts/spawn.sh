#!/bin/bash
export territoiresfuturs_ENV=${territoiresfuturs_ENV:-"staging"}
source .${territoiresfuturs_ENV}.env
# export HUGO_THEME_GIT_SSH=${HUGO_THEME_GIT_SSH:-"git@github.com:themefisher/airspace-hugo.git"}
export HUGO_THEME_GIT_SSH=${HUGO_THEME_GIT_SSH:-"git@github.com:zhaohuabing/hugo-theme-cleanwhite.git"}

if [ "x${HUGO_BASE_URL}" == "x" ]; then
  echo "the HUGO_BASE_URL env. var. is not defined, stopping the hugo project spawn"
  echo "set the HUGO_BASE_URL env. var.n, and re-run npm run spawn"
  exit 0
fi;

# ---
export TEMP_SPWAN_HOME=$(mktemp -d -t "TEMP_SPAN_HOME-XXXXXXXXXX")
git clone ${HUGO_THEME_GIT_SSH} ${TEMP_SPWAN_HOME}


mkdir content/
mkdir data/
mkdir static/
mkdir assets/
mkdir layouts/
mkdir resources/


# cp -rT ${TEMP_SPWAN_HOME}/exampleSite/content ./content
cp -fR ${TEMP_SPWAN_HOME}/exampleSite/content/* ./content/
# cp -rT ${TEMP_SPWAN_HOME}/exampleSite/data ./data
cp -fR ${TEMP_SPWAN_HOME}/exampleSite/data/* ./data/
# cp -rT ${TEMP_SPWAN_HOME}/static ./static
cp -fR ${TEMP_SPWAN_HOME}/static/* ./static/
# cp -rT ${TEMP_SPWAN_HOME}/exampleSite/static ./static
cp -fR ${TEMP_SPWAN_HOME}/exampleSite/static/* ./static/
# cp -rT ${TEMP_SPWAN_HOME}/assets ./assets
cp -fR ${TEMP_SPWAN_HOME}/assets/* ./assets/
cp ${TEMP_SPWAN_HOME}/exampleSite/assets/custom-theme.scss ./assets

cp ${TEMP_SPWAN_HOME}/exampleSite/config.toml .

# echo '' >> ./config.toml
# echo '[params.reveal_hugo]' >> ./config.toml
# echo 'custom_theme = "assets/custom-theme.scss"' >> ./config.toml
# echo 'custom_theme_compile = true' >> ./config.toml

echo '' >> ./config.toml
echo '' >> ./config.toml
echo '[reveal_hugo.custom_theme_options]' >> ./config.toml
echo 'targetPath = "assets/custom-theme.css"' >> ./config.toml
echo 'enableSourceMap = true' >> ./config.toml

# cp -rT ${TEMP_SPWAN_HOME}/layouts ./layouts
cp -fR ${TEMP_SPWAN_HOME}/layouts/* ./layouts/
# cp -rT ${TEMP_SPWAN_HOME}/exampleSite/layouts ./layouts
cp -fR ${TEMP_SPWAN_HOME}/exampleSite/layouts/* ./layouts/

# cp -rT ${TEMP_SPWAN_HOME}/exampleSite/resources ./resources
cp -fR ${TEMP_SPWAN_HOME}/exampleSite/resources/* ./resources/


export TOML_FILE_PATH=${TEMP_SPWAN_HOME}/theme.toml
npm run parse-hugo-them-toml | tee -a ${TEMP_SPWAN_HOME}/hugo.theme.to.json

# cat ${TEMP_SPWAN_HOME}/hugo.theme.to.json | jq .name
# cat ./.npm.scripts/hugo.theme.to.json  | jq .name | awk -F '"' '{print $2}'
cat ./.npm.scripts/hugo.theme.to.json  | jq .name | awk -F '"' '{print $2}' | tr '[:upper:]' '[:lower:]' | sed 's# #-#g'

# export HUGO_THEME_NAME=$(cat ${TEMP_SPWAN_HOME}/hugo.theme.to.json | jq .name)
export HUGO_THEME_NAME=$(cat ./.npm.scripts/hugo.theme.to.json  | jq .name | awk -F '"' '{print $2}' | tr '[:upper:]' '[:lower:]' | sed 's# #-#g')

echo "According [theme.toml], the hugo theme name is : [${HUGO_THEME_NAME}]"
mkdir -p themes/${HUGO_THEME_NAME}
cp -rT ${TEMP_SPWAN_HOME} ./themes/${HUGO_THEME_NAME}


sed -i "s#baseURL =.*#baseURL = \"${HUGO_BASE_URL}\"#g" ./config.toml
sed -i "s#theme =.*#theme = \"${HUGO_THEME_NAME}\"#g" ./config.toml
sed -i "s#themesDir =.*#themesDir = \"./themes\"#g" ./config.toml

export PATH=$PATH:/usr/local/go/bin && go version && hugo
# export PATH=$PATH:/usr/local/go/bin && go version && hugo serve -bttp://127.0.0.1:1313
