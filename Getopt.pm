# $Revision: 1.17 $$Date: 2003/07/03 15:26:25 $$Author: wsnyder $
# Author: Wilson Snyder <wsnyder@wsnyder.org>
######################################################################
#
# This program is Copyright 2002 by Wilson Snyder.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of either the GNU General Public License or the
# Perl Artistic License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# If you do not have a copy of the GNU General Public License write to
# the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, 
# MA 02139, USA.
######################################################################

package P4::Getopt;
require 5.006_001;

use strict;
use vars qw($VERSION $AUTOLOAD $Debug %Args);
use Carp;
use IO::File;
use Cwd;

######################################################################
#### Configuration Section

$VERSION = '2.020';

#p4 -s -c <client> -d <pwd> -H <host> -p <port> -P <password> -u <user> -C <charset> 

# List of commands and arguments.
# Three forms
#    [-switch]
#    [-switch argument]
#    nonoptional...		# Many parameters
#    nonoptional		# One parameter
#    [optional...]		# Many parameters
#    [optional]			# One parameter
# The argument "files" is specially detected by c4 for filename parsing.

%Args = (
  'add'		=>'[-c changelist] [-t type] file...',
  'admin'	=>'[-z] cmds...',
  'branch'	=>'[-i] [-o] [-d] [-f] branchspec',
  'branches'	=>'',
  'change'	=>'[-i] [-o] [-d] [-f] [-s] [changelist]',
  'changes'	=>'[-i] [-l] [-c client] [-m maxnum] [-s status] [-u user] [file...]',
  'client'	=>'[-i] [-o] [-d] [-f] [-t template] [client]',
  'clients'	=>'',
  'counter'	=>'[-d] [-f] countername [value]',
  'counters'	=>'',
  'delete'	=>'[-c changelist] file...',
  'depot'	=>'[-i] [-o] [-d] depotname',
  'depots'	=>'',
  'describe'	=>'[-dn] [-dc] [-ds] [-du] [-s] changelist',
  'diff'	=>'[-d*] [-f] [-sa] [-sd] [-se] [-sr] [-t] [filerev...]',
  'diff2'	=>'[-d*] [-q] [-t] [-b branch] [filerev] [filerev2]',
  'dirs'	=>'[-C] [-D] [-H] [-t type] depotdirectory...',
  'edit'	=>'[-c changelist] [-t type] file...',
  'filelog'	=>'[-i] [-l] [-m maxrev] file...',
  'files'	=>'filerev...',
  'fix'		=>'[-d] [-s status] [-c changelist] jobName...',
  'fixes'	=>'[-i] [-j jobname] [-c changelist] [filerevs...]',
  'flush'	=>'[-n] [filerevs...]',
  'fstat'	=>'[-c changelist] [-C] [-l] [-H] [-P] [-s] [-W] filerev...',
  'group'	=>'[-i] [-o] [-d] groupname',
  'groups'	=>'[user]',
  'have'	=>'[file...]',
  'help'	=>'[keywords...]',
  'info',	=>'',
  'integrate'	=>'[-i] [-c changelist] [-d] [-f] [-n] [-r] [-t] [-v] [-b branch] [-s fromfile] [filerevs...]',
  'integrated'	=>'file...',
  'job'		=>'[-i] [-o] [-d] [-f] [jobname]',
  'jobs'	=>'[-i] [-e jobview] [-R] [-l] [-r] [-m max] [filerev...]',
  'jobspec'	=>'[-i] [-o]',
  'label'	=>'[-i] [-o] [-f] [-t template] labelname',
  'labels'	=>'filerevs',
  'labelsync'	=>'[-a] [-d] [-n] -l labelname [filerevs...]',
  'lock'	=>'[-c changelist] [file ...]',
  'logger'	=>'[-c sequence] [-t countername]',
  'obliterate'	=>'[-y] filerevs...',
  'opened'	=>'[-a] [-c changelist] [file...]',
  'passwd'	=>'[-O oldpassword] [-P newpassword] [user]',
  'print'	=>'[-o outfile] [-q] filerev...',
  'protect'	=>'[-o] [-i]',
  'reopen'	=>'[-c changelist] [-t type] file...',
  'resolve'	=>'[-af] [-am] [-as] [-at] [-ay] [-f] [-n] [-t] [-v] [file...]',
  'resolved'	=>'[file...]',
  'revert'	=>'[-c changelist] [-a] file...',
  'review'	=>'[-c changelist] [-t countername]',
  'reviews'	=>'[-c changelist] [file...]',
  'set'		=>'[-s] [-S svcname] [varvalue]',
  'sync'	=>'[-f] [-n] [files...]',
  'triggers'	=>'[-i] [-o]',
  'typemap'	=>'[-i] [-o]',
  'unlock'	=>'[-c changelist] [-f] file...',
  'user'	=>'[-d] [-i] [-o] [-f] [username]',
  'users'	=>'[user...]',
  'verify'	=>'[-q] [-u] [-v] file...',
  'where'	=>'[file...]',
  # Flags added      
  'submit'	=>'[-i] [-f] [-r] [-c changelist] [-s] [files]',  # Added -f
  # C4's own
  'client-create' =>'[-i] [-o] [-d] [-f] [-rmdir] [-c4] [-t template] [client]',
  'client-delete' =>'[-d] [-f] [client]',
  'update'	=>'[-n] [-f] [files...]',
  'unknown'	=>'[files...]',
);

#######################################################################
#######################################################################
#######################################################################

sub new {
    @_ >= 1 or croak 'usage: P4::Getopt->new ({options})';
    my $class = shift;		# Class (Getopt Element)
    $class ||= __PACKAGE__;
    my $defaults = {client=>$ENV{P4CLIENT},	#-c <>
		    pwd=>Cwd::getcwd(),	#-d <>
		    host=>$ENV{P4HOST},	#-H <>
		    port=>$ENV{P4PORT},	#-p <>
		    password=>$ENV{P4PASSWD}, #-P <>
		    script=>0,		#-s
		    user=>($ENV{P4USER}||$ENV{USER}||$ENV{USERNAME}), #-u <>
		    charset=>$ENV{P4CHARSET}, # -C
		    # Ours
		    noop=>0,		#-n
		    fileline=>'Command_Line:0',
		};
    my $self = {%{$defaults},
		defaults=>$defaults,
		@_,
	    };
    bless $self, $class;
    return $self;
}

#######################################################################
# Option parsing

sub parameter_file {
    my $self = shift;
    my $filename = shift;
    # Parse: -x <filename>  files

    print "*parameter_file $filename\n" if $Debug;
    my $fh = IO::File->new($filename) or die "%Error: ".$self->fileline().": $! $filename\n";
    my $hold_fileline = $self->fileline();
    while (my $line = $fh->getline()) {
	chomp $line;
	$line =~ s/\/\/.*$//;
	next if $line =~ /^\s*$/;
	$self->fileline ("$filename:$.");
	my @p = (split /\s+/,"$line ");
	$self->parameter (@p);
    }
    $fh->close();
    $self->fileline($hold_fileline);
}

sub parameter {
    my $self = shift;
    # Parse a parameter. Return list of leftover parameters
    
    my @new_params = ();
    foreach my $param (@_) {
	next if ($param =~ /^\s*$/);
	print " parameter($param)\n" if $Debug;
	if ($self->{_parameter_unknown}) {
	    push @new_params, $param;
	    next;
	}

	if ($param eq '-c'
	    || $param eq '-d'
	    || $param eq '-H'
	    || $param eq '-p'
	    || $param eq '-P'
	    || $param eq '-u'
	    || $param eq '-C'
	    || $param eq '-x'
	    ) {
	    $self->{_parameter_next} = $param;
	}
	elsif ($param eq '-s') {
	    $self->{script} = 1;
	} elsif ($param eq '-n') {
	    $self->{noop} = 1;	# Cvs compatibility
	}
	# Second parameters
	elsif ($self->{_parameter_next}) {
	    my $pn = $self->{_parameter_next};
	    $self->{_parameter_next} = undef;
	    if ($pn eq '-x') {
		$self->parameter_file ($param);
	    } elsif ($pn eq '-c') {
		$self->client ($param);
	    } elsif ($pn eq '-d') {
		$self->pwd ($param);
	    } elsif ($pn eq '-H') {
		$self->host ($param);
	    } elsif ($pn eq '-p') {
		$self->port ($param);
	    } elsif ($pn eq '-P') {
		$self->password ($param);
	    } elsif ($pn eq '-u') {
		$self->user ($param);
	    } elsif ($pn eq '-C') {
		$self->charset ($param);
	    } else {
		die "%Error: ".$self->fileline().": Bad internal next param ".$pn;
	    }
	}
	elsif ($param !~ /^-/) { # Unknown.  Ignore rest.
	    push @new_params, $param;
	    $self->{_parameter_unknown} = 1;
	}
    }
    return @new_params;
}

#######################################################################
# Accessors

sub _param_changed {
    my $self = shift;
    my $param = shift;
    return (($self->{$param}||"") ne ($self->{defaults}{$param}||""));
}

sub get_parameters {
    my $self = shift;
    my @params = ();
    push @params, ("-c", $self->{client})	if _param_changed($self, 'client');
    push @params, ("-d", $self->{pwd})		if _param_changed($self, 'pwd');
    push @params, ("-h", $self->{host})		if _param_changed($self, 'host');
    push @params, ("-p", $self->{port})		if _param_changed($self, 'port');
    push @params, ("-P", $self->{password})	if _param_changed($self, 'password');
    push @params, ("-s")    			if _param_changed($self, 'script');
    push @params, ("-u", $self->{user})		if _param_changed($self, 'user');
    push @params, ("-C", $self->{charset})	if _param_changed($self, 'charset');
    return (@params);
}

#######################################################################
# Methods

sub setClientOpt {
    my $self = shift;
    my $client = shift or carp "%Error: usage setClientOpt(P4::Client object),";

    print "SetClient(".$self->client.")\n" if $self->client && $Debug;
    print "SetPort(".$self->port.")\n" if $self->port && $Debug;
    print "SetPassword(".$self->password.")\n" if $self->password && $Debug;

    $client->SetClient($self->client) if $self->client;
    $client->SetPort($self->port) if $self->port;
    $client->SetPassword($self->password) if $self->password;
}

sub parseCmd {
    my $self = shift;
    my $cmd = shift;
    my @args = @_;

    # Returns an array elements for each parameter.
    #    It's what the given argument is
    #		Switch, The name of the switch, or unknown
    my $cmdTemplate = $Args{$cmd};
    print "parseCmd($cmd @args) -> $cmdTemplate\n" if $Debug;
    my %parser;  # Hash of switch and if it gets a parameter
    my $paramNum=0;
    my $tempElement = $cmdTemplate;
    while ($tempElement) {
	$tempElement =~ s/^\s+//;
	if ($tempElement =~ s/^\[(-\S+)\]//) {
	    $parser{$1} = {what=>'switch', then=>undef, more=>0,};
	} elsif ($tempElement =~ s/^\[(-\S+)\s+(\S+)\]//) {
	    $parser{$1} = {what=>'switch', then=>$2,    more=>0,};
	} elsif ($tempElement =~ s/^\[(\S+)\.\.\.\]//) {
	    $parser{$paramNum} = {what=>$1, then=>undef, more=>1,};
	    $paramNum++;
	} elsif ($tempElement =~ s/^\[(\S+)\]//) {
	    $parser{$paramNum} = {what=>$1, then=>undef, more=>0,};
	    $paramNum++;
	} elsif ($tempElement =~ s/^(\S+)\.\.\.//) {
	    $parser{$paramNum} = {what=>$1, then=>undef, more=>1,};
	    $paramNum++;
	} elsif ($tempElement =~ s/^(\S+)//) {
	    $parser{$paramNum} = {what=>$1, then=>undef, more=>0,};
	    $paramNum++;
	} else {
	    die "Internal %Error: Bad Cmd Template $cmd/$paramNum: $cmdTemplate,";
	}
    }
    #use Data::Dumper; print Dumper(\%parser) if $Debug||1;

    my @out;
    my $inSwitch;
    $paramNum = 0;
    foreach my $arg (@args) {
	my $argone = substr($arg,0,2)."*";   #  -dw -> -d* for diff detection
	if ($arg =~ /^-/ && $parser{$arg}) {
	    push @out, $parser{$arg}{what};
	    $inSwitch = $parser{$arg}{then};
	} elsif ($arg =~ /^-/ && $parser{$argone}) {
	    push @out, $parser{$argone}{what};
	    $inSwitch = $parser{$argone}{then};
	} else {
	    if ($inSwitch) {   # Argument to a switch
		push @out, $inSwitch;
		$inSwitch = 0;
	    } elsif ($parser{$paramNum}) {  # Named [optional?] argument
		push @out, $parser{$paramNum}{what};
		$paramNum++ if !$parser{$paramNum}{more};
	    } else {
		push @out, "unknown";
	    }
	}
    }
    return @out;
}

sub hashCmd {
    my $self = shift;
    my $cmd = shift;
    my @args = @_;

    my %hashed;
    my @cmdParsed = $self->parseCmd($cmd, @args);
    #use Data::Dumper; print Dumper(\@args, \@cmdParsed);
    for (my $i=0; $i<=$#cmdParsed; $i++) {
	if ($cmdParsed[$i] eq 'switch') {
	    $hashed{$args[$i]} = 1;
	} else {
	    if (!ref $hashed{$cmdParsed[$i]}) {
		$hashed{$cmdParsed[$i]} = [$args[$i]];
	    } else {
		push @{$hashed{$cmdParsed[$i]}}, $args[$i];
	    }
	}
    }
    return %hashed;
}

#######################################################################

sub AUTOLOAD {
    my $self = $_[0];
    my $func = $AUTOLOAD;
    $func =~ s/.*:://;
    if (exists $self->{$func}) {
	eval "sub $func { \$_[0]->{'$func'} = \$_[1] if defined \$_[1]; return \$_[0]->{'$func'}; }; 1;" or die;
	goto &$AUTOLOAD;
    } else {
	croak "Undefined ".__PACKAGE__." subroutine $func called,";
    }
}

sub DESTROY {}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::Getopt - Get P4 command line options

=head1 SYNOPSIS

  use P4::Getopt;

  my $opt = new P4::Getopt;
  $opt->parameter (qw( -u username ));

  @ARGV = $opt->parameter (@ARGV);
  ...
=head1 DESCRIPTION

The C<P4::Getopt> package provides standardized handling of global options
for the front of P4 commands.

=over 4

=item $opt = P4::Getopt->new ( I<opts> )

Create a new Getopt.

=item $self->get_parameter ( )

Returns a list of parameters that when passed through $self->parameter()
should result in the same state.  Often this is used to form command lines
for wrappers that want to call p4 underneath themselves.

=item $self->parameter ( \@params )

Parses any recognized parameters in the referenced array, removing the
standard parameters and returning a array with all unparsed parameters.

The below list shows the parameters that are supported, and the
functions that are called:

    -c <client>      client
    -d <pwd>	     pwd
    -H <host>        host
    -p <port>        port
    -P <password>    password
    -s               script (set true)
    -u <user>        user
    -C <charset>     charset
    -n               noop (set true)    CVS compatible option

    -x <file>        Read given file and parse args automatically

=back

=head1 ACCESSORS

There is a accessor for each parameter listed above.  In addition:

=over 4

=item $self->fileline()

The filename and line number last parsed.

=item $self->parseCmd(<cmd>, <opts>)

Return a array with one element for each option.  The element is either
'switch', the name of the switch the option is specifing, or the name of
the parameter.

=item $self->hashCmd(<cmd>, <opts>)

Return a hash with one key for each option.  The value of the key is 1 if a
no-argument option was set, else it is an array with each value the option
was set to.

=item $self->setClientOpt(<P4::Client>)

Set the client, port, and password based on the options.

=back

=head1 SEE ALSO

C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
