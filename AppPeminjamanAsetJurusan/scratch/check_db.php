<?php
try {
    $pdo = new PDO("mysql:host=127.0.0.1;dbname=db_aspaj", "root", "", [PDO::ATTR_TIMEOUT => 5]);
    $stmt = $pdo->query("SELECT name, photo FROM commodities WHERE photo LIKE '%qOFGh40LJWcTfojr650gQU6QC96ccyP6Aq8baMwQ%'");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($row) {
        echo "Match found: " . $row['name'] . " | " . $row['photo'] . "\n";
    } else {
        echo "No match found for hash qOFGh40LJWcTfojr650gQU6QC96ccyP6Aq8baMwQ\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
