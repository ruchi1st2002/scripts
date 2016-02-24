#!/usr/bin/env perl

##parser.pl
###Search the best result with the friend list string

use strict;
use Bio::SearchIO;
use Bio::SeqIO;
use Getopt::Std;

my %options;
getopts ("i:p:f:c:", \%options);

#system (date);

my $file = $options{i};
my $outname = $options{p};
my $FriendGenomeString = $options{f};
my $poshitnum = 0;
my $neghitnum = 0;
my $totalhitnum = 0;
my $querynum = 0;
my $matchnum = 0;
my $QueryName;
my $QueryDesc;
my @FailedList;
my $FailFlag = 0;
my @FriendGenomeIdentifierList;

@FriendGenomeIdentifierList=split /,/, lc($FriendGenomeString);
for(my $i = 0; $i le $#FriendGenomeIdentifierList; $i++){
    $FriendGenomeIdentifierList[$i] =~ s/^\s+//;    #strip leading white space
    $FriendGenomeIdentifierList[$i] =~ s/\s+$//;    #strip trailing white space
}
print $FriendGenomeIdentifierList[0], "\n", @FriendGenomeIdentifierList;
open OUTPUT, ">$outname" or die $!;
open SEQFILE, ">$outname-probes.fasta" or die $!;

print OUTPUT  "\tTotal\tPositive\tNegitive\n";

my $in = new Bio::SearchIO(-format => 'blast', 
			   -file   => $file);
while( my $result = $in->next_result ) {
  ## $result is a Bio::Search::Result::ResultI compliant object
    $QueryName = $result->query_name;
    $QueryDesc = $result->query_description;
    my @hitname;
    while( my $hit = $result->next_hit ) {
    ## $hit is a Bio::Search::Hit::HitI compliant object
	my $hitdesc = lc($hit->description);
	my $i;
	my $friend = 0;
	for $i (@FriendGenomeIdentifierList){        
	    if( $hit->significance < 1e-9 && $hitdesc =~ /$i/) {
		$poshitnum++;
		$totalhitnum++;
		$friend = 1;
		last;
	    } 
	} 
	if ( $hit->significance < 1e-9 && $friend == 0) {
	    $neghitnum++;
	    $totalhitnum++;
	    push (@hitname, $hitdesc);
	    $FailFlag = 1;
	}
    }
    if ($FailFlag == 1){ push (@FailedList, "$QueryName $QueryDesc"); };
    $FailFlag = 0; 
    print OUTPUT  "$QueryName $QueryDesc\t$totalhitnum\t", $poshitnum, "\t", $neghitnum, "\t", @hitname;
    print OUTPUT  "\n";
    if ($totalhitnum >= 1){
	$matchnum++;
    }
    $poshitnum = 0; 
    $neghitnum = 0;
    $totalhitnum = 0;
    $querynum++;
    reset @hitname;
}  
print OUTPUT "\n\nNumber of probes:\t $querynum\nNumber of Matches:\t $matchnum\n";

foreach (@FailedList){
    print OUTPUT $_,"\n";
}

my $seq;
my $seq_IO;
my $Fail = 0;
$seq_IO = Bio::SeqIO->new( -format => 'fasta', -file => $options{c});

while ($seq = $seq_IO->next_seq){
    my $Fail = 0;
    my $seqname = join(' ', $seq->display_id,$seq->desc);
    my $i;
    for $i (@FailedList){
	if ($seqname eq $i){
	    $Fail++;
	}
    }
    if ($Fail == 0) {
	print SEQFILE ">", $seqname, "\n", $seq->seq, "\n";
    }
}

#system (date);
