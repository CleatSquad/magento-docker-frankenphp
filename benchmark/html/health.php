<?php
/**
 * Simple health check endpoint
 */
header('Content-Type: application/json');

echo json_encode([
    'status' => 'ok',
    'server' => $_SERVER['SERVER_SOFTWARE'] ?? 'unknown',
    'php_version' => PHP_VERSION,
    'timestamp' => date('c')
]);
