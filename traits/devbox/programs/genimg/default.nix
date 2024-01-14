{ pkgs, ... }: with pkgs;
let
  genimg = writeShellScriptBin "genimg" ''
    temp_file=$(mktemp)
    trap 'rm -f -- "$temp_file"' EXIT

    curl https://api.openai.com/v1/images/generations \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d '{
        "model": "dall-e-3",
        "prompt": "'"$1"'",
        "n": 1,
        "size": "1792x1024"
      }' > "$temp_file"

    echo
    echo "Original prompt: $1"
    echo "Revised prompt: $(cat $temp_file | ${jq}/bin/jq -r '.data[0].revised_prompt')"
    echo

    prompt_title=$(echo "$1" | sed -e 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
    image_url=$(cat "$temp_file" | ${jq}/bin/jq -r '.data[0].url')

    open "$image_url"
    ${wget}/bin/wget -O "$prompt_title-$(date '+%s').png" "$image_url"
  '';
in
{
  home.packages = [ genimg ];
}
