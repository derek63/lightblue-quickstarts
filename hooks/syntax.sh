#!/bin/sh

# The propose of this script is to validate the .pp (puppet) and erb files before the commit
# The script below is based on the Puppet Cookbook 
# This file (and others in this folder) needs to be set in each hooks folder from .git as it is not in version control ( http://stackoverflow.com/a/4457124/1322969 )


syntax_errors=0
error_msg=$(mktemp /tmp/error_msg.XXXXXX)
against=HEAD

# Get list of new/modified manifest and template files to check (in git index)
for indexfile in `git diff-index --diff-filter=AM --name-only --cached $against | egrep '\.(pp|erb)'`
do
    # Don't check empty files
    if [ `git cat-file -s :0:$indexfile` -gt 0 ]
    then
        case $indexfile in
            *.pp )
                # Check puppet manifest syntax
                git cat-file blob :0:$indexfile | puppet parser validate > $error_msg ;;
            *.erb )
                # Check ERB template syntax
                git cat-file blob :0:$indexfile | erb -x -T - | ruby -c 2> $error_msg > /dev/null ;;
        esac
        if [ "$?" -ne 0 ]
        then
            echo -n "$indexfile: "
            cat $error_msg
            syntax_errors=`expr $syntax_errors + 1`
        fi
    fi
done

rm -f $error_msg

if [ "$syntax_errors" -ne 0 ]
then
    echo "Error: $syntax_errors syntax errors found, aborting commit."
    exit 1
fi
