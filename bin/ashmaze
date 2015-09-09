#!/bin/bash
#
#
# Bash Maze ver 1.0
# This game was based on the maze generator from
# Joe Wingbermuehle at  https://raw.github.com/joewing/maze/master/maze.sh
# I've added movement and collision to create the game.
# 
#
# References:
# https://raw.github.com/joewing/maze/master/maze.sh
# http://lendscripts.blogspot.com.br/2012/10/licao-3-programacao-de-jogos-em.html
#
# Written by Fernando Bolonhezi Giannasi - jun/2013


# Validade bash version
if [ $(echo $BASH_VERSION | awk -F"." '{ if ( ($1 >= 4) ) {print "0"} else {print "1"}}') -ne "0" ]; then
  echo "This game only works on bash 4.0 or later"
  echo "Your version is $BASH_VERSION"
  exit 1
fi

# Inicial menu
setterm -cursor off

while true; do
clear
echo -e '\033[01;33m'
cat << EOF
	Bash Maze ver 1.0
*******************************************
Help the red ball find the exit
*******************************************
Keys:
	a -> move left
	s -> move down
	d -> move right
	w -> move up
	q -> quit (anytime)
*******************************************
EOF
tput sgr0
echo -e '\033[01;31m'
cat << EOF
Select the difficulty:
	1-) Easy
	2-) Medium
	3-) Hard
	q-) Exit
EOF
tput sgr0
read -n1 -s DIFIC

case "$DIFIC" in
"1")
  MAZE_WIDTH="39"
  MAZE_HEIGHT="21"
  break
  ;;
"2")
  MAZE_WIDTH="49"
  MAZE_HEIGHT="31"
  break
  ;;
"3")
  MAZE_WIDTH="59"
  MAZE_HEIGHT="31"
  break
  ;;
"q")
  exit 0
  ;;
esac
done

# Initialize the maze array.
function init_maze {
   for ((y=0; y<MAZE_HEIGHT; y++)) ; do
      for ((x=1; x<$((MAZE_WIDTH-1)); x++)) ; do
         maze[$((y * MAZE_WIDTH + x))]=0
      done
      maze[$((y * MAZE_WIDTH + 0))]=1
      maze[$((y * MAZE_WIDTH + (MAZE_WIDTH - 1)))]=1
   done
   for ((x=0; x<MAZE_WIDTH; x++)) ; do
      maze[$x]=1
      maze[$(((MAZE_HEIGHT - 1) * MAZE_WIDTH + x))]=1
   done
}

# Display the maze array.
function print_maze {
   for ((y=0; y<MAZE_HEIGHT; y++)) ; do
      for ((x = 0; x < MAZE_WIDTH; x++ )) ; do
         if [[ maze[$((y * MAZE_WIDTH + x))] -eq 0 ]] ; then
            echo -n "[]"
         else
            echo -n "  "
         fi
      done
      echo
   done
}

# Carve the maze starting at the specified offset.
function carve_maze {
   local index=$1
   local dir=$RANDOM
   local i=0
   maze[$index]=1
   while [ $i -le 4 ] ; do
      local offset=0
      case $((dir % 4)) in
         0) offset=1 ;;
         1) offset=-1 ;;
         2) offset=$MAZE_WIDTH ;;
         3) offset=$((-$MAZE_WIDTH)) ;;
      esac
      local index2=$((index + offset))
      if [[ maze[$index2] -eq 0 ]] ; then
         local nindex=$((index2 + offset))
         if [[ maze[$nindex] -eq 0 ]] ; then
            maze[$index2]=1
            carve_maze $nindex
            i=0
            dir=$RANDOM
            index=$nindex
         fi
      fi
      i=$((i + 1))
      dir=$((dir + 1))
   done
}

# Create a maze:
TMP="/tmp"
if [ ! -d "$TMP" ]; then
  mkdir "$TMP"
fi
init_maze
carve_maze $((2 * MAZE_WIDTH + 2))
maze[$((MAZE_WIDTH + 2))]=1
maze[$(((MAZE_HEIGHT - 2) * MAZE_WIDTH + MAZE_WIDTH - 3))]=1
print_maze > $TMP/maze.txt
sed -i '1d' $TMP/maze.txt
sed -i 's/^  //g' $TMP/maze.txt

# Variables
INPUT="0" # Input data
m="0" # Mov 1
n="1" # Mov 2
C="0" # Collision test
x="3" # X coordinate
y="0" # Y coordinate
counter="1" #Counts movements
WINS="$(echo $MAZE_HEIGHT - 3 | bc)" # Detects the exit

#Functions to print maze and ball
function cat_maze() {
  echo -ne '\033[01;32m'
  cat $TMP/maze.txt
  tput sgr0
  echo "X coordinate = $x"
  echo "Y coordinate = $y"
  echo "Moves = $counter"
}

function cat_ball() {
  echo -ne '\033[01;31m'O
  tput sgr0
}

# inicial position
clear
tput cup 0 0
cat_maze
tput cup $y $x
cat_ball

# Moving the ball:
while [ $INPUT != "q" ];do
  read  -n1 -s INPUT

  if [ $INPUT = a ];then
    let "m = x"
    let "n = y + 1"
    C=$(cat $TMP/maze.txt | sed -n "$n"p 2> /dev/null | cut -c"$m" 2> /dev/null) # If C is not empty than we hit a wall
    if [ -z $C ];then
      let "x = x - 1"
    else
      let counter--
    fi
  fi

  if [ $INPUT = d ];then
    let "m = x + 2"
    let "n = y + 1"
    C=$(cat $TMP/maze.txt | sed -n "$n"p 2> /dev/null | cut -c"$m" 2> /dev/null)
    if [ -z $C ];then
      let "x = x + 1"
    else
      let counter--
    fi
  fi

  if [ $INPUT = w ];then
    let "m = x + 1"
    let "n = y"
    C=$(cat $TMP/maze.txt | sed -n "$n"p 2> /dev/null | cut -c"$m" 2> /dev/null)
    if [ -z $C ];then
      let "y = y - 1"
    else
      let counter--
    fi
  fi

  if [ $INPUT = s ];then
    let "m = x + 1"
    let "n = y + 2"
    C=$(cat $TMP/maze.txt | sed -n "$n"p 2> /dev/null | cut -c"$m" 2> /dev/null)
    if [ -z $C ];then
      let "y = y + 1"
    else
      let counter--
    fi
  fi

  if [ "$y" -lt "0" ]; then y=0; let counter--; fi

# Check Wins
  if [ "$y" -gt "$WINS" ]; then
    tput cup $(echo $MAZE_HEIGHT + 3 | bc) 0
    echo -e '\033[01;31m'
    echo You WON!!!!!
    echo "Score: $counter moves"
    tput sgr0
    echo 
    setterm -cursor on
    exit 0
  fi

  clear
  cat_maze

# Prints the ball on new location
  tput cup $y $x
  cat_ball
  let counter++
done
clear

# End of script
