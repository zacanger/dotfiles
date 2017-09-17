#!/usr/bin/env bash
# This script lets you resize images in batches with different compression tools
usage(){
  cat <<END
usage: resize FILE_OR_FOLDER [options]

  The options are as follows:

    -w widths     (default: 2560 1920 1024 560)
    -q quality    (default: 75)
    -a adjust     Only files within the adjusted date will be resized. See 'man date' val[ymwdHMS] (default 1m)
    -t tool       Compression tool: jpegoptim, mozjpeg or imagemagick (default: imagemagick)
    -r            Losslessly shrink JPEG file with JPEGrescan (default: 0)
    -d            Attach info to filename

END
  exit 1
}

type "convert" > /dev/null 2>&1 || { echo "Please install imagemagick first" >&2; exit 1; }
[[ $# -ge 1 ]] || { echo -e "Incorrect number of parameters\n" >&2; usage; }

files=$1
[[ -e $files ]] || { echo -e "resize: $1: No such file or directory\n" >&2; usage; }
shift

adjust=""
dir="resized"
quality=75
widths="2560 1920 1024 560"
tool='imagemagick'
rescan=0
debug=0

while getopts ":w:q:a:t:rd" opt; do
  case $opt in
    a)  adjust=$OPTARG  ;;
    d)  debug=1         ;;
    q)  quality=$OPTARG ;;
    r)  rescan=1        ;;
    t)  tool=$OPTARG    ;;
    w)  widths=$OPTARG  ;;
    --) break           ;;
    :)  echo -e "Option -${OPTARG} is missing an argument\n" >&2; usage ;;
    \?) echo -e "Unknown option: -${OPTARG}\n" >&2; usage               ;;
  esac
done

if [[ -d $files ]]; then
  cd $files
  if [[ -n $adjust  ]]; then
    timestamp=`date -j -v-$adjust +"%Y/%m/%d %H:%M"`
    files=`find . -newermt "$timestamp" -d 1 -name '*.jpg'`
  else
    files=`find . -d 1 -name '*.jpg'`
  fi
fi

mkdir -p $dir || { echo "Could not create $dir." >&2; exit 1; }

for file in $files; do
  for width in $widths; do
    resized_file="${file/.jpg/}_${width}.jpg"
    if (( $debug )); then
      resized_file="${file/.jpg/}_${tool}_q${quality}_w${width}.jpg"
    fi
    echo "generating $resized_file"
    case $tool in
      "jpegoptim")   `convert -resize $width $file jpg:- | jpegoptim -q -p -f --max=$quality --strip-all --stdout --stdin > $dir/$resized_file` ;;
      "mozjpeg")     `convert -resize $width $file png:- | cjpeg -quality $quality -optimize -dct float -outfile $dir/$resized_file`            ;;
      "imagemagick") `convert -quality $quality -resize $width $file $dir/$resized_file`                                                        ;;
    esac
    if (( $rescan )); then
      optimized_file=$resized_file
      if (( $debug )); then
        optimized_file="${file/.jpg/}_${tool}+rescan_q${quality}_w${width}.jpg"
      fi
      echo "optimizing $optimized_file"
      `mv $dir/$resized_file /tmp`
      `jpegrescan -q -s -i /tmp/$resized_file $dir/$optimized_file`
    fi
  done
done
