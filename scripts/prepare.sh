#!/bin/bash

red="\e[1;31m"  # Red B
blue="\e[1;34m" # Blue B
green="\e[0;32m"

bwhite="\e[47m" # white background

rst="\e[0m"     # Text reset

st=1

stage()
{
    echo -en "$green[$st] "$blue"$1...$rst\n"
    let "st += 1"
}

clone_project()
{
    if [ ! -d "../$2" ]; then
        echo -en $green"Clone $2$rst\n"
        git clone $1 ../$2
        cd ../$2
        git checkout $3
        cd -
    else
        echo -en "You can update "$green"$2"$rst" manualy$rst\n"
    fi
}

stage "Clone projects"

clone_project https://github.com/ShunkevichDV/sc-machine.git sc-machine scp_stable
clone_project https://github.com/Ivan-Zhukau/sc-web.git sc-web master
clone_project https://github.com/ShunkevichDV/ims.ostis.kb.git ims.ostis.kb master
clone_project https://github.com/ostis-apps/gt-ostis-drawings.git gt-ostis-drawings master
clone_project https://github.com/ostis-apps/set-ostis-drawings set-ostis-drawings master
clone_project https://github.com/ostis-apps/gt-knowledge-processing-machine.git kb/graph_theory/gt-knowledge-processing-machine master
clone_project https://github.com/ostis-apps/gt-knowledge-base.git kb/graph_theory/gt-knowledge-base master
clone_project https://github.com/MaxGavr/set-theory.git kb/set-theory discrete_math
clone_project https://bitbucket.org/iit-ims-team/web-scn-editor web-scn-editor

stage "Prepare projects"

prepare()
{
    echo -en $green$1$rst"\n"
}

prepare "sc-machine"
cd ../sc-machine/scripts
./install_deps_ubuntu.sh

sudo apt-get install redis-server

./clean_all.sh
./make_all.sh
cd -

prepare "sc-web"
sudo apt-get install python-dev # required for numpy module
cd ../sc-web/scripts
./install_deps_ubuntu.sh
./install_nodejs_dependence.sh
cd -
cd ../sc-web
npm install
grunt build
cd -
echo -en $green"Copy server.conf"$rst"\n"
cp -f ../config/server.conf ../sc-web/server/

cd ../gt-ostis-drawings
npm install
grunt build
cd ../set-ostis-drawings
npm install
grunt build
cd ../web-scn-editor/
npm install
grunt build
grunt exec:renewComponentsHtml
cd ../scripts

stage "Build knowledge base"

rm -rf ../kb/menu
rm ../ims.ostis.kb/ui/ui_start_sc_element.scs

./build_kb.sh
