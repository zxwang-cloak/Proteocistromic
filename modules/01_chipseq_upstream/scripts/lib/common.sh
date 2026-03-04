#!/usr/bin/env bash
set -euo pipefail

# Print an informative log message with a timestamp.
log() {
    echo "[$(date '+%F %T')] $*"
}

# Exit with an error message.
die() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Ensure that a command is available in PATH.
require_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found in PATH: $cmd"
}

# Ensure that a file exists.
require_file() {
    local filepath="$1"
    [[ -f "$filepath" ]] || die "Required file not found: $filepath"
}

# Ensure that a directory exists.
require_dir() {
    local dirpath="$1"
    [[ -d "$dirpath" ]] || die "Required directory not found: $dirpath"
}

# Resolve a path against a base directory.
resolve_relative_path() {
    local input_path="$1"
    local base_dir="$2"

    if [[ "$input_path" = /* ]]; then
        printf "%s\n" "$input_path"
    else
        realpath -m "${base_dir}/${input_path}"
    fi
}

# Load a shell configuration file.
load_config() {
    local config_file="$1"
    require_file "$config_file"

    CONFIG_FILE="$(abs_path "$config_file")"
    CONFIG_DIR="$(cd "$(dirname "$CONFIG_FILE")" && pwd)"
    PROJECT_DIR="$(cd "${CONFIG_DIR}/.." && pwd)"

    # shellcheck disable=SC1090
    source "$CONFIG_FILE"

    local path_var
    for path_var in RAW_DIR OUT_DIR BOWTIE2_INDEX GENOME_FASTA CHROM_SIZES BLACKLIST_BED PICARD_JAR MEME_DB_1 MEME_DB_2 MEME_DB_3; do
        if [[ -n "${!path_var:-}" ]]; then
            printf -v "$path_var" '%s' "$(resolve_relative_path "${!path_var}" "$PROJECT_DIR")"
        fi
    done
}

# Ensure that one or more config variables are defined and non-empty.
require_vars() {
    local var_name
    for var_name in "$@"; do
        [[ -n "${!var_name:-}" ]] || die "Required config variable is missing or empty: $var_name"
    done
}

# Ensure that a Bowtie2 index exists.
check_bowtie2_index() {
    local index_base="$1"
    compgen -G "${index_base}"'*.bt2*' >/dev/null || die "Bowtie2 index files were not found for base path: $index_base"
}

# Create a directory if it does not exist.
ensure_dir() {
    local dirpath="$1"
    mkdir -p "$dirpath"
}

# Resolve an absolute path.
abs_path() {
    local target="$1"
    realpath "$target"
}
