<div align="center">

# asdf-codex [![Build](https://github.com/TimothyMerlin/asdf-codex/actions/workflows/build.yml/badge.svg)](https://github.com/TimothyMerlin/asdf-codex/actions/workflows/build.yml) [![Lint](https://github.com/TimothyMerlin/asdf-codex/actions/workflows/lint.yml/badge.svg)](https://github.com/TimothyMerlin/asdf-codex/actions/workflows/lint.yml)

[codex](https://github.com/openai/codex) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`, `git`, and `jq` are required by the install script.
- Optional: set `GITHUB_API_TOKEN` to raise the GitHub rate limit when listing versions or downloading releases.

# Install

Plugin:

```shell
asdf plugin add codex
# or
asdf plugin add codex https://github.com/TimothyMerlin/asdf-codex.git
```

codex:

```shell
# Show all installable versions
asdf list-all codex

# Install specific version
asdf install codex latest

# Set a version globally (on your ~/.tool-versions file)
asdf global codex latest

# Now codex commands are available
codex --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/TimothyMerlin/asdf-codex/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Merlin Scherer](https://github.com/TimothyMerlin/)
