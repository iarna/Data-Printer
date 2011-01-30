use strict;
use warnings;

use Test::More;
use Term::ANSIColor 'colorstrip';
use Data::Printer 'd';

my $scalar = 'test';
is( colorstrip( d($scalar) ), '"test"', 'simple scalar' );

my $scalar_ref = \$scalar;
is( colorstrip( d($scalar_ref) ), '\\ "test"', 'scalar ref' );

my $refref = \$scalar_ref;
is( colorstrip( d($refref) ), '\\ \\ "test"', 'reference of reference');

$scalar = 42;
is( colorstrip( d($scalar) ), '42', 'simple numeric scalar' );

$scalar = -4.2;
is( colorstrip( d($scalar) ), '-4.2', 'negative float scalar' );

$scalar = '4.2';
is( colorstrip( d($scalar) ), '4.2', 'stringified float scalar' );

$scalar = 7;
is( colorstrip( d($scalar_ref) ), '\\ 7', 'simple numeric ref' );

my @array = (1 .. 3);
is( colorstrip( d(@array) ),
'[
    [0] 1,
    [1] 2,
    [2] 3,
]', 'simple array');

@array = ( 1, $scalar_ref );
is( colorstrip( d(@array) ),
'[
    [0] 1,
    [1] \\ 7,
]', 'simple array with scalar ref');
$scalar = 4.2;

@array = ( 1 .. 11 );
is( colorstrip( d(@array) ),
'[
    [0]  1,
    [1]  2,
    [2]  3,
    [3]  4,
    [4]  5,
    [5]  6,
    [6]  7,
    [7]  8,
    [8]  9,
    [9]  10,
    [10] 11,
]', 'simple array alignment');

$array[2] = [ 'foo', 7 ];
$array[5] = [ -6, [ 64 ], 'one', \$scalar ];
is( colorstrip( d(@array) ),
'[
    [0]  1,
    [1]  2,
    [2]  [
        [0] "foo",
        [1] 7,
    ],
    [3]  4,
    [4]  5,
    [5]  [
        [0] -6,
        [1] [
            [0] 64,
        ],
        [2] "one",
        [3] \\ 4.2,
    ],
    [6]  7,
    [7]  8,
    [8]  9,
    [9]  10,
    [10] 11,
]', 'nested array');

my %hash = ( foo => 33, bar => 99 );
is( colorstrip( d(%hash) ),
'{
    bar    99,
    foo    33,
}', 'simple hash');

$hash{$scalar} = \$scalar;
$hash{hash} = { 1 => 2, 3 => { 4 => 5 }, 10 => 11 };
$hash{something} = [ 3 .. 5 ];
$hash{zelda} = 'moo';

is( colorstrip( d(%hash) ),
'{
    4.2          \\ 4.2,
    bar          99,
    foo          33,
    hash         {
        1     2,
        3     {
            4    5,
        },
        10    11,
    },
    something    [
        [0] 3,
        [1] 4,
        [2] 5,
    ],
    zelda        "moo",
}', 'nested hash');

@array = ( { 1 => 2 }, 3, { 4 => 5 } );
is( colorstrip( d(@array) ),
'[
    [0] {
        1    2,
    },
    [1] 3,
    [2] {
        4    5,
    },
]', 'array of hashes');

my $array_ref = [ 1..2 ];
@array = ( 7, \$array_ref, 8 );
is( colorstrip( d(@array) ),
'[
    [0] 7,
    [1] \\ [
        [0] 1,
        [1] 2,
    ],
    [2] 8,
]', 'reference of an array reference');

my $hash_ref = { c => 3 };
%hash = ( a => 1, b => \$hash_ref, d => 4 );
is( colorstrip( d(%hash) ),
'{
    a    1,
    b    \\ {
        c    3,
    },
    d    4,
}', 'reference of a hash reference');

is( colorstrip( d($array_ref) ),
'\\ [
    [0] 1,
    [1] 2,
]', 'simple array ref' );

is( colorstrip( d($hash_ref) ),
'\\ {
    c    3,
}', 'simple hash ref' );

# null tests
$scalar = undef;
$scalar_ref = \$scalar;
is( colorstrip( d($scalar) ), 'undef', 'null test' );

is( colorstrip( d($scalar_ref) ), '\\ undef', 'null ref' );

@array = ( undef, undef, [ undef ], undef );
is (colorstrip( d(@array) ),
'[
    [0] undef,
    [1] undef,
    [2] [
        [0] undef,
    ],
    [3] undef,
]', 'array with undefs' );

%hash = ( 'undef' => undef, foo => { 'meep' => undef }, zed => 26 );
is( colorstrip( d(%hash) ),
'{
    foo      {
        meep    undef,
    },
    undef    undef,
    zed      26,
}', 'hash with undefs' );

my $sub = sub { 0 };
is ( colorstrip( d($sub) ), '\ sub { ... }', 'subref test' );

$array[0] = sub { 1 };
$array[2][1] = sub { 2 };
is (colorstrip( d(@array) ),
'[
    [0] sub { ... },
    [1] undef,
    [2] [
        [0] undef,
        [1] sub { ... },
    ],
    [3] undef,
]', 'array with subrefs' );


$hash{foo}{bar} = sub { 3 };
$hash{'undef'} = sub { 4 };
is( colorstrip( d(%hash) ),
'{
    foo      {
        bar     sub { ... },
        meep    undef,
    },
    undef    sub { ... },
    zed      26,
}', 'hash with subrefs' );


my $regex = qr{(?:moo(\d|\s)*[a-z]+(.?))}i;
is ( colorstrip( d($regex) ),
'\\ (?:moo(\d|\s)*[a-z]+(.?))  (modifiers: i)', 'regex with modifiers' );

$regex = qr{(?:moo(\d|\s)*[a-z]+(.?))};
is ( colorstrip( d($regex) ), '\ (?:moo(\d|\s)*[a-z]+(.?))', 'plain regex' );

$array[0] = qr{\d(\W)[\s]*};
$array[2][1] = qr{\d(\W)[\s]*};
is (colorstrip( d(@array) ),
'[
    [0] \d(\W)[\s]*,
    [1] undef,
    [2] [
        [0] undef,
        [1] \d(\W)[\s]*,
    ],
    [3] undef,
]', 'array with regex' );

$hash{foo}{bar} = qr{\d(\W)[\s]*};
$hash{'undef'} = qr{\d(\W)[\s]*};
is( colorstrip( d(%hash) ),
'{
    foo      {
        bar     \d(\W)[\s]*,
        meep    undef,
    },
    undef    \d(\W)[\s]*,
    zed      26,
}', 'hash with regex' );

$scalar = 3;
$scalar_ref = \$scalar;
my $ref2 = \$scalar;
@array = ($scalar, $scalar_ref, $ref2);
is( colorstrip( d(@array) ),
'[
    [0] 3,
    [1] \\ 3,
    [2] \\ var[1],
]', 'scalar refs in array' );

@array = ();
$array_ref = [];
$hash_ref = {};
$regex = qr{test};
$scalar = 'foobar';

$array[0] = \@array;         # 'var'
$array[1] = $array_ref;
$array[1][0] = $hash_ref;
$array[1][1] = $array_ref;   # 'var[1]'
$array[1][0]->{foo} = $sub;
$array[1][2] = $regex;
$array[2] = $sub;            # 'var[1][0]{foo}'
$array[3] = $regex;          # 'var[1][2]'
$array[4] = $scalar;
$array[5] = $scalar_ref;
$array[6] = $scalar_ref;
$array[7] = \$scalar;
is( colorstrip( d(@array) ),
'[
    [0] var,
    [1] [
        [0] {
            foo    sub { ... },
        },
        [1] var[1],
        [2] test,
    ],
    [2] var[1][0]{foo},
    [3] var[1][2],
    [4] "foobar",
    [5] \\ "foobar",
    [6] \\ var[5],
    [7] \\ var[5],
]', 'handling repeated and circular references' );


done_testing;