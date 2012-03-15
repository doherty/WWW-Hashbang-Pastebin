use strict;
use warnings;
use Test::More tests => 3;

# the order is important
use WWW::Hashbang::Pastebin;
use Dancer::Test;

route_exists            [GET => '/c'], 'route /c exists';
response_status_is      [GET => '/c'], 410, '410 for deleted paste';
response_content_is     [GET => '/c'], q{No such paste as 'c'};
