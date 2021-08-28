<?php

class Users extends Model
{

    public $table = "spr_users";

    public function __construct($id = 0)
    {
        $this->activeRecord($id);
    }

    static public function load()
    {
        global $DB;
        $DB->prepare("CALL spr_users_load()");
        return $DB->execute_all();

    }

    static public function auth($login = '', $psw = '')
    {
        global $DB;

        $DB->prepare("CALL auth(:login,:psw)");
        $DB->bind("login", $login);
        $DB->bind("psw", md5($psw));
        $user = $DB->execute_all();

        if ($user) {

            $DB->prepare("CALL `get_roles_byUser`(:id)");
            $DB->bind("id", $user[0]['id']);
            $roles = $DB->execute_all();

            $_SESSION['user'] = [
                "user_id" => $user[0]['id'],
                "roles" => $roles ? $roles[0]['roles'] : ""
            ];

            return $user[0]['id'];
        } else {
            return false;
        }

    }

    static public function echoAuthUser()
    {
        header_status::set(200);
        echo json_encode([
            "status" => "ok",
            "data" => $_SESSION['user']
        ]);
    }

    static public function isAdmin()
    {
        if (!isset($_SESSION['user'])) return false;
        if (in_array(1, explode(',', $_SESSION['user']['roles']))) {
            return true;
        } else {
            return false;
        }
    }

    public function saveData()
    {
        global $DB;
        $DB->prepare("CALL spr_users_saveData(:id,:login,:email,:psw)");
        $DB->bind('id', $this->columns->id);
        $DB->bind('login', $this->columns->login);
        $DB->bind('email', $this->columns->email);
        $DB->bind('psw', $this->columns->psw);
        return $DB->execute_all();

    }

    public function verifyUniqueLogin($login = '')
    {
        global $DB;
        $DB->prepare("CALL verifyUniqueLogin(:login)");
        $DB->bind('login', $login == "" ? $this->columns->login : $login);
        return $DB->execute_all();
    }

    public function del()
    {
        global $DB;
        $DB->prepare("CALL spr_users_delete(:id)");
        $DB->bind('id', $this->columns->id);
        return $DB->execute_all();
    }

}