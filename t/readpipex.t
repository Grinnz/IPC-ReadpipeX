use strict;
use warnings;
use Test::More;
use Test::Warnings;
use IPC::ReadpipeX;

$? = 1;
is readpipex($^X, '-e', 'print "42\n43\n"'), "42\n43\n", 'right output';
is $?, 0, '$? is 0';

$? = 1;
is_deeply [readpipex($^X, '-e', 'print "42\n43\n"')], ["42\n","43\n"], 'right output';
is $?, 0, '$? is 0';

is readpipex($^X, '-e', 'exit 5'), '', 'no output';
is +($? >> 8), 5, 'exit status is 5';

$! = 0;
is readpipex('command-that-does-not-exist', 'args'), undef, 'invalid command';
is $?, -1, '$? is -1';
isnt 0+$!, 0, '$! is set';

done_testing;
