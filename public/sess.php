<?php
@session_start();

require_once dirname(dirname(__FILE__)) . DIRECTORY_SEPARATOR . 'base' . DIRECTORY_SEPARATOR . 'config.php';


//  define('PATH_INC',  PATH_BASE . DIRECTORY_SEPARATOR . 'include');
define('PATH_ROOT',			dirname(dirname(__FILE__)));
define('PATH_INC',			PATH_ROOT . '/include');
define('PATH_BASE',			PATH_ROOT . '/base');

require_once PATH_BASE . '/autoload.php';

$DB = new connect_db();
if(!$DB->valid()) {
    echo "<h1>Ошибка подключения к БД {$DB->db_drv}:{$DB->db_name}</h1><h2>{$DB->error}</h2><pre>";
    print_r($DB->errInfo);
    echo "</pre>";
}

