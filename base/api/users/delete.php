<?php

if (!Users::isAdmin()) {
    header_status::set(404);
    return;
}

$_POST = json_decode(file_get_contents('php://input'), true);

$user = new Users($_POST['id']);


if ($user) {
    $ret = $user->del();
    if ($ret[0]['status'] == "ok") {
        header_status::set(200);
        echo json_encode(["status" => "ok", "id" => $_POST['id']]);
    } else {
        header_status::set(304);
        echo json_encode(["status" => "error"]);
    }
} else {
    header_status::set(304);
    echo json_encode(["status" => "error"]);
}


