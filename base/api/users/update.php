<?php

if (!Users::isAdmin()) {
    header_status::set(404);
    return;
}


$_POST = json_decode(file_get_contents('php://input'), true);

$user = new Users($_POST['id']);
$user->columns->login = $_POST['login'];
$user->columns->psw = md5($_POST['psw']);
$user->columns->email = $_POST['email'];

$test_user_id = $user->verifyUniqueLogin();

if ($test_user_id && $test_user_id[0]['id'] !== $_POST['id']) {
    header_status::set(202);
    echo json_encode(["status" => "error", "msg" => "Login is not Unique"]);
    return;
}

$ret = $user->saveData();
if ($ret) {
    header_status::set(200);
    echo json_encode(["status" => "ok", "data" => $ret]);
} else {
    header_status::set(303);
    echo json_encode(["status" => "error", "msg" => "error"]);
}