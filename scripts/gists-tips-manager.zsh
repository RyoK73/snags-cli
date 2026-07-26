#!/usr/bin/env zsh

typeset -g SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
typeset -g REPO_DIR="$(realpath "${SCRIPT_DIR}/../")"
typeset -g ASSETS_JSON="${REPO_DIR}/assets/assets.json"
typeset -g TIPS_DIR="${REPO_DIR}/tips"
typeset -g TIPS_GIST_FILTER='\[Tips\]'
typeset -g meta_file content_file

function print-launch-message() {
	setopt local_options pipe_fail warn_create_global

	local title=$1 subtitle=$2
	gum style \
		--foreground="#ffffff" --border-foreground="#00b5cb" \
		--border=double --align=center \
		--width=50 --margin="1 2" --padding="2 4" \
		"$title" "$subtitle"
}

# Identify one *.meta.yaml file and one content file in tip_dir
function resolve-tip-files() {
	setopt local_options pipe_fail warn_create_global

	local tip_dir=$1
	local f
	for f in "${tip_dir}"/*(.N); do
		if [[ "$f" == *.meta.yaml ]]; then
			meta_file="${f}"
		else
			content_file="${f}"
		fi
	done
}

# If gist_id is empty, create a new gist with gh gist create and write it back to meta.yaml; otherwise overwrite with gh gist edit
function upload-tip() {
	setopt local_options pipe_fail warn_create_global

	local tip_dir=$1
	resolve-tip-files "${tip_dir}"

	local gist_id="$(yq -r '.gist_id' "${meta_file}")"
	local title="$(yq -r '.title' "${meta_file}")"

	if [[ -z "${gist_id}" || "${gist_id}" == "null" ]]; then
		local gist_url
		gist_url="$(gh gist create --public --desc "[Tips] ${title}" "${content_file}" "${meta_file}")" || {
			echo "Error: Failed to create gist"
			return
		}
		local new_gist_id="${gist_url:t}"
		yq -i -y --arg gist_id "${new_gist_id}" '.gist_id = $gist_id' "${meta_file}"
		echo "Gist created: ${gist_url}"
	else
		gh gist edit "${gist_id}" --filename "$(basename "${content_file}")" "${content_file}" || {
			echo "Error: Failed to update gist content"
			return
		}
		gh gist edit "${gist_id}" --filename "$(basename "${meta_file}")" "${meta_file}" || {
			echo "Error: Failed to update gist metadata"
			return
		}
		echo "Gist (${gist_id}) updated"
	fi
}

# Helper function (distinct role from tip-edit)
# Opens the content file with $EDITOR and only prompts for upload confirmation on successful exit
# (If $EDITOR exits abnormally, halts processing here, so no upload happens)
function edit-and-maybe-upload() {
	setopt local_options pipe_fail warn_create_global

	local tip_dir=$1 content_file=$2

	if ! gum confirm "Open with ${EDITOR}?"; then
		echo "Created at ${tip_dir}"
		return
	fi

	"${EDITOR}" "${tip_dir}/${content_file}" || {
		echo "Error: Editor exited abnormally"
		return
	}

	if gum confirm "Upload to gist?"; then
		upload-tip "${tip_dir}"
	fi
}

function tip-new() {
	setopt local_options pipe_fail warn_create_global
	local assets_category="$(jq -r '.category | sort | .[]' "${ASSETS_JSON}")"
	local assets_language="$(jq -r '.language | sort | .[].name' "${ASSETS_JSON}")"

	# Start interactive prompts
	print-launch-message "Let's Create Tips !" "Choose Tips Option !!"

	local filename
	filename="$(gum input --placeholder="Enter a filename")" || {
		echo "canceled"
		return
	}

	local title
	title="$(gum input --placeholder="Enter a title")" || {
		echo "canceled"
		return
	}

	local category
	category="$(gum filter --no-limit --header="Choose a category" <<<"${assets_category}")" || {
		echo "canceled"
		return
	}

	local language
	language="$(gum filter --header="Choose a language" <<<"${assets_language}")" || {
		echo "canceled"
		return
	}

	local extension
	extension="$(jq -r --arg lang "${language}" '.language[] | select(.name==$lang) | .ext' "${ASSETS_JSON}")" || {
		echo "Error: Failed to resolve extension"
		return
	}
	# Determine the file extension

	local created_date="$(date "+%Y-%m-%d")"
	local category_yaml="[$(echo "${category}" | paste -sd, - | sed 's/,/, /g')]" # Convert to a YAML array

	local tip_name="${created_date}-${filename}"
	local tip_dir="${TIPS_DIR}/${tip_name}"

	mkdir -p "${tip_dir}"
	touch "${tip_dir}/${filename}.${extension}"
	cat <<-EOF >"${tip_dir}/${filename}.meta.yaml"
		title: ${title}
		category: ${category_yaml}
		created_at: ${created_date}
		gist_id: ""
	EOF

	edit-and-maybe-upload "${tip_dir}" "${filename}.${extension}"
}

function browse-gist-list() {
	setopt local_options pipe_fail warn_create_global
	gh gist list --filter "${TIPS_GIST_FILTER}" |
		gum table --separator=$'\t' --columns="ID,Description,Files,Visibility,UpdatedAt" "$@"

	if ((pipestatus[1] != 0)); then
		echo "Error: Failed to fetch gist list"
		return 1
	fi
}

function tip-list() {
	setopt local_options pipe_fail warn_create_global
	print-launch-message "Your Tips !" "Browse Tips List !!"

	browse-gist-list --print
}

function tip-edit() {
	setopt local_options pipe_fail warn_create_global
	print-launch-message "Edit Tips !" "Choose Tips to Edit !!"

	local selected_id
	selected_id="$(browse-gist-list --return-column=1)"

	if [[ -z "${selected_id}" ]]; then
		echo "No item selected to edit"
		return
	fi

	local tip_dir="" dir meta
	for dir in "${TIPS_DIR}"/*(/N); do
		meta=("${dir}"/*.meta.yaml(N))
		[[ -n "${meta[1]}" ]] || continue
		if [[ "$(yq -r '.gist_id' "${meta[1]}")" == "${selected_id}" ]]; then
			tip_dir="${dir}"
			break
		fi
	done

	if [[ -z "${tip_dir}" ]]; then
		# Not yet fetched locally (uploaded from another PC etc.), so fetch it with gist clone
		local tmp_dir="$(mktemp -d)"
		gh gist clone "${selected_id}" "${tmp_dir}" || {
			echo "Error: Failed to clone gist"
			return
		}

		# resolve remote meta,content files
		resolve-tip-files "${tmp_dir}"

		local created_at="$(yq -r '.created_at' "${meta_file}")"
		local stem="$(basename "${content_file}" | sed -E 's/\.[^.]+$//')"
		tip_dir="${TIPS_DIR}/${created_at}-${stem}"

		mkdir -p "${TIPS_DIR}"
		mv "${tmp_dir}" "${tip_dir}"
	fi

	resolve-tip-files "${tip_dir}"

	edit-and-maybe-upload "${tip_dir}" "$(basename "${content_file}")"
}
