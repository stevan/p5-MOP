#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

# roles ...
package Foo {
    use Moxie;
}
package Bar {
    use Moxie;
}
package Baz {
    use Moxie;
}
package Bat {
    use Moxie;

    with 'Baz';
}

# classes ...
package Quux {
    use Moxie;

    extends 'MOP::Object';
       with 'Foo', 'Bar';
}

package Quuux {
    use Moxie;

    extends 'Quux';
       with 'Foo', 'Baz';
}

package Xyzzy {
    use Moxie;

    extends 'MOP::Object';
       with 'Foo', 'Bat';
}

ok(Quux->DOES($_),  "... Quux DOES $_")  for qw( Foo Bar         Quux       MOP::Object UNIVERSAL );
ok(Quuux->DOES($_), "... Quuux DOES $_") for qw( Foo Bar Baz     Quux Quuux MOP::Object UNIVERSAL );
ok(Xyzzy->DOES($_), "... Xyzzy DOES $_") for qw( Foo     Baz Bat      Xyzzy MOP::Object UNIVERSAL );

#{ local $TODO = "broken in core perl" if $] < 5.019005;
#push @UNIVERSAL::ISA, 'Blorg';
#ok(Quux->DOES('Blorg'));
#ok(Quuux->DOES('Blorg'));
#ok(Xyzzy->DOES('Blorg'));
#}

done_testing;
