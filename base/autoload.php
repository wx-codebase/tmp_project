<?php

function classLoader($className) {

    $filePath = PATH_INC . DIRECTORY_SEPARATOR . strtolower($className) . '.class.php';

    if (file_exists($filePath)) {
        require_once($filePath);
    }
}

spl_autoload_register('classLoader');
