#!/bin/dash

# ==============================================================================
# test06.sh
# Testing tigger-rm functionality
# ==============================================================================

# add the current directory to the PATH so scripts
# can still be executed from it after we cd

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.

expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.

trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# Create tigger repository

cat > "$expected_output" <<EOF
Initialized empty tigger repository in .tigger
EOF

tigger-init > "$actual_output" 2>&1


if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# Create a simple file.
echo "line 1" > new_file

# add a file to the repository staging area

cat > "$expected_output" <<EOF
EOF

tigger-add new_file > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


# now remove the file in the working dir and index
cat > "$expected_output" <<EOF
EOF

tigger-rm --force new_file  > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


# so now the file should not exist in the index

cat > "$expected_output" <<EOF
tigger-show: error: 'new_file' not found in index
EOF

tigger-show :new_file > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0