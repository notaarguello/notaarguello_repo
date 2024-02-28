postNoteToObsidian() {
  local note_path=$1
  local note_name=$2
  local note_content="$3"
  local api_key="${OBSIDIAN_NOTES_API_KEY}"
  
  # URL encode note_path and note_name
  local encoded_note_path=$(echo "$note_path" | jq -sRr @uri)
  local encoded_note_name=$(echo "$note_name" | jq -sRr @uri)

  curl -X 'PUT' \
    "https://127.0.0.1:27124/vault/${encoded_note_path}/${encoded_note_name}.md" \
    -H 'accept: */*' \
    -H 'Content-Type: text/markdown' \
    -H "Authorization: Bearer ${api_key}" \
    -d "$note_content"
}

patchContentToDailyNoteObsidian() {
  local header="$1"
  local content="$2"
  local api_key="${OBSIDIAN_NOTES_API_KEY}"

  curl -X 'PATCH' \
    'https://127.0.0.1:27124/periodic/daily/' \
    -H 'accept: */*' \
    -H "Heading: ${header}" \
    -H 'Content-Insertion-Position: end' \
    -H 'Content-Insertion-Ignore-Newline: false' \
    -H 'Heading-Boundary: ::' \
    -H 'Content-Type: text/markdown' \
    -H "Authorization: Bearer ${api_key}" \
    -d "$content"
}


