package WWW::Hashbang::Pastebin;
use v5.14.0;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema);
use Integer::Tiny;
use Try::Tiny;
use DateTime;

# ABSTRACT: a pastebin with no UI; a Perl Dancer clone of http://sprunge.us
# VERSION

my $mapper = do {
    my $key = config->{key} || join '', ('a'..'z', 0..9);
    $key =~ tr/.//d;
    Integer::Tiny->new($key);
};


get '/' => sub {
    return template index => { url => uri_for('') };
};

post '/' => sub {
    my $paste_content = param('p') || param('sprunge');
    my $lang = param('lang');

    unless ($paste_content) {
        status 'bad_request';
        return 'No paste content received';
    }

    my $now = DateTime->now;
    my $row = schema->resultset('Paste')->create({
        paste_content => $paste_content,
        paste_date    => $now,
    });

    my $ext_id  = $mapper->encrypt($row->id);
    my $ext_url = uri_for("/$ext_id");
    $ext_url = "$ext_url?$lang" if $lang;
    debug "Created paste $ext_id: $ext_url";
    headers
        'X-Pastebin-ID'     => $ext_id,
        'X-Pastebin-URL'    => $ext_url;
    return "$ext_url\n";
};

get '/:id' => sub {
    my $ext_id = param('id');
    my $line_nos = ($ext_id =~ s{\.$}{});

    my $int_id = try { $mapper->decrypt( $ext_id ) } || do {
        status 'bad_request';
        return "'$ext_id' is not a valid paste ID";
    };
    debug "paste ID requested: $int_id";

    my $paste = schema->resultset('Paste')->find( $int_id );

    unless ($paste) {
        my $msg = "No such paste as '$ext_id'";
        warning $msg;
        content_type('text/plain');
        status 'not_found';
        return $msg;
    }
    elsif ($paste->deleted) {
        warning "Request was for deleted paste '$ext_id'->'$int_id'";
        status 'gone';
        return "No such paste as '$ext_id'";
    }

    headers 'X-Pastebin-ID' => $ext_id;
    if ($line_nos) {
        return template paste => { content => $paste->content };
    }
    else {
        content_type('text/plain');
        return $paste->content;
    }
};

true;
