#
# script to convert the data range of colorscale files for GMT
# by rescaling, based on -1 to 1 range as of the col.??.cpt
# files
#
# part of the iGMT distribution
# 
# Thorsten Becker, 04/05/99
#
# $Id$
#
BEGIN{
# if no arguments given, leave range the same
  if(min==0)min=-1.;
  if(max==0)max=1.;
  mean=(max+min)/2.;
  range=(max-min)/2.;
# number of intervals without annotation when psscale is used
  printevery=25;
}
{
  if(NR<256){
    if(printevery - NR > 0)
#no annotation
      print($1*range+mean,$2,$3,$4,$5*range+mean,$6,$7,$8,$9);
    else {
#annotate
      print($1*range+mean,$2,$3,$4,$5*range+mean,$6,$7,$8,$9,"L");
      printevery=NR+printevery;
    }
  }
  else
    print($0);

}
