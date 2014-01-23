#!/bin/bash
CURRENT_DIR=$(pwd);

# Create import dir
SSP_DIR="${CURRENT_DIR}/ssp-git-conversion"

function importSvnToGit {
	rm -rf $SSP_DIR
	mkdir $SSP_DIR
	cd $SSP_DIR

	# @todo patch authors
	# Import old svn repo into git
	svn2git --verbose http://simplesamlphp.googlecode.com/svn/
}

function createFilteredModule {
	MODULE_PATH=$1
	MODULE_EXPORT_DIR="$CURRENT_DIR/ssp-modules-git-conversion/${MODULE_PATH}"
	echo "Filtering module {$MODULE_PATH} to ${MODULE_EXPORT_DIR}"

	echo "Created a filtered export of module only"
	rm -rf $MODULE_EXPORT_DIR;
	git clone $SSP_DIR $MODULE_EXPORT_DIR
	cd $MODULE_EXPORT_DIR
	echo "Filter only ${MODULE_PATH} dir"
	git filter-branch -f --subdirectory-filter ${MODULE_PATH} --prune-empty -- --all

	# Note: Temporary disabled to speed up development, should be enabled	
	# Remove all Svn id's (caused by using an svn export)	echo "Remove svn id's"
	#git filter-branch -f --tree-filter "grep -rl '\$Id' --include=*.php | xargs sed -i s/\\\$Id[^\$]*\\\\$/\\\$Id\\\$/g > /dev/null 2>&1 || true" -- --all
}

# Note: Enable this once to import the current state of the SSP svn repo, this takes a few minutes so it is disabled by default
#importSvnToGit

cd $SSP_DIR
for modulePath in modules/*
do
 createFilteredModule $modulePath
done
