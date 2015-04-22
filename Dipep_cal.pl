#!/usr/bin/perl
##calculates dipeptide composition##
@AA =qw ( A C D E F G H I K L M N P Q R S T V W Y);
for($i=0;$i<@AA;$i++)
{
    for($j=0;$j<@AA;$j++)
    {
	$dipep[$c]="$AA[$i]$AA[$j]";
	$c++;
    }
}

$file1=$ARGV[0];

open(fp, $file1);
while($line = <fp>) 
{
    chomp($line); 
    if($line !~/>/) 
    {   

	$len=length($line);
#	print"LENGTH===$len\n";
	@var='';
	$s1=0;
	for($s=0;$s<($len-1);$s++) 
	{
	    $var[$s]=substr($line,$s1,2);
	    $s1++;	
	}   
	$count=0;
	for($a=0;$a<@dipep;$a++)
	{
	    for($s=0;$s<@var;$s++) 
	    {
		#print "$var[$s]\n";
	       if("$var[$s]" eq "$dipep[$a]")
	       {
#		   print "$var[$s]---$dipep[$a]---$count\n";
		   $count++;
	       }
	   }


	    $dipep_count[$m]=$count;

	    $m++;
	    $count=0;
	}
#	print "@dipep_count\n";
	$m=0;
#	print "0 ";
	for($dd=1;$dd<401;$dd++)
	{
	    $new_dipep_count=($dipep_count[$dd]/$len)*100;
#	    print "$dd:";
	    printf"%7.5f ",$new_dipep_count;
	}

	print "\n";
    }
    @dipep_count='';
    $len=0;
#    $r=<STDIN>;
}




