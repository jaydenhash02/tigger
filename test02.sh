#!/bin/dash


# ==============================================================================
# test02.sh
# Test the tigger-log command upon the first commit.
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


# commit the file to the repository history

cat > "$expected_output" <<EOF
Committed as commit 0
EOF


tigger-commit -m 'first commit' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


# the first commit has been made at this point

# now test the tigger-log
cat > "$expected_output" <<EOF
0 first commit
EOF

tigger-log > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0