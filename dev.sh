#/bin/bash
function dev(){
	projectspath=${devsearch_projectspath:-$HOME/Dropbox/Share/Development}
	# check if foler exists
	if [ ! -d ${projectspath} ]; then
		echo "Error: Development folder \"${projectspath}\" doesn't exist"
		return 1
	fi

	# Check if argument (search term) is set
	if [ ${#} -ne 0 ]; then
		# Arguments given => search for term
		# Store results in variable for later use
		results=$(find ${projectspath}/ -name \*${*}\* -type d -maxdepth 1 -exec basename {} \;)

		# Check if variable is not empty
		if [[ $results == "" ]]; then
			# 0 projects found
			projectscount="0"
		# Count the projects
		else
			# n projects found
			projectscount=$(echo "${results}" | wc -l | tr -d ' ')
		fi

		# Check project counts
		if [[ ${projectscount} == "0" ]]; then
			echo "Error: Couldn't find any project results for in \"${*}\""
			return 1
		elif [[ ${projectscount} == "1" ]]; then
			echo "Info: Only one result found while searching for \"${*}\". cd into \"${results}\"..."
			cd ${projectspath}/${results}
		else
			echo "Info: Found ${projectscount} result while searching for \"${*}\":"
			# For each result ...
				for project in ${results}; do
					# ... display project name
				echo ${project}
			done | column
				return 0
		fi

	# No arguments => display projects
	else
		# Store projects in variable for later use
		projects=$(ls -l ${projectspath} | tail -n +2 | awk '{ print $9" "$10" "$11 }')

		# Check if variable is not empty
		if [[ $projects == "" ]]; then
			# 0 projects found
			projectscount="0"
		# Count the projects
		else
			# n projects found
			projectscount=$(echo "${projects}" | wc -l | tr -d ' ')
		fi

		# Check project counts
		if [[ ${projectscount} == "0" ]]; then
			echo "Error: Couldn't find any projects in \"${projectspath}\""
			return 1
		else
			echo "Info: ${projectscount} available projects:"
			# For each result ...
				for project in ${projects}; do
					# ... display project name
				echo ${project}
			done | column
				return 0
		fi
	fi
}

_dev()
{
		case ${COMP_CWORD} in
		1)
		# Backup $IFS, adjust to support whitespaces
		OLDIFS=$IFS IFS=$(echo -en "\n\b")
		local projects
		cur=${COMP_WORDS[COMP_CWORD]}
		local projects="$(for x in `find ${devsearch_projectspath} -name "*${cur}*" -not -path '*/\.*' -type d -maxdepth 1 -exec basename {} \; | grep -v "${devsearch_projectspath##*/}"`; do echo ${x}; done)"
		COMPREPLY=( $( compgen -W "${projects}" -- ${cur} ) )
		# Restore $IFS
		IFS=$OLDIFS
				;;
		*)
				COMPREPLY=()
				;;
		esac
}
complete -F _dev dev
