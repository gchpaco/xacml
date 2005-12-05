BEGIN {
  FS="\t"
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
  ndat = asort(datums)
  mslop = asort(slops)
  runs = data[slops[1], datums[1]]

  for (i = 1; i <= ndat; i++) {
    datum = datums[i]
    
    n = mslop * runs
    sumx = 0
    sumy = 0
    sumxy = 0
    sumx2 = 0
    sumy2 = 0

    for (j = 1; j <= mslop; j++) {
      slop = slops[j]
      x = slop
      for (k = 2; k <= runs; k++) {
	point = data[slop, datum, k]
	y = log (point)

	sumx += x
	sumy += y
	sumxy += x * y
	sumx2 += x * x
	sumy2 += y * y
      }
    }

    m = (n * sumxy - sumx * sumy) / (n * sumx2 - sumx * sumx)
    m2 = (n * sumxy - sumx * sumy) / (n * sumy2 - sumy * sumy)
    b = (sumy - m * sumx) / n
    rcoeff = sqrt(m * m2)
    
    A = exp (b)
    r = exp (m)
    print m, b, A, r, rcoeff
    for (t = 1; t <= mslop; t++)
      print t, A * exp(t * log(r))
  }
}