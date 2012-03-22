#!/usr/bin/env perl
use strict;
use warnings;
use Dancer qw(:script);
use WWW::Hashbang::Pastebin;

# VERSION
# PODNAME: app.pl
# ABSTRACT: runner for WWW::Hashbang::Pastebin

WWW::Hashbang::Pastebin::schema->deploy
    unless $ENV{PLACK_ENV};

dance;
