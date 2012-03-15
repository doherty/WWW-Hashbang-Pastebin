use strict;
use warnings;
use Test::More tests => 1;

# the order is important
use WWW::Hashbang::Pastebin;
use Dancer::Test;

END {
    require File::Copy;
    File::Copy::copy('db/paste.db.bak', 'db/paste.db');
}

response_status_is  [POST => '/'], 400, 'HTTP 400 for empty POST';
