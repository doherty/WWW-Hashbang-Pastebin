use strict;
use warnings;
use Test::More tests => 2;

# the order is important
use WWW::Hashbang::Pastebin;
use Dancer::Test;

subtest 'plain' => sub {
    plan tests => 5;

    route_exists            [GET => '/b'], 'route /b exists';
    response_status_is      [GET => '/b'], 200, 'HTTP OK';
    response_headers_include[GET => '/b'], ['X-Pastebin-ID' => 'b'];
    response_headers_include[GET => '/b'], ['Content-Type' => 'text/plain'];
    response_content_like   [GET => '/b'], qr/\Qits alive\E/, 'known paste content retrieved OK';
};

subtest 'html' => sub {
    plan tests => 6;

    route_exists            [GET => '/b.'], 'route /b. exists';
    response_status_is      [GET => '/b.'], 200, 'HTTP OK';
    response_headers_include[GET => '/b.'], ['X-Pastebin-ID' => 'b'];
    response_headers_include[GET => '/b.'], ['Content-Type' => 'text/html'];
    response_content_like   [GET => '/b.'], qr/\Qits alive\E/, 'known paste content retrieved OK';
    response_content_like   [GET => '/b.'], qr/\Qname="l1"\E/, 'line numbers present';
};
