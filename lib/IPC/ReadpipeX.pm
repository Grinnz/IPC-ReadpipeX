package IPC::ReadpipeX;

use strict;
use warnings;
use Exporter 'import';

our $VERSION = '0.001';

our @EXPORT = 'readpipex';

sub readpipex {
  no warnings 'exec';
  open my $stdout, '-|', @_ or do { $? = -1; return };
  my @output = readline $stdout;
  close $stdout;
  return wantarray ? @output : join '', @output;
}

1;

=head1 NAME

IPC::ReadpipeX - List form of readpipe/qx/backticks for capturing output

=head1 SYNOPSIS

  use IPC::ReadpipeX;

  my @entries = readpipex 'ls', '-l', $path;
  if ($? == -1) {
    die "ls '$path' failed: $!";
  } elsif ($?) {
    my $exit = $? >> 8;
    die "ls '$path' exited with status $exit";
  }

  my $hostname = readpipex 'hostname', '-f';
  chomp $hostname;

=head1 DESCRIPTION

The built-in L<readpipe|perlfunc/"readpipe"> function, also known as the C<qx>
operator or backticks (C<``>), runs a command and captures the output (STDOUT).
However, unlike L<system|perlfunc/"system"> and L<exec|perlfunc/"exec">, the
command will always be parsed by the shell, and it does not provide a list form
to bypass shell parsing when multiple arguments are passed. L</"readpipex">
provides this capability for systems that support forking, in a simple
copy-pastable function.

For other methods of redirecting output, capturing STDERR, interacting with the
process, operating system portability, and automatic error-checking, consider
the modules listed in L</"SEE ALSO">.

=head1 FUNCTIONS

C<readpipex> is exported by default.

=head2 readpipex

  my $output = readpipex $cmd, @args;
  my @output = readpipex $cmd, @args;

Runs the given command, capturing STDOUT and returning it as a single string in
scalar context, or an array of lines in list context. If more than one argument
is passed, the command will be executed directly rather than via the shell, as
in L<system|perlfunc/"system"> and L<exec|perlfunc/"exec">.

Like the core L<readpipe|perlfunc/"readpipe"> function and C<qx> operator,
errors forking or running the command are indicated by L<$?|perlvar/"$?"> being
set to C<-1>, and L<$!|perlvar/"$!"> can be inspected to determine the error.
The exit status of the process is otherwise available in L<$?|perlvar/"$?">.

The code of this function can easily be copy-pasted and is shown below.

  sub readpipex {
    open my $stdout, '-|', @_ or do { $? = -1; return };
    my @output = readline $stdout;
    close $stdout;
    return wantarray ? @output : join '', @output;
  }

=head1 CAVEATS

=over

=item *

Behavior when passing no arguments is unspecified.

=item *

The list form of L<open|perlfunc/"open"> requires Perl 5.8+.

=item *

The C<-|> open mode is unsupported on Windows.

=item *

Errors while reading or closing the pipe, though exceedingly rare, are ignored,
as in the core readpipe.

=item *

C<exec> warnings are disabled, because the code to handle these correctly would
be longer than the current function. Make sure to check C<$?> for failure.

=back

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

=over

=item *

L<IPC::System::Simple> - provides C<system> and C<capture> functions with
automatic error-checking, optional exit status checking, and variants that
always bypass the shell

=item *

L<IPC::Run3> - run a process and direct STDIN, STDOUT, and STDERR with
automatic error-checking

=item *

L<Capture::Tiny> - capture STDOUT and STDERR in any wrapped code

=item *

L<IO::Async::Process> - complete asynchronous control over a process and its
handles

=back
