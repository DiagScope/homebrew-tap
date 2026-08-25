# DiagScope Homebrew Tap

Install [DiagScope](https://github.com/DiagScope/diagscope) via Homebrew.

## Install

```bash
brew tap DiagScope/tap
brew install diagscope
```

## Usage

```bash
# Analyze a Spring / Quarkus project
diagscope scan --project /path/to/project

# Plain Java or Kotlin (no framework annotations)
diagscope scan --project /path/to/project --entrypoint PUBLIC_METHOD

# Gate CI — fail on errors in files changed since base branch
diagscope scan --project . --changed-since origin/main --fail-on ERROR

# Explore the rule catalog
diagscope rules
diagscope explain SILENT_CATCH
```

## Requirements

- macOS (Intel or Apple Silicon)
- Java 25 is installed automatically as a dependency via `openjdk@25`

## Update

```bash
brew update && brew upgrade diagscope
```
