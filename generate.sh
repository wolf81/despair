#!/bin/bash

# the script directory
DIR="$(dirname "$0")"

DATA_DIR="${DIR}/dat"
TARGET_DIR="${DIR}/gen"

# arrays to manage CSV column names & related type info
COL_NAMES=()
TYPE_INFO=()

# set Internal Field Seperator to: |
OIFS=${IFS}
IFS="|"

function isNumber() {
	awk -v a="$1" 'BEGIN {print (a == a + 0)}';
}

function generateEntity() {
	declare -a FIELDS=(${1})

	local CSV_PATH="${2}"
	local ID=$(echo ${FIELDS[0]} | xargs)
	local TYPE=$(basename ${CSV_PATH/\.csv/})
	local TYPE_DIR="${TARGET_DIR}/${TYPE}"
	local FILE_PATH="${TYPE_DIR}/${ID}.lua"

	# constants for newline and tab - these are escaped for use with awk script
	local nl="$(printf '\nq')"
	local tab="$(printf '\tq')"

	# notify on the entify file we're generating
	echo "${tab%q}${FILE_PATH}"

	# create an entity type directory if none exists already
	mkdir -p "${TYPE_DIR}"

	# generate LUA string for entity file
	S="return {${nl%q}"

	# get field count from array
	local N_FIELDS=${#FIELDS[@]}
	for (( i = 0; i < $N_FIELDS; i++ )); do
		local COL_NAME=${COL_NAMES[i]}
		local TYPE=${TYPE_INFO[i]}
		local VAL=$(echo ${FIELDS[i]} | xargs)

		# based on type, add value as number, array or string
		if [[ $TYPE == number ]]; then
            # assign default value of 0 if not defined			
			if [[ -z ${VAL} ]]; then VAL="0"; fi

			# append to Lua string
			S+="${tab%q}${COL_NAME} = ${VAL},${nl%q}"
		elif [[ $TYPE == array ]]; then
			# variable to store result
			local OUT=""

			# temporary use comma seperator for fields
			IFS=","; 

			# loop through each item in fields
			declare -a VALS=(${FIELDS[i]})
			for VAL in "${VALS[@]}"; do 
				VAL=$(echo $VAL | xargs)
				if [[ `isNumber ${VAL}` == "1" ]]; then
					OUT+="${VAL}, "
				else
					OUT+="'${VAL}', "
				fi 
			done

			# trim comma-space (, ) at the end
			OUT="${OUT%%, }"

			# restore pipe as field separator in order to parse columns properly
			IFS="|"

			# append to Lua string
			S+="${tab%q}${COL_NAME} = { ${OUT} },${nl%q}"
		else
			# append to Lua string
			S+="${tab%q}${COL_NAME} = '${VAL}',${nl%q}"
		fi
	done	

	S+="}"

	# write the LUA entity string to the entity file
	echo "${S}" > "${FILE_PATH}"
}

function configureColumns() {
	local CSV_FILE="${1}"

	# extract the header rows
	HEADER=$(head -1 $CSV_FILE)
	
	COL_NAMES=()
	TYPE_INFO=()

	# convert column names to lower case and store in array
	for COL in $HEADER
	do
		# trim whitespace
		COL=$(echo $COL| xargs)

		# parse header type annotations: 
		# - #: number
		# - @: array of strings
		# - $: string
		# default is string if no annotation provided
		if [[ $COL == *\$ ]] ; then
			TYPE_INFO+=(string)
			COL=${COL%?} # remove last character
		elif [[ $COL == *\# ]] ; then
			TYPE_INFO+=(number)
			COL=${COL%?} # remove last character
		elif [[ $COL == *\@ ]] ; then
			TYPE_INFO+=(array)
			COL=${COL%?} # remove last character
		else
			TYPE_INFO+=(string)
		fi

		# store the column names in an array
		COL_NAMES+=(`echo $COL | awk '{ print tolower($1) }'`)
	done
}

function parseCSV() {
	local FILE_PATH="${1}"

	# notify on the CSV file we're processing
	echo "${FILE_PATH}"

	# add newline at end of file in order to parse CSV properly
	[[ -n "$(tail -c1 ${FILE_PATH})" ]] && echo >> "${FILE_PATH}"

	{
		# ignore the header line
		read

		# parse remaining lines
		while read -r LINE; do
			# skip empty lines
			[[ -z "${LINE}" ]] && continue

			generateEntity "${LINE}" "${FILE_PATH}"
		done
	} < "${FILE_PATH}"
}

function generateEntities() {
    # clear target directory if exists
	if [[ -d ${TARGET_DIR} ]]; then rm -Rf ${TARGET_DIR}; fi

	# parse CSV files
	for FILE_PATH in "${DATA_DIR}"/*.csv; do
		configureColumns "$FILE_PATH"
		parseCSV "$FILE_PATH"
	done
}

generateEntities

# restore internal field seperator
IFS=$OIFS
