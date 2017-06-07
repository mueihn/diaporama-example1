::# exit whenever something unexpected happens
::set -e
::
::##
::# generate the files.xml listing the input photos and advertisements
::##
::echo "<files>" > files.xml
::echo -e "\t<photos>" >> files.xml
::find photos -name *.jpg -o -name *.jpeg -o -name *.png | \
::while read file; do
::	echo -e "\t\t<photo>${file}</photo>" >> files.xml
::done
::echo -e "\t</photos>" >> files.xml
::echo -e "\t<advertisements>" >> files.xml
::find advertisements -name *.jpg -o -name *.jpeg -o -name *.png | \
::while read file; do
::	echo -e "\t\t<advertisement>${file}</advertisement>" >> files.xml
::done
::echo -e "\t</advertisements>" >> files.xml
::echo "</files>" >> files.xml

::::
:: generate the actual slideshow file from the input XML and the config XML
::::
msxsl files.xml sortFiles.xslt -o sortedFiles.xml
msxsl sortedFiles.xml generateDiaporamaJson.xslt -o diaporama.json

::::
:: run the slideshow
::::
::./slideshow.sh
