#!/bin/bash

BOLD=`tput bold`
UNDERLINE=`tput smul`
NORMAL=`tput sgr0`
WHITE=`tput setaf 15`
GREY=`tput setaf 8`
RED=`tput setaf 9`
GREEN=`tput setaf 10`

check_errors() {
	ERRORS=()

	# Check that wp is installed
	if ! which wp > /dev/null; then
		ERRORS=("${ERRORS[@]}" "==>${WHITE} wp   ${GREY}${UNDERLINE}https://wp-cli.org/#installing${NORMAL}")
	fi

	# Check that perl is installed
	if ! which perl > /dev/null; then
		ERRORS=("${ERRORS[@]}" "==>${WHITE} perl ${GREY}${UNDERLINE}https://www.perl.org/get.html${NORMAL}")
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
		wp core download --version=$WP_VERSION --path=$WP_CORE_DIR
	fi

	echo "${BOLD}${GREEN}Switching to WordPress $WP_VERSION${NORMAL}"

	rm -rf $DIR/public/wp;
	cp -R $WP_CORE_DIR $DIR/public/wp

	DB_NAME=$(perl -lne 'm{DB_NAME.*?([\w.-]+)} and print $1' $DIR/env.php)
	perl -i -pwe "s|${DB_NAME}|wordpress_${WP_VERSION}|" $DIR/env.php
}

install_wp() {
	WP_PATH='--path=public/wp'
	wp db create $WP_PATH > /dev/null 2>&1
	if ! wp core is-installed $WP_PATH; then
		wp core install $WP_PATH --url="http://wordpress.dev" --title="WordPress $WP_VERSION" --admin_user="dev" --admin_password="dev" --admin_email="dev@geminilabs.io"
		wp option update welcome 0 $WP_PATH
		wp option update uploads_use_yearmonth_folders 0 $WP_PATH
		wp option update blogdescription "" $WP_PATH
		wp option update permalink_structure "/%postname%/" $WP_PATH
		wp option update show_on_front page $WP_PATH
		wp option update page_on_front 2 $WP_PATH
		wp post delete 1 --force $WP_PATH
		wp post update 2 --post_title=Home --post_name=home --post_content= $WP_PATH
		wp user meta update 1 show_welcome_panel 0 $WP_PATH
		wp widget deactivate $(wp widget list sidebar-1 --fields=id --format=ids $WP_PATH) $WP_PATH
	fi
}

install_test_suite() {
	if [ ! -d $WP_TESTS_DIR ]; then
		mkdir -p $WP_TESTS_DIR
		svn co --quiet https://develop.svn.wordpress.org/tags/${WP_VERSION}/tests/phpunit/includes/ $WP_TESTS_DIR/includes
	fi

	rm -f $DIR/tests/current
	ln -s $WP_TESTS_DIR $DIR/tests/current

	DB_NAME=$(perl -lne 'm{DB_NAME.*?([\w.-]+)} and print $1' $DIR/env.php)
	DB_USER=$(perl -lne 'm{DB_USER.*?([\w.-]+)} and print $1' $DIR/env.php)
	DB_PASS=$(perl -lne 'm{DB_PASSWORD.*?([\w.-]+)} and print $1' $DIR/env.php)
	DB_HOST=$(perl -lne 'm{DB_HOST.*?([\w.-]+)} and print $1' $DIR/env.php)

	WP_TEST_CONFIG="$WP_TESTS_DIR/wp-tests-config.php"

	if [ ! -f wp-tests-config.php ]; then
		download https://develop.svn.wordpress.org/tags/${WP_VERSION}/wp-tests-config-sample.php $WP_TEST_CONFIG
		perl -i -pwe "s|dirname.{22}|'${DIR}/public/wp/'|" $WP_TEST_CONFIG
		perl -i -pwe "s|youremptytestdbnamehere|${DB_NAME}|" $WP_TEST_CONFIG
		perl -i -pwe "s|yourusernamehere|${DB_USER}|" $WP_TEST_CONFIG
		perl -i -pwe "s|yourpasswordhere|${DB_PASS}|" $WP_TEST_CONFIG
		perl -i -pwe "s|localhost|${DB_HOST}|" $WP_TEST_CONFIG
	fi
}

check_errors

read -e -p 'Enter the WordPress version to switch to (3.7 - 4.6): ' WP_VERSION

REGEX_WP3='^3.([7-9]+)$'
REGEX_WP4='^4.([0-6]+)$'

if ! [[ $WP_VERSION =~ $REGEX_WP3 || $WP_VERSION =~ $REGEX_WP4 ]] ; then
	WP_VERSION="4.6"
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")";pwd)"
WP_CORE_DIR="$DIR/versions/$WP_VERSION"
WP_TESTS_DIR="$DIR/tests/$WP_VERSION"

cd $DIR

switch_wp
install_wp
install_test_suite
