#!/usr/bin/env bash

print_usage(){
	cat << EOF
Usage: $0 [-h] [-l TARGET_LANGUAGE] [-cs] [-t TEXT_TO_TRANSLATE]

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
EOF
}

exit_gracefully(){
	# Delete files created while retrieving the text from a screenshot
	rm -f ~/.$0.*.png
	rm -f ~/.$0.*.png.txt
}
trap exit_gracefully EXIT

if [[ $# -eq 0 ]]; then
	print_usage
	exit 1
fi

TARGET_LANGUAGE=""
RETRIEVE_TEXT_FROM_CLIPBOARD="false"
RETRIEVE_TEXT_FROM_SCREENSHOT="false"
TEXT_TO_TRANSLATE=""

while getopts "hl:cst:" OPT; do
	case "${OPT}" in
		h)
			print_usage
			exit 0
			;;
		l)
			TARGET_LANGUAGE="${OPTARG}"
			;;
		c)
			RETRIEVE_TEXT_FROM_CLIPBOARD="true"
			;;
		s)
			RETRIEVE_TEXT_FROM_SCREENSHOT="true"
			;;
		t)
			TEXT_TO_TRANSLATE="${OPTARG}"
			;;
		*)
			print_usage
			exit 1
			;;
	esac
done

if ${RETRIEVE_TEXT_FROM_CLIPBOARD}; then
	TEXT_TO_TRANSLATE=$(xsel -o)
elif ${RETRIEVE_TEXT_FROM_SCREENSHOT}; then
	# Take the screenshot with the mouse and increase image quality with option -q from default 75 to 100
	SCREENSHOT_FILE="$(mktemp ~/.${0##*/}.XXXXXX.png)"
	scrot -d 1 -s "${SCREENSHOT_FILE}" -q 100
	
	# Transform the screenshot file to increase detection rate
	mogrify -modulate 100,0 -resize 400% "${SCREENSHOT_FILE}"
	
	tesseract "${SCREENSHOT_FILE}" "${SCREENSHOT_FILE}"
	TEXT_TO_TRANSLATE=$(cat "${SCREENSHOT_FILE}.txt")
fi

# Clean TEXT_TO_TRANSLATE
TEXT_TO_TRANSLATE=$(echo "${TEXT_TO_TRANSLATE}" | sed -e 's/^[^[[:print:]]]*//' | sed -e 's/[^[[:print:]]]*$//')

# Exit if nothing to translate
if [[ -z "${TEXT_TO_TRANSLATE}" ]]; then
	notify-send --icon=info "Translation" "Nothing to translate!"
	exit 0
fi

# Retrieve default locale if TARGET_LANGUAGE not specified
if [[ -z "${TARGET_LANGUAGE}" ]]; then
	TARGET_LANGUAGE="${LANG%_*}"
fi
printf "TARGET_LANGUAGE=%s\n" "${TARGET_LANGUAGE}"

# Retrieve the translation
TRANSLATED_TEXT=$(trans -b :${TARGET_LANGUAGE} "${TEXT_TO_TRANSLATE}")
printf "TEXT_TO_TRANSLATE=%s\n" "${TEXT_TO_TRANSLATE}"
printf "TRANSLATED_TEXT=%s\n" "${TRANSLATED_TEXT}"

# Use xmlstarlet to escape HTML characters as the desktop notifications use HTML formatting
NOTIFICATION_TEXT="$(echo "${TEXT_TO_TRANSLATE}" | xmlstarlet esc)\n\n<i>$(echo ${TRANSLATED_TEXT} | xmlstarlet esc)</i>"

# Desktop Notifications Specification <http://www.galago-project.org/specs/notification/0.9/x161.html>
notify-send --icon=info "Translation" "${NOTIFICATION_TEXT}"
