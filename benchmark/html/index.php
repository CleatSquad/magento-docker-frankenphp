<?php
/**
 * Benchmark test script for comparing FrankenPHP vs Nginx + PHP-FPM
 *
 * This script performs various operations to simulate real-world PHP workloads:
 * - CPU intensive operations (Fibonacci, sorting)
 * - Memory operations (array manipulation)
 * - String operations
 * - JSON encoding/decoding
 */

header('Content-Type: application/json');

$startTime = microtime(true);

/**
 * CPU intensive: Calculate Fibonacci
 */
function fibonacci(int $n): int
{
    if ($n <= 1) {
        return $n;
    }
    return fibonacci($n - 1) + fibonacci($n - 2);
}

/**
 * Array operations: Generate and sort random data
 */
function arrayOperations(int $size): array
{
    $data = [];
    for ($i = 0; $i < $size; $i++) {
        $data[] = rand(1, 10000);
    }
    sort($data);
    return [
        'count' => count($data),
        'sum' => array_sum($data),
        'min' => min($data),
        'max' => max($data)
    ];
}

/**
 * String operations
 */
function stringOperations(int $iterations): string
{
    $result = '';
    for ($i = 0; $i < $iterations; $i++) {
        $result .= md5(uniqid((string)mt_rand(), true));
    }
    return substr($result, 0, 64);
}

/**
 * JSON operations
 */
function jsonOperations(int $size): int
{
    $data = [];
    for ($i = 0; $i < $size; $i++) {
        $data[] = [
            'id' => $i,
            'name' => 'Item ' . $i,
            'price' => rand(100, 10000) / 100,
            'description' => str_repeat('Lorem ipsum ', 10)
        ];
    }
    $encoded = json_encode($data);
    $decoded = json_decode($encoded, true);
    return strlen($encoded);
}

// Run benchmark operations
$results = [
    'server' => $_SERVER['SERVER_SOFTWARE'] ?? 'unknown',
    'php_version' => PHP_VERSION,
    'timestamp' => date('c'),
    'tests' => [
        'fibonacci_30' => [
            'start' => microtime(true),
            'result' => fibonacci(30),
            'duration' => 0
        ],
        'array_10000' => [
            'start' => microtime(true),
            'result' => arrayOperations(10000),
            'duration' => 0
        ],
        'string_1000' => [
            'start' => microtime(true),
            'result' => stringOperations(1000),
            'duration' => 0
        ],
        'json_1000' => [
            'start' => microtime(true),
            'result' => jsonOperations(1000),
            'duration' => 0
        ]
    ]
];

// Calculate durations
$endTime = microtime(true);
$results['tests']['fibonacci_30']['duration'] = ($results['tests']['array_10000']['start'] - $results['tests']['fibonacci_30']['start']) * 1000;
$results['tests']['array_10000']['duration'] = ($results['tests']['string_1000']['start'] - $results['tests']['array_10000']['start']) * 1000;
$results['tests']['string_1000']['duration'] = ($results['tests']['json_1000']['start'] - $results['tests']['string_1000']['start']) * 1000;
$results['tests']['json_1000']['duration'] = ($endTime - $results['tests']['json_1000']['start']) * 1000;

// Remove start times from output
foreach ($results['tests'] as &$test) {
    unset($test['start']);
}

$results['total_duration_ms'] = ($endTime - $startTime) * 1000;
$results['memory_peak_mb'] = round(memory_get_peak_usage(true) / 1024 / 1024, 2);

echo json_encode($results, JSON_PRETTY_PRINT);
