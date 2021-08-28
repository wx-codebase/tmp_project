<?php

class Model
{

    public $table = false;
    public $columns;
    public $db_error = "";

    private function classCfg($param)
    {

        $ret["id"] = "id";

        if (!isset($ret[$param])) {
            return -1;
        } else {
            return $ret[$param];
        }

    }

    private function prepare()
    {
        global $DB;

        $this->columns = new stdClass();

        $DB->prepare("CALL get_fields(:table);");
        $DB->bind("table",$this->table);
        $properties = $DB->execute_all();

        foreach ($properties as $property) {

            switch ($property['data_type']) {
                case 'int':
                    $this->columns->{$property['column_name']} = 0;
                    break;

                case 'smallint':
                    $this->columns->{$property['column_name']} = 0;
                    break;

                case 'decimal':
                    $this->columns->{$property['column_name']} = 0;
                    break;

                case 'varchar':
                    $this->columns->{$property['column_name']} = "";
                    break;

                case 'date':
                    $this->columns->{$property['column_name']} = "1999-01-01";
                    break;

                case 'datetime':
                    $this->columns->{$property['column_name']} = "1999-01-01 00:00:00";
                    break;

                default:
                    $this->columns->{$property['column_name']} = "";
                    break;
            }

        }

    }

    public function activeRecord($id = 0)
    {
        global $DB;


        $this->table = $this->table ? $this->table : __CLASS__;

        $this->prepare();

        if (intval($id) > 0) {
            $DB->prepare("SELECT * FROM {$this->table} WHERE id = :id");
            $DB->bind("id", $id);
            $row = $DB->execute_all();

            if ($row) {
                $itm = $row[0];
                foreach ($this->columns as $key => $value) {
                    $this->columns->{$key} = $itm[$key];
                }
            }
        }

    }

    public function save($dm_excl = [])
    {

        // $dm_excl - Не сохранять поля
        global $DB;

        if (isset($this->dm_excl)) {
            $dm_excl = array_merge($dm_excl, $this->dm_excl);
        }

        $cols = [];
        $column_list = [];
        $value_list = [];


        foreach ($this->columns as $name => $value) {
            if (!in_array($name, $dm_excl)) {
                if ($name != "id") $cols[] = "`$name` = :" . $name;
                $column_list[] = "`" . $name . "`";
                $value_list[] = ":" . $name;
            }
        }

        $cols = implode(',', $cols);
        $column_list = implode(',', $column_list);
        $value_list = implode(',',  $value_list);

        $sql =
            "   INSERT INTO {$this->table} ($column_list)
            VALUES ($value_list)
            ON DUPLICATE KEY UPDATE $cols;
        ";


        $DB->prepare($sql);


        foreach ($this->columns as $name => $value) {
            if (!in_array($name, $dm_excl)) $DB->bind($name, $value);
        }
        $q = $DB->execute();

        if (!$q) $this->db_error = $DB->error;

        // var_dump($DB);
        return $q ? $this->columns->id == 0 ? $DB->lastInsertId() : $this->columns->id : false;


    }


}