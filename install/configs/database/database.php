<?php  if (!defined('BASEPATH')) exit('No direct script access allowed');
/*
| -------------------------------------------------------------------
| DATABASE CONNECTIVITY SETTINGS
| -------------------------------------------------------------------
| This file will contain the settings needed to access your database.
|
| For complete instructions please consult the "Database Connection"
| page of the User Guide.
|
| -------------------------------------------------------------------
| EXPLANATION OF VARIABLES
| -------------------------------------------------------------------
|
|	['hostname'] The hostname of your database server.
|	['username'] The username used to connect to the database
|	['password'] The password used to connect to the database
|	['database'] The name of the database you want to connect to
|	['dbdriver'] The database type. ie: mysql.  Currently supported:
				 mysql, mysqli, postgre, odbc, mssql
|	['dbprefix'] You can add an optional prefix, which will be added
|				 to the table name when using the  Active Record class
|	['pconnect'] TRUE/FALSE - Whether to use a persistent connection
|	['db_debug'] TRUE/FALSE - Whether database errors should be displayed.
|	['cache_on'] TRUE/FALSE - Enables/disables query caching
|	['cachedir'] The path to the folder where cache files should be stored
|	['char_set'] The character set used in communicating with the database
|	['dbcollat'] The character collation used in communicating with the database
|
| The $active_group variable lets you choose which connection group to
| make active.  By default there is only one group (the "default" group).
|
| The $active_record variables lets you determine whether or not to load
| the active record class
*/
$active_group = "default";
$active_record = TRUE;

$db['default']['hostname'] = "db";
$db['default']['username'] = "root";
$db['default']['password'] = "docker";
$db['default']['database'] = "ctc";
$db['default']['dbdriver'] = "mysqli";
$db['default']['dbprefix'] = "";
$db['default']['pconnect'] = TRUE;
$db['default']['db_debug'] = TRUE;
$db['default']['cache_on'] = FALSE;
$db['default']['cachedir'] = "";
$db['default']['char_set'] = "utf8mb4";
$db['default']['dbcollat'] = "utf8mb4_unicode_ci";

$db['joom1']['hostname'] = "db";
$db['joom1']['username'] = "root";
$db['joom1']['password'] = "docker";
$db['joom1']['database'] = "joom1";
$db['joom1']['dbdriver'] = "mysqli";
$db['joom1']['dbprefix'] = "";
$db['joom1']['pconnect'] = TRUE;
$db['joom1']['db_debug'] = TRUE;
$db['joom1']['cache_on'] = FALSE;
$db['joom1']['cachedir'] = "";
$db['joom1']['char_set'] = "utf8mb4";
$db['joom1']['dbcollat'] = "utf8mb4_unicode_ci";

$db['tripreports']['hostname'] = "db";
$db['tripreports']['username'] = "root";
$db['tripreports']['password'] = "docker";
$db['tripreports']['database'] = "tripreports";
$db['tripreports']['dbdriver'] = "mysqli";
$db['tripreports']['dbprefix'] = "";
$db['tripreports']['pconnect'] = TRUE;
$db['tripreports']['db_debug'] = TRUE;
$db['tripreports']['cache_on'] = FALSE;
$db['tripreports']['cachedir'] = "";
$db['tripreports']['char_set'] = "utf8mb4";
$db['tripreports']['dbcollat'] = "utf8mb4_unicode_ci";
