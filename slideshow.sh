#!/bin/bash

# exit whenever something unexpected happens
set -e

# set the browser command to a fallback value in case
# it is not yet set in the environment
if [ -z "${SLIDESHOWBROWSER}" ]; then
	SLIDESHOWBROWSER="firefox -new-window"
fi

# run slideshow in the browser
${SLIDESHOWBROWSER} index.html&
