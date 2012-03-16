package WWW::Hashbang::Pastebin::Schema::Result::Paste;
use strict;
use warnings;
use base qw/DBIx::Class::Core/;
# VERSION
# ABSTRACT: represents a paste in the pastebin
 
__PACKAGE__->table('paste');
__PACKAGE__->load_components( qw/InflateColumn::DateTime/ );
__PACKAGE__->add_columns(
    'paste_id'   => {
        data_type           => 'bigint',
        is_auto_increment   => 1,
        is_numeric          => 1,
        accessor            => 'id',
    },
    'paste_content' => {
        data_type           => 'text',
        accessor            => 'content',
    },
    'paste_deleted' => {
        data_type           => 'boolean',
        default_value       => 0,
        accessor            => 'deleted',
    },
    'paste_date'    => {
        data_type           => 'datetime',
        accessor            => 'date',
    }
);

__PACKAGE__->set_primary_key('paste_id');
 
1;
