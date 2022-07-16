#!/bin/dash

# ==============================================================================
# test08.sh
# Testing tigger-merge
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


# make a branch b1
cat > "$expected_output" <<EOF
EOF

tigger-branch b1 > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


# now activate tigger-branch to show the list of branches
cat > "$expected_output" <<EOF
b1
master
EOF

tigger-branch > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


# checkout to the branch
cat > "$expected_output" <<EOF
Switched to branch 'b1'
EOF

tigger-checkout b1 > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


# make a new file
echo "line 2" > file_2

# add new file to the repository staging area

cat > "$expected_output" <<EOF
EOF

tigger-add file_2 > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# commit the file to the new branch repository history

cat > "$expected_output" <<EOF
Committed as commit 1
EOF


tigger-commit -m 'second commit' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


# checkout back to master
cat > "$expected_output" <<EOF
Switched to branch 'master'
EOF

tigger-checkout master > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# merge b1 into master
cat > "$expected_output" <<EOF
Fast-forward: no commit created
EOF

tigger-merge b1 -m merge-message  > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# now file_2 should exist too
cat > "$expected_output" <<EOF
line 2
EOF

tigger-show 1:file_2 > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0