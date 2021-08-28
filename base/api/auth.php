<?php

use base\path_inc;

if (isset($_SESSION['user'])) {
    Users::echoAuthUser();
    return;
}

$_POST = json_decode(file_get_contents('php://input'), true);
$user = Users::auth($_POST['login'], $_POST['psw']);
if ($user) {
    Users::echoAuthUser();
} else {
    header_status::set(403);
    echo json_encode(["status" => "error"]);
}


