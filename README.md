# Rotorock, go rock!


## How to run (locally)

```bash
git clone git@github.com:rotorock-io/siteweb.git ~/rotorock-io-work
cd ~/rotorock-io-work
git checkout develop && atom .
# and then run :
npm i
export PATH=$PATH:/usr/local/go/bin && go version
hugo serve -b http://127.0.0.1:4545 -p 4545 --bind 127.0.0.1 -w
```

## How to Deploy

```bash
# --- #
export PATH=$PATH:/usr/local/go/bin && go version
git clone git@github.com:rotorock-io/siteweb.git ~/rotorock-io-work
cd ~/rotorock-io-work
git checkout develop && atom .
export HUGO_BASE_URL=https://rotorock.io
export HUGO_BASE_URL=https://rotorock-io.github.io/siteweb/
hugo -b ${HUGO_BASE_URL}
if [ -d ./docs/ ]; then
  rm -fr docs/
fi;
mkdir docs/
cp -fR public/* docs/
echo "rotorock.io" > docs/CNAME
echo "rotorock.io" > CNAME

git add -A && git commit -m "deploy" && git push -u origin HEAD

git flow release start 0.0.0

git flow release finish -s 0.0.0

```

## How to re-spawn (how that site was generated)

```bash
export PATH=$PATH:/usr/local/go/bin && go version
git clone git@github.com:rotorock-io/siteweb.git ~/rotorock-io-work
cd ~/rotorock-io-work
git checkout develop && atom .
npm i
npm run spawn
# and then run :
npm i
hugo serve -b http://127.0.0.1:4545 -p 4545 --bind 127.0.0.1 -w
```
