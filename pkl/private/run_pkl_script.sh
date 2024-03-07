#!/usr/bin/env bash
# Create symlinks from the output root to the current folder.
# This allows Pkl to consume generated files.

expected_output=$1
is_test=$2
format_args=$3
entrypoints=$4
output_path_flag_name=$5
working_dir=$6
command=$7
executable=$8
symlinks_json_file_path=$9
symlinks_executable=${10}

properties_and_expressions=()
num_args=$#
for ((j=11;j<=num_args;j++)); do
    val=${!j}
    properties_and_expressions+=("$val")
done

"$symlinks_executable" "$symlinks_json_file_path"

ret=$?
if [[ $ret != 0 ]]; then
    echo "Failed creating dependency symlinks in Pkl rule setup." >&2
    exit 1
fi

if [ "$is_test" == "false" ]; then
    output_args=($output_path_flag_name "$1")
else
    output_args=()
fi
output=$($executable "$command" $format_args "${properties_and_expressions[@]}" $expression_args --working-dir "${working_dir}" --cache-dir "../cache" "${output_args[@]}" $entrypoints)

ret=$?
if [[ $ret != 0 ]]; then
    echo "Failed processing PKL configuration with entrypoint(s) '$entrypoints' (PWD: $(pwd)):" >&2
    echo "${output}"
    exit 1
fi

# Move the output from the working dir to where Bazel expects it
mv "${working_dir}/${expected_output}" "$1"

echo "$output" | grep ❌
ret=$?
if [[ $ret != 0 ]]; then
    exit 0
fi
exit 1