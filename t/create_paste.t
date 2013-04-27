use strict;
use warnings;
use Test::More 0.96 tests => 3;

# the order is important
use WWW::Hashbang::Pastebin;
use Dancer::Plugin::DBIC;
use Dancer::Test;

route_exists [POST => '/'], 'a route handler is defined for POST /';

subtest param => sub {
    plan tests => 4;

    my $rand = rand();
    my $response = dancer_response('POST', '/', { params  => {p => $rand} });
    like $response->content, qr{^http://.+/.+} or diag explain $response;

    my $paste_id = $response->header('X-Pastebin-ID');
    route_exists            [GET => "/$paste_id"],              "route /$paste_id exists";
    response_status_is      [GET => "/$paste_id"], 200,         "200 for /$paste_id";
    response_content_is     [GET => "/$paste_id"] => $rand,     'Paste content OK';
};

subtest upload => sub {
    plan tests => 2;
    my $data  = 'file contents';
    my $response = dancer_response(POST => '/', {
        files => [{ name => 'test', filename => "test.txt", data => $data }]
    });
    like $response->content => qr{^http://.+/.+} or diag explain $response;
    response_content_is [GET => '/' . $response->header('X-Pastebin-ID')] => $data,
        'file upload saved correctly';
};
