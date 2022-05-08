# translate-notify

Simple script to show some text translation in a desktop notification.

Features:
  - retrieve the text to translate from the clipboard or extract it from a screenshot (region of the screen selected by user input)
  - target language can be given in parameters, else the script uses the default locale
  - shortcut can be registered in `~/.config/sxhkd/sxhkdrc`:

        super + z
        translate-notify -l fr -c

## Usage

~~~
Usage: translate-notify.sh [-h] [-l TARGET_LANGUAGE] [-cs] [-t TEXT_TO_TRANSLATE]

Where:
  -h      Help.
  -l      Target language. If not speficied then the default locale will be used.
  -c      Retrieve text to translate from the clipboard.
  -s      Let the user take a screenshot of a region of the screen, extract the text with tesseract-ocr and translate it.
          Some dependencies are required to extract the text to translate from a screenshot: tesseract-ocr, imagemagick, scrot.
  -t      Text to translate.
  
Dependencies:
  xmlstarlet is required to escape HTML formatting.
  tesseract-ocr, imagemagick and scrot are required to extract the text to translate from a screenshot.
~~~

