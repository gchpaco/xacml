#!/usr/bin/awk -f
BEGIN {
  FS = "\t";
  inoutput = 0;
  firsttime = 1;
  col = 1;
  cols = 2;
  
  height = 3;
  width = 2.5;

  hspacing = 1;
  vspacing = 1.5;

  print ".G1";
}

function beginoutput (title)
{
  if (firsttime)
    {
      print "graph A" col;
      firsttime = 0;
      print "frame invis ht " height " wid " width;
      print "label top \"" title "\"";
      print "label left \"Time (in seconds)\" left 0.2";
      print "label bot \"Number of elements per environment set\"";
      print "ticks left out";
    }
}

function endoutput ()
{
  print "#";
  col++;
  if (col > cols)
    col = 1;
}

{
  if ($1 != "Slop") {
    if ($1 ~ /^[0-9]/) {
      if ($2 != "Error!") {
	for (i = 2; i <= 6; i++) {
	  if (currentbatch ~ /^one/)
	    print "bullet at " $1 ", " $i;
	  else
	    print "delta at " $1 ", " $i;
	}
	print "tick bot at " $1 " \"" $1 "\"";
	#for (i = 2; i <= 6; i++)
	#  print "tick right at " $i " \"\"";
      }
    } else {
      currentbatch = $1
      inoutput = 1;
      beginoutput("Run times for $P sub 1$");
    }
  }
}

END {
  if (inoutput)
    endoutput();
  print ".G2";
}
