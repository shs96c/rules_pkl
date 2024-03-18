#!/usr/bin/env bash
# Create symlinks from the output root to the current folder.
# This allows Pkl to consume generated files.

expected_output=$1
is_test=$2
format_args=$3
entrypoints=$4
multiple_outputs=$5
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
  if [ "$multiple_outputs" == "true" ]; then
    mkdir _generated_files
    output_args=( "--multiple-file-output-path" "_generated_files")
  else
    output_args=("--output-path" "$expected_output")
  fi
else
    output_args=()
fi

output=$($executable "$command" $format_args "${properties_and_expressions[@]}" $expression_args --working-dir "${working_dir}" --cache-dir "../cache" "${output_args[@]}" $entrypoints)

ret=$?
if [[ $ret != 0 ]]; then
  if [ "$command" == eval ]; then
    echo "Failed processing PKL configuration with entrypoint(s) '$entrypoints' (PWD: $(pwd)):" >&2
    echo "${output}"
  else
    echo "Test failed."
    echo "${output}"
  fi
  exit 1
fi


if [[ "$command" == eval ]]; then
# Move the output from the working dir to where Bazel expects it
  if [ "$multiple_outputs" == true ]; then
       mv "${working_dir}/_generated_files"/* "$expected_output"

  else
     mv "${working_dir}/${expected_output}" "$expected_output"
  fi
fi
