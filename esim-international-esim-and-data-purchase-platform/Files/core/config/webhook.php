<?php

/*
    |--------------------------------------------------------------------------
    | Webhook Allowed IPs
    |--------------------------------------------------------------------------
    |
    | This configuration file is used to define the list of allowed IP addresses
    | for various webhook services. Each key represents a specific service or
    | provider (e.g., 'esimaccess'), and its value is an array of IP addresses
    | that are permitted to send webhook requests to your application.
    |
    | When a webhook request is received, the application should verify that the
    | IP address of the incoming request matches one of the allowed IPs defined
    | here. If the IP is not whitelisted, the request should be denied to ensure
    | security and prevent unauthorized access.
    |
    | You can define multiple services with their corresponding allowed IPs as
    | needed. Make sure to keep this list updated according to the provider’s
    | documentation or security policies.
    |
*/

return [
    'esimaccess' => [
        '3.1.131.226',
        '54.254.74.88',
        '18.136.190.97',
        '18.136.60.197',
        '18.136.19.137'
    ],
];
