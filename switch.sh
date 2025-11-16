#!/bin/bash

BOLD=`tput bold`
UNDERLINE=`tput smul`
NORMAL=`tput sgr0`
WHITE=`tput setaf 15`
GREY=`tput setaf 8`
RED=`tput setaf 9`
GREEN=`tput setaf 10`

WP_MIN_VERSION="6.0"
WP_MAX_VERSION="$(curl -s https://api.wordpress.org/core/version-check/1.7/ | jq -r '.offers[0].version' | cut -d. -f1,2)"
WP_PATH="--path=public/wp"
WP_PREVIOUS_VERSION="$(wp core version $WP_PATH)"

check_errors() {
	ERRORS=()
	if ! which jq > /dev/null; then
		ERRORS=("${ERRORS[@]}" "==>${WHITE} jq    ${GREY}${UNDERLINE}https://jqlang.github.io/jq/download/${NORMAL}")
	fi
	if ! which mysql > /dev/null; then
		ERRORS=("${ERRORS[@]}" "==>${WHITE} mysql ${GREY}${UNDERLINE}https://dev.mysql.com/downloads/mysql/${NORMAL}")
	fi
	if ! which perl > /dev/null; then
		ERRORS=("${ERRORS[@]}" "==>${WHITE} perl  ${GREY}${UNDERLINE}https://www.perl.org/get.html${NORMAL}")
	fi
	if ! which wp > /dev/null; then
		ERRORS=("${ERRORS[@]}" "==>${WHITE} wp    ${GREY}${UNDERLINE}https://wp-cli.org/#installing${NORMAL}")
	fi
	if [ ${#ERRORS[@]} -gt 0 ]; then
		echo "${RED}${BOLD}Error: ${NORMAL}The following commands were not found:"
		for error in "${ERRORS[@]}"
		do
			echo $"${error}"
		done
		exit 1
	fi
}

download() {
	if [ `which curl` ]; then
		curl -s "$1" > "$2";
	elif [ `which wget` ]; then
		wget -nv -O "$2" "$1"
	fi
}

switch_wp() {
	if ! [ -d $WP_CORE_DIR ]; then
		mkdir -p $WP_CORE_DIR
		wp core download --version=$WP_NEW_VERSION --path=$WP_CORE_DIR
	fi
	echo "${BOLD}${GREEN}Switching to WordPress $WP_NEW_VERSION${NORMAL}"
	rm -rf $DIR/public/wp;
	cp -R $WP_CORE_DIR $DIR/public/wp
	DB_NAME=$(perl -lne 'm{DB_NAME.*?([\w.-]+)} and print $1' $DIR/env.php)
	perl -i -pwe "s|${DB_NAME}|wordpress_${WP_NEW_VERSION}|" $DIR/env.php
}

install_wp() {
	wp db create $WP_PATH > /dev/null 2>&1
	if ! wp core is-installed $WP_PATH; then
		echo "${BOLD}${GREEN}Installing WordPress $WP_NEW_VERSION${NORMAL}"
		wp core install --url="http://wordpress.test" --title="WordPress $WP_NEW_VERSION" --admin_user="dev" --admin_password="dev" --admin_email="dev@geminilabs.io" $WP_PATH
		wp option update welcome 0 $WP_PATH
		wp option update uploads_use_yearmonth_folders 0 $WP_PATH
		wp option update blogdescription "" $WP_PATH
		wp option update permalink_structure "/%postname%/" $WP_PATH
		wp option update show_on_front page $WP_PATH
		wp option update page_on_front 2 $WP_PATH
		wp post delete 1 --force $WP_PATH
		wp post update 2 --post_title=Home --post_name=home --post_content= $WP_PATH
		wp user meta update 1 show_welcome_panel 0 $WP_PATH
	fi
}

install_test_suite() {
	echo "${BOLD}${GREEN}Installing Test Suite for WordPress $WP_NEW_VERSION${NORMAL}"
	if [ ! -d $WP_TESTS_DIR ]; then
		mkdir -p $WP_TESTS_DIR
		svn co --quiet https://develop.svn.wordpress.org/tags/${WP_NEW_VERSION}/tests/phpunit/includes/ $WP_TESTS_DIR/includes
		svn co --quiet https://develop.svn.wordpress.org/tags/${WP_NEW_VERSION}/tests/phpunit/data/ $WP_TESTS_DIR/data
	fi
	rm -f $DIR/tests/current
	ln -s $WP_TESTS_DIR $DIR/tests/current
	DB_NAME=$(perl -lne 'm{DB_NAME.*?([\w.-]+)} and print $1' $DIR/env.php)
	DB_USER=$(perl -lne 'm{DB_USER.*?([\w.-]+)} and print $1' $DIR/env.php)
	DB_PASS=$(perl -lne 'm{DB_PASSWORD.*?([\w.-]+)} and print $1' $DIR/env.php)
	DB_HOST=$(perl -lne 'm{DB_HOST.*?([\w.-]+)} and print $1' $DIR/env.php)
	WP_TEST_CONFIG="$WP_TESTS_DIR/wp-tests-config.php"
	if [ ! -f wp-tests-config.php ]; then
		download https://develop.svn.wordpress.org/tags/${WP_NEW_VERSION}/wp-tests-config-sample.php $WP_TEST_CONFIG
		if [ ! -f "$WP_TEST_CONFIG" ]; then
			echo "${RED}${BOLD}Failed to download wp-tests-config.php${NORMAL}"
			exit 1
		fi
		perl -i -pwe "s|dirname.{22}|'${DIR}/public/wp/'|" $WP_TEST_CONFIG
		perl -i -pwe "s|youremptytestdbnamehere|${DB_NAME}|" $WP_TEST_CONFIG
		perl -i -pwe "s|yourusernamehere|${DB_USER}|" $WP_TEST_CONFIG
		perl -i -pwe "s|yourpasswordhere|${DB_PASS}|" $WP_TEST_CONFIG
		perl -i -pwe "s|localhost|${DB_HOST}|" $WP_TEST_CONFIG
	fi
}

export_db() {
	echo "${BOLD}${GREEN}Exporting Database${NORMAL}"
	# TABLE_PREFIX=$(perl -lne 'm{table_prefix.*?([\w]+)} and print $1' $DIR/env.php)
	# wp db export $DIR/db_$WP_PREVIOUS_VERSION.sql --add-drop-table --tables=$(wp db tables --all-tables-with-prefix --format=csv $WP_PATH) --quiet $WP_PATH
	wp db export $DIR/db_$WP_PREVIOUS_VERSION.sql --add-drop-table --single-transaction --skip-set-charset --set-gtid-purged=OFF --quiet $WP_PATH
}

import_db() {
	echo "${BOLD}${GREEN}Importing Database${NORMAL}"
	mkdir -p $DIR/backups
	# wp db export $DIR/backups/db_$WP_NEW_VERSION.sql $WP_PATH
	# wp db export $DIR/backups/db_$WP_NEW_VERSION.sql --add-drop-table --tables=$(wp db tables --all-tables-with-prefix --format=csv $WP_PATH) $WP_PATH
	wp db export $DIR/backups/db_$WP_NEW_VERSION.sql --add-drop-table --single-transaction --skip-set-charset --set-gtid-purged=OFF --quiet $WP_PATH
	wp db import $DIR/db_$WP_PREVIOUS_VERSION.sql $WP_PATH
	wp option update blogname "WordPress $WP_NEW_VERSION" --quiet $WP_PATH
	wp core update-db --quiet $WP_PATH
	rm $DIR/*.sql
}

check_errors

read -e -p "You are using WordPress ${WP_PREVIOUS_VERSION}. Enter a new version to switch to (${WP_MIN_VERSION} - ${WP_MAX_VERSION}), or Enter for latest: " WP_NEW_VERSION

if [[ -z "$WP_NEW_VERSION" ]] || [ $(echo "$WP_NEW_VERSION <= $WP_MIN_VERSION" | bc) -eq 1 ] || [ $(echo "$WP_NEW_VERSION >= $WP_MAX_VERSION" | bc) -eq 1 ]; then
	WP_NEW_VERSION="$WP_MAX_VERSION"
fi

echo "${GREEN}Using: $WP_NEW_VERSION${NORMAL}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")";pwd)"
WP_CORE_DIR="$DIR/versions/$WP_NEW_VERSION"
WP_TESTS_DIR="$DIR/tests/$WP_NEW_VERSION"

cd $DIR

if ! [[ $WP_NEW_VERSION == $WP_PREVIOUS_VERSION ]]; then
	export_db
	switch_wp
	install_wp
	install_test_suite
	import_db
	echo "${GREEN}${BOLD}Switch complete.${NORMAL}"
else
	echo "${YELLOW}No version change needed.${NORMAL}"
fi
