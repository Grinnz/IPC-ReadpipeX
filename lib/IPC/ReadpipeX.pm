package IPC::ReadpipeX;

use strict;
use warnings;
use Carp 'croak';
use Exporter 'import';
use IPC::Open3;

our $VERSION = '0.001';

our @EXPORT = 'readpipex';

sub readpipex {
  my @cmd = @_;
  # IPC::Open3 closes the STDIN handle in the parent, so give it a dup of STDIN
  open my $dup, '<&', \*STDIN or croak "dup STDIN failed: $!";
  my $stdin = '<&' . fileno $dup;
  my ($pid, $stdout, $error);
  {
    local $@;
    $error = $@ unless eval { $pid = open3 $stdin, $stdout, '>&STDERR', @cmd; 1 };
  }
  # Rethrow for better context
  croak $error if defined $error;
  my @output = wantarray ? readline($stdout) : do { local $/; scalar readline $stdout };
  waitpid $pid, 0;
  return wantarray ? @output : $output[0];
}

1;

=head1 NAME

IPC::ReadpipeX - List form of readpipe/qx/backticks for capturing output

=head1 SYNOPSIS

  use IPC::ReadpipeX;

  my @entries = readpipex 'ls', '-l', $path;
  if ($?) {
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
provides this capability in a simple copy-pastable function.

For other methods of redirecting output, capturing STDERR, and interacting with
the process, consider the modules listed in L</"SEE ALSO">.

=head1 FUNCTIONS

C<readpipex> is exported by default.

=head2 readpipex

  my $output = readpipex $cmd, @args;
  my @output = readpipex $cmd, @args;

Runs the given command, capturing STDOUT and returning it as a single string in
scalar context, or an array of lines in list context. If more than one argument
is passed, the command will be executed directly rather than via the shell, as
in L<system|perlfunc/"system"> and L<exec|perlfunc/"exec">.

Errors forking or running the command will raise an exception, and
L<$!|perlvar/"$!"> will be set to the error code. The exit status of the
process is otherwise available in L<$?|perlvar/"$?"> as normal.

On systems that support forking with Perl 5.8 or newer, and Windows with Perl
5.22 or newer, the simple code below can be copy-pasted to implement readpipex.

  sub readpipex {
    no warnings 'exec';
    open my $stdout, '-|', @_ or die "readpipex '$_[0]' failed: $!";
    my @output = readline $stdout;
    close $stdout;
    return wantarray ? @output : join '', @output;
  }

=head1 CAVEATS

=over

=item *

Behavior when passing no arguments is unspecified.

=item *

Errors while reading or closing the pipe, though exceedingly rare, are ignored,
as in the core readpipe.

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
optional exit status checking and variants that always bypass the shell

=item *

L<IPC::Run3> - run a process and direct STDIN, STDOUT, and STDERR

=item *

L<Capture::Tiny> - capture STDOUT and STDERR in any wrapped code

=item *

L<IO::Async::Process> - complete asynchronous control over a process and its
handles

=back
