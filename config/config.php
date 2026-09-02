<?php
/**
 * EcoCycle — central configuration & PDO database connection.
 *
 * Adjust DB credentials here if your XAMPP setup differs from the defaults.
 */

declare(strict_types=1);

// ---- Database credentials (XAMPP defaults) ----
const DB_HOST = '127.0.0.1';
const DB_PORT = '3306';
const DB_NAME = 'ecocycle';
const DB_USER = 'root';
const DB_PASS = '';

// ---- App settings ----
const APP_NAME = 'EcoCycle';
const APP_TAGLINE = 'Turn everyday recycling into a rewarding community habit.';

/**
 * Return a shared PDO connection.
 *
 * @param bool $withDatabase  When false, connect to the server only (used by setup).
 */
function db(bool $withDatabase = true): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO && $withDatabase) {
        return $pdo;
    }

    $dsn = sprintf('mysql:host=%s;port=%s;charset=utf8mb4', DB_HOST, DB_PORT);
    if ($withDatabase) {
        $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_PORT, DB_NAME);
    }

    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];

    $connection = new PDO($dsn, DB_USER, DB_PASS, $options);
    if ($withDatabase) {
        $pdo = $connection;
    }
    return $connection;
}
