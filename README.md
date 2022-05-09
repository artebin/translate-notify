# translate-notify

Simple script to show some text translation in a desktop notification.

## Features
  - Retrieve the text to translate from the clipboard or extract it from a screenshot (a region of the screen selected by user input) with OCR.
  - The translations are retrieved with `translate-shell` using Google Translate, so Internet connection is required. 
  - The target language can be specified as a parameter, else the script uses the default locale.
  - Shortcuts can be registered in `~/.config/sxhkd/sxhkdrc`.

      - Retrieve the text to translate from the clipboard, translate it and show the translation in a desktop notification:
    
                super + z
                translate-notify -l fr -c
        
      - Ask the user to capture a region of the screen with the mouse, extract the text, translate it and show the translation in a desktop notification:
        
                @super + x
                translate-notify -l fr -s

## Usage

~~~
Usage: translate-notify.sh [-h] [-l TARGET_LANGUAGE] [-cs] [-t TEXT_TO_TRANSLATE]

Where:
  -h      Help.
  -l      Target language. If not speficied then the default locale will be used.
  -c      Retrieve the text to translate from the clipboard.
  -s      Retrieve the text to translate using OCR on a region of the screen captured by the user.
  -t      Text to translate.
  
Dependencies:
  xmlstarlet is required to escape HTML formatting.
  tesseract-ocr, imagemagick and maim are required to extract the text to translate from a screenshot.
~~~

