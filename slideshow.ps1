##
# run slideshow in the browser
##
#if ([Environment]::GetEnvironmentVariables().Contains("SLIDESOWBROWSER")) {
#    $browserCommand = $Env:SLIDESHOWBROWSER
#} else {
#    $browserCommand = "start microsoft-edge:"
#}

# TODO: make this more configurable
Start-Process "firefox.exe" -ArgumentList "index.html"