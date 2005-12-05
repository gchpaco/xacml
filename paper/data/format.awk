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
  if ($2 ~ /Error/)
    data[currentslop, $1] = "Error!"
  else {
    for (i = 2; i <= NF; i++)
      things[i - 1] = $i
    n = asort (things)
    data[currentslop, $1] = things[3]
  }
}

END {
  n = asort(slops)
  m = asort(datums)
  for (i = 1; i <= n; i++) {
    slop = slops[i]
    print slop
    for (j = 1; j <= m; j++) {
      datum = datums[j]
      if (data[slop, datum] ~ /Error/)
	printf " & "
      else
	printf " & %4.1f s", data[slop, datum]
    }
    if (i != n)
      print " \\\\\n"
    else
      print "\n"
  }
}