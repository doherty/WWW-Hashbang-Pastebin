package WWW::Hashbang::Pastebin;
use strict;
use warnings;
use 5.014000;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema);
use Dancer::Plugin::EscapeHTML qw(escape_html);
use Integer::Tiny;
use Try::Tiny;
use DateTime;

# ABSTRACT: command line pastebin
# VERSION

=head1 SYNOPSIS

    $ (hostname ; uptime) | curl -F 'p=<-' http://p.hashbang.ca
    http://p.hashbang.ca/f4s2
    $ chromium-browser http://p.hashbang.ca/f4s2+#l2

=for test_synopsis
1;
__END__

=head1 DESCRIPTION

This pastebin has no user interface - use C<curl> or L<WWW::Hashbang::Pastebin::Client>'s
C<p> command to POST paste content. Your paste's ID is returned in the
C<X-Pastebin-ID> header; the URL in the C<X-Pastebin-URL>, as well as the response
content.

Append a plus sign to the URL to get line numbers. Add an anchor like C<#l1> to
jump to the given line number, or click the line number you want. The line number
for the selected line will be highlighted.

=cut

my $mapper = do {
    my $key = config->{key} || join '', ('a'..'z', 0..9);
    $key =~ tr/+//d;
    Integer::Tiny->new($key);
};


get '/' => sub {
    return template 'index';
};

post '/' => sub {
    my $paste_content = param('p') || param('sprunge');
    my $lang = param('lang');

    unless ($paste_content) {
        status 'bad_request';
        return 'No paste content received';
    }

    my $now = DateTime->now( time_zone => 'UTC' );
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
    my $line_nos = ($ext_id =~ s{\+$}{});

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
        open my $in, '<', \$paste->content;
        1 while (<$in>);
        my $lines = $.;
        close $in;
        return template paste => { content => $paste->content, lines => [1..$lines] };
    }
    else {
        content_type('text/plain');
        return $paste->content;
    }
};

=head1 SEE ALSO

=over 4

=item * L<http://sprunge.us>

=item * L<http://p.defau.lt>

=back

=cut

true;
