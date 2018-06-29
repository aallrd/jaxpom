#/usr/bin/env bash

set -euo pipefail

function __list_jaxbcontext_file() {
	__jaxb_files=($(grep --include=*.java --exclude=${0##*/} -lIr "JAXBContext" ./* | xargs))
	return 0
}

function __find_project_pom() {
	local file dir pom
	file="${1}"
	dir="$(dirname "${file}")"
	while [[ "${dir}" != "." ]]; do
		pom="${dir}/pom.xml"
		if [[ -e "${pom}" ]]; then
			__poms=(${__poms[@]:-} ${pom})
			break
		else
			dir="$(dirname "${dir}")"
		fi
	done
	return 0
}


function __add_jaxb_dependency() {
	local pom
	pom="${1}"
	p4 edit "${pom}"
	# jaxb-activation
	xml ed --inplace \
		--subnode "/_:project/_:dependencies" --type elem -n dependency -v "" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n groupId -v "javax.activation" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n artifactId -v "activation" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n version -v "1.1.1" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n scope -v "provided" \
		"${pom}"
	if [[ ${?} -ne 0 ]]; then
		echo "Failed to append the jaxb-activation dependency to ${pom}" ; return 1;
	fi

	# jaxb-api
	xml ed --inplace \
		--subnode "/_:project/_:dependencies" --type elem -n dependency -v "" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n groupId -v "javax.xml.bind" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n artifactId -v "jaxb-api" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n version -v "2.3.0" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n scope -v "provided" \
		"${pom}"
	if [[ ${?} -ne 0 ]]; then
		echo "Failed to append the jaxb-api dependency to ${pom}" ; return 1;
	fi

	# jaxb-impl
	xml ed --inplace \
		--subnode "/_:project/_:dependencies" --type elem -n dependency -v "" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n groupId -v "com.sun.xml.bind" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n artifactId -v "jaxb-impl" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n version -v "2.3.0" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n scope -v "provided" \
		"${pom}"
	if [[ ${?} -ne 0 ]]; then
		echo "Failed to append the jaxb-impl dependency to ${pom}" ; return 1;
	fi

	# jaxb-core
	xml ed --inplace \
		--subnode "/_:project/_:dependencies" --type elem -n dependency -v "" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n groupId -v "com.sun.xml.bind" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n artifactId -v "jaxb-core" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n version -v "2.3.0" \
		--subnode "/_:project/_:dependencies/dependency[last()]" --type elem -n scope -v "provided" \
		"${pom}"
	if [[ ${?} -ne 0 ]]; then
		echo "Failed to append the jaxb-core dependency to ${pom}" ; return 1;
	fi

	# Prettifying the xml file
	xml ed --inplace "${pom}"
	if [[ ${?} -ne 0 ]]; then
		echo "Failed to prettify the file ${pom}" ; return 1;
	fi

	return 0
}

function __main() {
	command -v xml >/dev/null || { echo "[ERROR] The xmlstarlet command is not available." ; return 1; }
	command -v p4 >/dev/null || { echo "[ERROR] The p4 command is not available." ; return 1; }
	__list_jaxbcontext_file
	for jaxb_file in ${__jaxb_files[@]}; do
		__find_project_pom "${jaxb_file}"
	done
	echo "Unsorted: ${#__poms[@]}"
	__uniq_poms=($(printf "%s\n" "${__poms[@]}" | sort -u))
	echo "Uniq: ${#__uniq_poms[@]}"
	for pom in ${__uniq_poms[@]}; do
		__add_jaxb_dependency "${pom}"
	done
	return 0
}

__main "${@}"
