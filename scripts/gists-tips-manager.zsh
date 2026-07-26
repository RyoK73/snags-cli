#!/usr/bin/env zsh

typeset -g SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
typeset -g REPO_DIR="$(realpath "${SCRIPT_DIR}/../")"
typeset -g ASSETS_JSON="${REPO_DIR}/assets/assets.json"
typeset -g TIPS_DIR="${REPO_DIR}/tips"
typeset -g TIPS_GIST_FILTER='\[Tips\]'

function print-launch-message() {
  setopt local_options err_exit pipe_fail
  local title=$1 subtitle=$2
  gum style \
    --foreground="#ffffff" --border-foreground="#00b5cb" \
    --border=double --align=center \
    --width=50 --margin="1 2" --padding="2 4" \
    "$title" "$subtitle"
}

# tip_dirにある*.meta.yamlとそれ以外のコンテンツファイルをそれぞれ1つずつ特定する
function resolve-tip-files() {
  setopt local_options err_exit pipe_fail
  local tip_dir=$1
  local f
  for f in "${tip_dir}"/*(.N); do
    if [[ "$f" == *.meta.yaml ]]; then
      echo "meta:${f}"
    else
      echo "content:${f}"
    fi
  done
}

# gist_idが空ならgh gist createで新規作成しmeta.yamlに書き戻す、あればgh gist editで上書きする
function upload-tip() {
  setopt local_options err_exit pipe_fail
  local tip_dir=$1
  local meta_file content_file line

  while IFS= read -r line; do
    case "${line}" in
    meta:*) meta_file="${line#meta:}" ;;
    content:*) content_file="${line#content:}" ;;
    esac
  done < <(resolve-tip-files "${tip_dir}")

  local gist_id="$(yq -r '.gist_id' "${meta_file}")"
  local title="$(yq -r '.title' "${meta_file}")"

  if [[ -z "${gist_id}" || "${gist_id}" == "null" ]]; then
    local gist_url="$(gh gist create --public --desc "[Tips] ${title}" "${content_file}" "${meta_file}")"
    local new_gist_id="${gist_url:t}"
    yq -i -y --arg gist_id "${new_gist_id}" '.gist_id = $gist_id' "${meta_file}"
    echo "gistを作成しました: ${gist_url}"
  else
    gh gist edit "${gist_id}" --filename "$(basename "${content_file}")" "${content_file}"
    gh gist edit "${gist_id}" --filename "$(basename "${meta_file}")" "${meta_file}"
    echo "gist(${gist_id})を更新しました"
  fi
}

# 補助関数(tip-editとは別役割)
# $EDITORでコンテンツファイルを開き、正常終了した場合のみアップロード確認する
# （$EDITORが異常終了した場合はerr_exitオプションによりここで処理が止まり、アップロードされない）
function edit-and-maybe-upload() {
  setopt local_options err_exit pipe_fail
  local tip_dir=$1 content_file=$2

  if ! gum confirm "${EDITOR}で開きますか？"; then
    echo "${tip_dir} に作成しました"
    return
  fi

  "${EDITOR}" "${tip_dir}/${content_file}"

  if gum confirm "gistにアップロードしますか？"; then
    upload-tip "${tip_dir}"
  fi
}

function tip-new() {
  setopt local_options err_exit pipe_fail
  local assets_category="$(jq -r '.category | sort | .[]' "${ASSETS_JSON}")"
  local assets_language="$(jq -r '.language | sort | .[].name' "${ASSETS_JSON}")"

  # 対話開始
  print-launch-message "Let's Create Tips !" "Choose Tips Option !!"

  local filename="$(gum input --placeholder=ファイル名を入力してください)"
  local title="$(gum input --placeholder=タイトルを入力してください)"
  local category="$(gum filter --header=タグを選んでください --no-limit <<<"${assets_category}")"

  local language="$(gum filter --header=言語を選んでください <<<"${assets_language}")"

  local extension="$(jq -r --arg lang "${language}" '.language[] | select(.name==$lang) | .ext' "${ASSETS_JSON}")" # ファイル拡張子を特定

  local created_date="$(date "+%Y-%m-%d")"
  local category_yaml="[$(echo "${category}" | paste -sd, - | sed 's/,/, /g')]" # yaml形式の配列に変換

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
  setopt local_options err_exit pipe_fail
  gh gist list --filter "${TIPS_GIST_FILTER}" |
    gum table --separator=$'\t' --columns="ID,Description,Files,Visibility,UpdatedAt" "$@"

}

function tip-list() {
  setopt local_options err_exit pipe_fail
  print-launch-message "Your Tips !" "Browse Tips List !!"

  browse-gist-list --print
}

function tip-edit() {
  setopt local_options err_exit pipe_fail
  print-launch-message "Edit Tips !" "Choose Tips to Edit !!"

  local selected_id="$(browse-gist-list --return-column=1)"

  if [[ -z "${selected_id}" ]]; then
    echo "編集対象が選択されませんでした"
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
    # ローカルに未取得（他PC等でアップロードされた）tipなのでgist_cloneで取得する
    local tmp_dir="$(mktemp -d)"
    gh gist clone "${selected_id}" "${tmp_dir}"

    local remote_meta remote_content line
    while IFS= read -r line; do
      case "${line}" in
      meta:*) remote_meta="${line#meta:}" ;;
      content:*) remote_content="${line#content:}" ;;
      esac
    done < <(resolve-tip-files "${tmp_dir}")

    local created_at="$(yq -r '.created_at' "${remote_meta}")"
    local stem="$(basename "${remote_content}" | sed -E 's/\.[^.]+$//')"
    tip_dir="${TIPS_DIR}/${created_at}-${stem}"

    mkdir -p "${TIPS_DIR}"
    mv "${tmp_dir}" "${tip_dir}"
  fi

  local meta_file content_file line
  while IFS= read -r line; do
    case "${line}" in
    meta:*) meta_file="${line#meta:}" ;;
    content:*) content_file="${line#content:}" ;;
    esac
  done < <(resolve-tip-files "${tip_dir}")

  edit-and-maybe-upload "${tip_dir}" "$(basename "${content_file}")"
}
