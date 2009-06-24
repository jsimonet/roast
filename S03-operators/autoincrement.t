use v6;
use Test;

# Tests for auto-increment and auto-decrement operators
# originally from Perl 5, by way of t/operators/auto.t

plan 64;

#L<S03/Autoincrement precedence>

my $base = 10000;

my $x = 10000;
is(0 + ++$x - 1, $base, '0 + ++$x - 1');
is(0 + $x-- - 1, $base, '0 + $x-- - 1');
is(1 * $x,       $base, '1 * $x');
is(0 + $x-- - 0, $base, '0 + $x-- - 0');
is(1 + $x,       $base, '1 + $x');
is(1 + $x++,     $base, '1 + $x++');
is(0 + $x,       $base, '0 + $x');
is(0 + --$x + 1, $base, '0 + --$x + 1');
is(0 + ++$x + 0, $base, '0 + ++$x + 0');
is($x,           $base, '$x');

my @x;
@x[0] = 10000;
is(0 + ++@x[0] - 1, $base, '0 + ++@x[0] - 1');
is(0 + @x[0]-- - 1, $base, '0 + @x[0]-- - 1');
is(1 * @x[0],       $base, '1 * @x[0]');
is(0 + @x[0]-- - 0, $base, '0 + @x[0]-- - 0');
is(1 + @x[0],       $base, '1 + @x[0]');
is(1 + @x[0]++,     $base, '1 + @x[0]++');
is(0 + @x[0],       $base, '0 + @x[0]');
is(0 + ++@x[0] - 1, $base, '0 + ++@x[0] - 1');
is(0 + --@x[0] + 0, $base, '0 + --@x[0] + 0');
is(@x[0],           $base, '@x[0]');

my %z;
%z{0} = 10000;
is(0 + ++%z{0} - 1, $base, '0 + ++%z{0} - 1');
is(0 + %z{0}-- - 1, $base, '0 + %z{0}-- - 1');
is(1 * %z{0},       $base, '1 * %z{0}');
is(0 + %z{0}-- - 0, $base, '0 + %z{0}-- - 0');
is(1 + %z{0},       $base, '1 + %z{0}');
is(1 + %z{0}++,     $base, '1 + %z{0}++');
is(0 + %z{0},       $base, '0 + %z{0}');
is(0 + ++%z{0} - 1, $base, '0 + ++%z{0} - 1');
is(0 + --%z{0} + 0, $base, '0 + --%z{0} + 0');
is(%z{0},           $base, '%z{0}');

# Increment of a Str
#L<S03/Autoincrement precedence/Increment of a>

# XXX: these need to be re-examined and extended per changes to S03.
# Also, see the thread at
# http://www.nntp.perl.org/group/perl.perl6.compiler/2007/06/msg1598.html
# which prompted many of the changes to Str autoincrement/autodecrement.

{
# These are the ranges specified in S03.
# They might be handy for some DDT later.

    my @rangechar = (
        [ 'A', 'Z' ],
        [ 'a', 'z' ],
        [ "\x[391]", "\x[3a9]" ],
        [ "\x[3b1]", "\x[3c9]" ],
        [ "\x[5d0]", "\x[5ea]" ],

        [ '0', '9' ],
        [ "\x[660]", "\x[669]" ],
        [ "\x[966]", "\x[96f]" ],
        [ "\x[9e6]", "\x[9ef]" ],
        [ "\x[a66]", "\x[a6f]" ],
        [ "\x[ae6]", "\x[aef]" ],
        [ "\x[b66]", "\x[b6f]" ],
    );
}

my @auto_tests = (
    { init => '99',  inc => '100' },
    { init => 'a0',  inc => 'a1' },
    { init => 'Az',  inc => 'Ba' },
    { init => 'zz',  inc => 'aaa' },
    { init => 'A99', inc => 'B00' },
    { init => 'zi',  inc => 'zj',
      name => 'EBCDIC check (i and j not contiguous)' },
    { init => 'zr',  inc => 'zs',
      name => 'EBCDIC check (r and s not contiguous)' },
    { init => 'a1',  dec => 'a0' },
    { init => '100', dec => '099' },
    { init => 'Ba',  dec => 'Az' },
    { init => 'B00', dec => 'A99' },

    { init => '123.456',
      inc  => '124.456',
      name => '124.456, not 123.457' },
    { init => '/tmp/pix000.jpg',
      inc  => '/tmp/pix001.jpg',
      name => 'increment a filename' },
);

for @auto_tests -> %t {
    my $pre = %t<init>;

    # This is a check on the form of the @auto_tests
    my $tests_run = 0;
    if ! $pre.defined {
        ok 0, 'initial value not defined';
        next;
    }

    if %t.exists( 'inc' ) {
        my $val = $pre;
        $val++;
        my $name = %t<name> // "'$pre'++ is '{%t<inc>}'";
        is( $val, %t<inc>, $name );
        $tests_run++;
    }
    if %t.exists( 'dec' ) {
        my $val = $pre;
        $val--;
        my $name = %t<name> // "'$pre'-- is '{%t<dec>}'";
        is( $val, %t<dec>, $name );
        $tests_run++;
    }

    # This is a check on the form of the @auto_tests
    if ! $tests_run {
        ok 0, "no test ran for '$pre'";
    }
}


my $foo;

$foo = 'aaa';
ok(--$foo ~~ Failure, "Decrement of 'aaa' should fail");

$foo = 'A00';
ok(--$foo ~~ Failure, "Decrement of 'A00' should fail");

# TODO: Check that the Failure is "Decrement out of range" and not
#       some other unrelated error (for the fail tests above).

$foo = "\x[391]";
is( ++$foo, "\x[392]", 'increment Greek uppercase alpha' );

$foo = "\x[3a9]";
is( ++$foo, "\x[391]\x[391]", 'increment Greek uppercase omega' );

$foo = "\x[3a1]";
is( ++$foo, "\x[3a3]", 'there is no \\x[3a2]' );

$foo = "\x[3b1]";
is( ++$foo, "\x[3b2]", 'increment Greek lowercase alpha' );

$foo = "\x[3c9]";
is( ++$foo, "\x[3b1]\x[3b1]", 'increment Greek lowercase omega' );

$foo = "\x[391]\x[3c9]";
is( ++$foo, "\x[392]\x[3b1]", "increment '\x[391]\x[3c9]'" );

$foo = "K\x[3c9]";
is( ++$foo, "L\x[3b1]", "increment 'K\x[3c9]'" );

{
    my $x;
    is ++$x, 1, 'Can autoincrement an undef variable (prefix)';

    my $y;
    $y++;
    is $y, 1, 'Can autoincrement an undef variable (postfix)';
}

{
    class Incrementor {
        has $.value;

        method succ() {
            Incrementor.new( value => $.value + 42);
        }
    }

    my $o = Incrementor.new( value => 0 );
    $o++;
    is $o.value, 42, 'Overriding succ catches postfix increment';
    ++$o;
    is $o.value, 84, 'Overriding succ catches prefix increment';
}

{
    class Decrementor {
        has $.value;

        method pred() {
            Decrementor.new( value => $.value - 42);
        }
    }

    my $o = Decrementor.new( value => 100 );
    $o--;
    is $o.value, 58, 'Overriding pred catches postfix decrement';
    --$o;
    is $o.value, 16, 'Overriding pred catches prefix decrement';
}

{
    # L<S03/Autoincrement precedence/Increment of a>
   
    my $x = "b";
    is $x.succ, 'c', '.succ for Str';
    is $x.pred, 'a', '.pred for Str';

    my $y = 1;
    is $y.succ, 2, '.succ for Int';
    is $y.pred, 0, '.pred for Int';

    my $z = Num.new();
    is $z.succ, 1 , '.succ for Num';
    is $z.pred, -1, '.pred for Num'
}
