# wordpress-versions

![](https://cloud.githubusercontent.com/assets/134939/18406221/3ff9fa72-76c8-11e6-8d7e-248d560da38e.gif)

Easily switch between multiple versions of WordPress. Each WordPress version has its own versioned test environment for running unit-tests against.

If you use homebrew to manage your local server installation, I highly suggest [brew-php-switcher](https://github.com/philcook/brew-php-switcher) to easily switch between PHP versions.

In the following examples, we assume the following:

- local DocumentRoot is: `~/Sites`
- local development domain is: `wordress.dev`
- local development domain DocumentRoot is: `~/Sites/wordpress/public`

### Switch WordPress versions:

1. Setup your local development server, database, domain (e.g. wordpress.dev), etc.

2. Clone wordpress-versions to your local DocumentRoot dir

    ```
    git clone git@github.com:geminilabs/wordpress-versions.git ~/Sites/wordpress
    cd ~/Sites/wordpress
    ```

3. Edit the environment and database values to match your local development setup

    ```
    vi env.php
    ```

4. Switch WordPress to your desired version, the database will be created if it doesn't exist in the format of "wordpress_{major_version}" (e.g. wordpress_4.6)

    ```
    sh switch.sh
    ```

### Running plugin unit tests where phpunit is installed with composer:

1. Switch WordPress to the version you want to test your plugin with

    ```
    cd ~/Sites/wordpress
    sh switch.sh
    ```

2. Symlink (or copy) your plugin into WordPress

    ```
    ln -s {path_to_your_plugin} ~/Sites/wordpress/public/app/plugins/{your_plugin}
    ```

3. Activate plugin, then cd to the plugin root dir

    ```
    cd ~/Sites/wordpress/public/app/plugins/{your_plugin}
    ```

4. Run your phpunit tests

    ```
    WP_TESTS_DIR=~/Sites/wordpress/tests/current/ vendor/bin/phpunit
    ```
