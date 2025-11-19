#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/openai/codex"
TOOL_NAME="codex"
TOOL_TEST="codex --help"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if codex is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3-
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	# Detect OS
	case "$(uname -s)" in
	Darwin) os="apple-darwin" ;;
	Linux) os="unknown-linux-gnu" ;;
	*)
		fail "Unsupported OS: $(uname -s)"
		;;
	esac

	# Detect architecture
	case "$(uname -m)" in
	x86_64) arch="x86_64" ;;
	arm64 | aarch64) arch="aarch64" ;;
	*)
		fail "Unsupported architecture: $(uname -m)"
		;;
	esac

	# Fetch release metadata
	local release
	release=$(curl -s \
		"https://api.github.com/repos/openai/codex/releases/tags/${version}")

	echo "$release" | jq -e '.assets' >/dev/null 2>&1 ||
		exit 0

	# Select correct .tar.gz asset for OS + arch
	url=$(
		echo "$release" |
			jq -r --arg arch "$arch" --arg os "$os" '
	        .assets[]
	        | select(.name | type == "string")
	        | select(.name | startswith("codex-"))
	        | select(.name | test("^codex-" + $arch + "-" + $os + "\\.tar\\.gz$"))
	        | .browser_download_url
	      ' |
			head -n 1
	)

	# If version exists but architecture is not available, treat as "not installable"
	if [ -z "$url" ]; then
		exit 0
	fi

	echo "* Downloading $TOOL_NAME release $version ($arch-$os)..."
	curl "${curl_opts[@]}" -o "$filename" -L "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"

		shopt -s nullglob
		codex_paths=("$ASDF_DOWNLOAD_PATH"/codex-*)
		shopt -u nullglob

		# If no matching files exist, exit cleanly
		if [ ${#codex_paths[@]} -eq 0 ]; then
			exit 0
		fi

		cp -r "$ASDF_DOWNLOAD_PATH"/codex-* "$install_path"/codex

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
