<?php
require_once '../sess.php';
$url 		= substr($_SERVER['REQUEST_URI'],strrpos($_SERVER['SCRIPT_NAME'],'/')+1);
$exploded 	= explode(DIRECTORY_SEPARATOR,$url);
$dir 		= '';
foreach ($exploded as $key => $expl) {
    # code...
    $file_name = PATH_BASE.DIRECTORY_SEPARATOR.$dir.$expl.'.php';

    if(file_exists($file_name)){
        include $file_name;
    }else{
        $dir = $dir.$expl.DIRECTORY_SEPARATOR;
    }
}

