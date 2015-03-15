<?php
function exemple($p_var) {
    try {
        $object = new stdClass();
        $object->strErreur = "";
        $object->data = "";
        
        $object->data = $p_var;

        return $object;
    } catch (Exception $e) {
        $object = new stdClass();
        $msg = $e->getMessage();
        $object->strErreur = $msg;
        $object->strData = "";
        return $object;
    }
}
?>