#!/bin/dash

# ==============================================================================
# test05.sh
# Testing the commit -a flag
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



# Create a new file.
echo "line 1" > file_2

# add file to the repository staging area

cat > "$expected_output" <<EOF
EOF

tigger-add file_2 > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# append line 2 to file_2
echo "line 2" >> file_2

# now use commit -a flag

cat > "$expected_output" <<EOF
Committed as commit 1
EOF


tigger-commit -a -m 'second commit' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# now tigger show should show 
# line 1 
# line 2 

cat > "$expected_output" <<EOF
line 1
line 2
EOF

tigger-show 1:file_2 > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0