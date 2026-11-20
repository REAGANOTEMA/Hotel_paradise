<?php
final class Database {
    private static ?PDO $pdo=null;
    public static function pdo(): PDO {
        if(self::$pdo) return self::$pdo;
        $e=require __DIR__.'/../config/env.php';
        $dsn="mysql:host={$e['db_host']};dbname={$e['db_name']};charset=utf8mb4";
        self::$pdo=new PDO($dsn,$e['db_user'],$e['db_pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
        return self::$pdo;
    }
}
