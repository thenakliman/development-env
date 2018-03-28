GIT_TEMPLATE_DIRECTORY="$HOME/.git-templates"

echo "Git template directory $GIT_TEMPLATE_DIRECTORY"

echo "Initialize git repository to use git template directory"
git config --global init.templatedir $GIT_TEMPLATE_DIRECTORY

echo "Create git template hooks directory"
mkdir -p $GIT_TEMPLATE_DIRECTORY/hooks

echo "Provide a pre commit hook, which link to actual hooks on commit"
cat << 'EOF' > $GIT_TEMPLATE_DIRECTORY/hooks/pre-commit
rm $PWD/.git/hooks/pre-commit

# If hooks directory exist in git repository
if [ -d "git/hooks" ]; then
    cd .git/hooks
    ln -s ../../git/hooks/*

    # If pre commit hook exist then execute it
    if [ -e "./pre-commit" ]; then
        ./pre-commit
    fi
fi

EOF

echo "Give execute permission to pre-commit hook"
chmod a+x $GIT_TEMPLATE_DIRECTORY/hooks/pre-commit
