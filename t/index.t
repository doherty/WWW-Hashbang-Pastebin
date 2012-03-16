use strict;
use warnings;
use Test::More tests => 3;

# the order is important
use WWW::Hashbang::Pastebin;
use Dancer::Test;

route_exists        [GET => '/'],       'a route handler is defined for GET /';
response_status_is  [GET => '/'], 200,  'response status is 200 for GET /';
response_content_like
    [GET => '/'],
    qr/WWW::Hashbang::Pastebin\(3\) +User Contributed Perl Documentation/,
    'main page renders OK';
