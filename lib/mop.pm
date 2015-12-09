package mop;

use strict;
use warnings;

our $VERSION;
our $AUTHORITY;

use Devel::CallParser;
use XSLoader;
BEGIN {
    $VERSION   = '0.01';
    $AUTHORITY = 'cpan:STEVAN';
    XSLoader::load( __PACKAGE__, $VERSION );
}

use mop::object;

use mop::module;

use mop::role;
use mop::class;

use mop::attribute;
use mop::method;

1;

__END__
