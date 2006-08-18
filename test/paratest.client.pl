#!/usr/bin/perl

# Usage: paratest.client.pl id chapeltestdir testdir distmode [compopts]
#  
# Used remotely by paratest.server.pl to run start_test locally.
#  id - used to create a file to synchronize with paratest.server.pl
#  chapeltestdir - root dir of Chapel test infrastructure
#  testdir - directory to run start_test on
#  compiler - Chapel compiler to use
# 

$debug = 0;
$logdir = "Logs";
$synchdir = "Logs/.synch";
$testcmd = "nice start_test";

sub systemd {
    my ($cmd) = @_;

    print "$cmd\n" if ($debug);
    system ($cmd);
}


sub main {
    my ($logfile, $synchfile, $workingdir, $testdir, $compiler, $platform);
    my ($node) = `uname -n`;
    chomp $node;
    ($node, $junk) = split (/\./, $node, 2);

    if ($#ARGV < 3) {
        print "@ARGV\n";
        print "usage: paratest.client.pl id chapeltestdir testdir distmode [compopts]\n";
        exit (3);
    }

    $id = $ARGV[0];
    $workingdir = $ARGV[1];
    $testdir = $ARGV[2];
    $distdir = $ARGV[3];

    if ($#ARGV==4) {
        $compopts = "-compopts ". $ARGV[4];
    }

    $synchfile = "$synchdir/$node.$id";

    unless (chdir ($workingdir)) {
        print "Error: cannot change to directory $workingdir\n";
        exit (2);
    }
    print "\n* $node up @ $workingdir *\n";

    $platform = `../util/platform`; chomp $platform;
    # $compiler = $ARGV[3];
    $compiler = "../compiler/$platform/chpl";
    unless (-e $compiler) {
        print "Error: cannot find chpl as '$compiler'\n";
        exit (2);
    }

    unless (-e $synchdir and -d $synchdir) {
        print "Error: synch directory $synchdir does not exist\n";
        exit (2);
    }

    print "$node $workingdir $testdir $compiler\n";

    $dirfname = $testdir;
    $dirfname =~ s/\//-/g;
    $logfile = "$logdir/$dirfname.$node.log";
    unlink $logfile if (-e $logfile);

    $testarg = "-compiler $compiler -logfile $logfile $compopts";
    if ($distdir) {
        $testarg = "$testarg -startdir $testdir -norecurse";
    } else {
        $testarg = "$testarg -onetest $testdir";
    }
    systemd ("$testcmd $testarg");

    systemd ("echo feed me > $synchfile");  # signal ready for more
}


main ();
