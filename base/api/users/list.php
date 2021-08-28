<?php


if (!Users::isAdmin()) {
    header_status::set(404);
    return;
}

echo json_encode(["status" => "ok", "data" => Users::load()]);