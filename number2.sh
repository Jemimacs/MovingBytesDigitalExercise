#!/bin/bash

FILE_NAME=""
IS_INTERACTIVE=0
declare -A PARKING_LOT

function setup_command {
  if [ $COUNT -eq 3 ]; then
    COMMAND1="${COMMANDS[0]}"
    COMMAND2="${COMMANDS[1]}"
    COMMAND3="${COMMANDS[2]}"
    run_command "$COMMAND1" "$COMMAND2" "$COMMAND3"
  elif [ $COUNT -eq 2 ]; then
    COMMAND1="${COMMANDS[0]}"
    COMMAND2="${COMMANDS[1]}"
    run_command "$COMMAND1" "$COMMAND2"
  elif [ $COUNT -eq 1 ]; then
    COMMAND1="${COMMANDS[0]}"
    run_command "$COMMAND1"
  else
    echo "Please insert any command"
  fi
}

function run_command {
  SLOT_COUNT=${#PARKING_LOT[@]}
  if [ "$IS_INTERACTIVE" == "1" ]; then
    echo "Output: "
  fi

  if [ "$1" == "create_parking_lot" ]; then
    for ((i=0;i<$2;i++)); do
      for ((j=0;j<3;j++)); do
        PARKING_LOT[${i}, reg]=""
        PARKING_LOT[${i}, col]=""
        PARKING_LOT[${i}, status]=0
      done
    done
    printf "Created a parking lot with $2 slots\n"
  elif [ "$1" == "park" ]; then
    declare -a INDEX_LIST
    for ((i=0;i<$SLOT_COUNT;i++)); do
      if [ "${PARKING_LOT[${i}, status]}" == "0" ]; then
        INDEX_LIST+=($i)
      fi
    done
    if [ ${#INDEX_LIST[@]} -ne 0 ]; then
      IFS=$'\n' SORTED_LIST=($(sort <<<"${INDEX_LIST[*]}")); unset IFS
      INDEX=${SORTED_LIST[0]}
      PARKING_LOT[${INDEX}, reg]=$2
      PARKING_LOT[${INDEX}, col]=$3
      PARKING_LOT[${INDEX}, status]=1
      let INDEX++
      printf "Allocated slot number: %d\n" $INDEX
      unset INDEX_LIST
    else
      printf "Sorry, parking lot is full\n"
    fi
  elif [ "$1" == "leave" ]; then
    let INDEX=$2-1
    PARKING_LOT[${INDEX}, reg]=""
    PARKING_LOT[${INDEX}, col]=""
    PARKING_LOT[${INDEX}, status]=0
    printf "Slot number %d is free\n" $2
  elif [ "$1" == "status" ]; then
    if [ "$IS_INTERACTIVE" == "1" ]; then
      header="%-10s %-20s %-10s\n"
      format="%-10d %-20s %-10s\n"

      printf "$header" "Slot No." "Registration No." "Colour"

      for ((i=0;i<$SLOT_COUNT;i++)); do
        if [ "${PARKING_LOT[${i}, status]}" == "1" ]; then
          let INDEX=$i+1
          printf "$format" $INDEX "${PARKING_LOT[${i}, reg]}" "${PARKING_LOT[${i}, col]}"
          echo ""
        fi
      done
    else
      printf "Slot No.  Registration No.  Colour\n"
      for ((i=0;i<$SLOT_COUNT;i++)); do
        if [ "${PARKING_LOT[${i}, status]}" == "1" ]; then
	  let INDEX=$i+1
          printf "%d  %s  %s\n" $INDEX "${PARKING_LOT[${i}, reg]}" "${PARKING_LOT[${i}, col]}"
        fi
      done
    fi
  elif [ "$1" == "registration_numbers_for_cars_with_colour" ]; then
    declare -a REG_LIST
    for ((i=0;i<$SLOT_COUNT;i++)); do
      if [ "${PARKING_LOT[${i}, col]}" == $2 ]; then
        REG_LIST+=(${PARKING_LOT[${i}, reg]})
      fi
    done
    echo "${REG_LIST[@]}" | sed 's/ /, /g'
    unset REG_LIST
  elif [ "$1" == "slot_numbers_for_cars_with_colour" ]; then
    declare -a SLOT_LIST
    for ((i=0;i<$SLOT_COUNT;i++)); do
      if [ "${PARKING_LOT[${i}, col]}" == $2 ]; then
        let INDEX=$i+1
        SLOT_LIST+=($INDEX)
      fi
    done
    echo "${SLOT_LIST[@]}" | sed 's/ /, /g'
    unset SLOT_LIST
  elif [ "$1" == "slot_number_for_registration_number" ]; then
    INDEX=-1
    for ((i=0;i<$SLOT_COUNT;i++)); do
      if [ "${PARKING_LOT[${i}, reg]}" == $2 ]; then
        let INDEX=$i+1
        printf "%d\n" $INDEX
        break
      fi
    done
    if [ "$INDEX" == -1 ]; then
      printf "Not found\n";
    fi
  else
    echo "Please insert the right command";
  fi
}

if [ $# -eq 0 ]
then
  TYPE="type"
  echo "--- To stop the interactive mode, please type q ---"
 
  while [[ $TYPE != ?(q|Q) ]]; do
    echo "Input: "
    read TYPE; echo ""
    if [[ $TYPE != ?(q|Q) ]]; then
      read -ra COMMANDS <<< "$TYPE"
      IS_INTERACTIVE=1
      COUNT=${#COMMANDS[@]}
      setup_command $COUNT "${COMMANDS[@]}"
      echo ""
    fi
  done
else
  FILE_NAME="$1"
  while read -r LINE; do
    read -ra COMMANDS <<< "$LINE"
    COUNT=${#COMMANDS[@]}
    setup_command $COUNT "${COMMANDS[@]}"
  done < "$FILE_NAME"
fi
