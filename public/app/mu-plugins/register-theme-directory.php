<?php
/**
 * Plugin Name:  Enable Default Themes
 * Plugin URI:   http://roots.io/wordpress-stack/
 * Description:  WordPress allows you to register multiple theme directories so this plugin makes the default twenty*** themes available.
 * Version:      1.0.0
 * Author:       Roots
 * Author URI:   http://roots.io/
 * License:      MIT License
 */

register_theme_directory( ABSPATH . 'wp-content/themes') ;
