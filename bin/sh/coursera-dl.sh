#!/bin/bash
set -e
set -u
function assert_aria2c_is_present() {
    set +e
    aria2c --help >/dev/null
    # TODO: Allow curl/wget as a fallback if aria2c is missing.
    if [ $? -ne 0 ]; then
        echo "Unable to find 'aria2c' (the command 'aria2c --help' failed). Please make sure that the package 'aria2c' (http://aria2.sourceforge.net/) is correctly installed" >&2
        exit 1
    fi
    set -e
}
assert_aria2c_is_present

##################
# Parse arguments
scriptname="$(basename "$0")"
function print_usage() {
    echo "USAGE: $scriptname [options] <Resources_Page> <Destination_Directory>" >&2
    echo -e "Downloads all resources from a course page. Requires 'aria2c' to be installed.\n" >&2
    echo -e "Resources_Page                  Either path to a locally saved copy, or URL of the webpage containing links to all the resources" >&2
    echo -e "                                (e.g., 'https://class.coursera.org/algo2-002/lecture/index', '~/algo_lectures.html', etc)" >&2
    echo -e "Destination_Directory           Path to existing local directory where course resources will be downloaded." >&2
    echo -e "options:" >&2
    echo -e "  -c, --cookie-file             Path to cookie file (e.g., ~/.config/google-chrome/Default/Cookies)." >&2
    echo -e "  -h, --help                    Display this help message and exit." >&2
}

cookieFile=""
resourcesPage=""
destDir=""
while [ "$#" -gt 0 ]
do
    case "$1" in
        -c | --cookie-file)
            shift;
            cookieFile="$1"
            shift
            ;;
        -h | --help)
            print_usage
            exit 0
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            print_usage
            exit 1
            ;;
        *)  if [ ! -z "$destDir" ]; then
                echo -e "Error: Extra positional arguments specified - Illegal\n" >&2
                print_usage
                exit 1
            fi
            if [ -z "$resourcesPage" ]; then
                resourcesPage="$1"
            else
                destDir="$1"
            fi
            shift;
            ;;
    esac
done

function validate_input() {
    if [ ! -z "$cookieFile" ]; then
        if [ ! -f "$cookieFile" ]; then
            echo -e "Not a valid file: '$cookieFile'\n" >&2
            print_usage
            exit 1
        fi
    fi
    if [ ! -d "$destDir" ]; then
        echo -e "Not a valid directory: '$destDir'\n" >&2
        print_usage
        exit 1
    fi
}
validate_input
##################

if [ ! -z "$cookieFile" ]; then
    aria2c_cookie_arg="--load-cookies \"$cookieFile\""
else
    aria2c_cookie_arg=""
fi

tempFile=""
if [ ! -f "$resourcesPage" ]; then
    tempFile="$(mktemp -u -t courseraDL.XXXXXX)"
    # Download the HTML page which contains link to all the resources
    aria2c $aria2c_cookie_arg "$resourcesPage"  --dir "$(dirname "$tempFile")" -o "$(basename "$tempFile")"
    htmlFile="$tempFile"
else
    htmlFile="$resourcesPage"
fi

# Now find all the relevant links from the lecture index page
allURLS="$(egrep -o '"https[^"]+(pdf|mp4)[^"]*"' "$htmlFile" | cut -b 2- | rev | cut -b 2- | rev)"

count=0
for link in $allURLS; do
    echo -e "${link}"
    echo "******* Will start Downloading link: $link *******"
    aria2c --continue $aria2c_cookie_arg --dir "$destDir" "$link"
    echo -e "******* Finished downloading link: $link *******\n"
    count=$((count+1))
done

if [ -f "$tempFile" ]; then
    rm "$tempFile"
fi
echo -e "All Downloads finished (total $count files downloaded)! :)\n"
