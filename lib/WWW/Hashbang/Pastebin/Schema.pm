package WWW::Hashbang::Pastebin::Schema;
use strict;
use warnings;
use Try::Tiny;
use base qw(DBIx::Class::Schema);
# VERSION
# ABSTRACT: Database schema for WWW::Hashbang::Pastebin

__PACKAGE__->load_namespaces();

sub connection {
    my ($self, @info) = @_;
    return $self if !@info && $self->storage;

    my ($storage_class, $args) = ref $self->storage_type ?
    ($self->_normalize_storage_type($self->storage_type),{}) : ($self->storage_type, {});

    $storage_class = 'DBIx::Class::Storage'.$storage_class
        if $storage_class =~ m/^::/;
    try {
        $self->ensure_class_loaded($storage_class);
    }
    catch {
        $self->throw_exception(
            "Unable to load storage class ${storage_class}: $_"
        );
    };
    my $storage = $storage_class->new($self=>$args);
    $storage->connect_info(\@info);
    $self->storage($storage);

    my $dbname = (split /:/, $info[0], 3)[2];
    if ($dbname and $dbname eq 'dbname=:memory:') {
#        warn "deploying into $dbname";
        $self->deploy();
    }

    return $self;
}

1;
