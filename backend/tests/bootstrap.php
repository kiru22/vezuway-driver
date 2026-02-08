<?php
putenv('DB_DATABASE=logistics_testing');
$_ENV['DB_DATABASE'] = 'logistics_testing';
$_SERVER['DB_DATABASE'] = 'logistics_testing';

require __DIR__.'/../vendor/autoload.php';
