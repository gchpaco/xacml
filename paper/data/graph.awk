BEGIN {
  FS="\t"
  ORS=""
  slopnum = 1
}

$1 ~ /Slop/ {
  currentslop = $2
  slops[slopnum++] = $2
  datanum = 1
}

$1 !~ /Slop/ {
  if (! ($1 in datums))
    datums[datanum++] = $1
  data[currentslop, $1] = NF
  for (i = 2; i <= NF; i++)
    data[currentslop, $1, i] = $i
}

END {
  n = asort(datums)
  m = asort(slops)
  runs = data[slops[1], datums[1]]
  print "Slop"
  for (i = 2; i <= runs; i++)
    print "\tRun #" (i - 1)
  print "\n"
  for (i = 1; i <= n; i++) {
    datum = datums[i]
    print datum "\n"
    for (j = 1; j <= m; j++) {
      slop = slops[j]
      print slop
      for (k = 2; k <= runs; k++)
	printf "\t%4.2f", data[slop, datum, k]
      print "\n"
    }
  }
}