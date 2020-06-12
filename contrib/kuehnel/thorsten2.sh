#!/bin/sh
#
echo "Creating the basemap"
psxy  test_3d.dat -K -JX6/6 -R-3.016/3.016/-3.016/3.016 -Cthorsten2.cpt -Sc0.1 -X1.8 -Y1.5 > thorsten2.ps
psbasemap -O -K -JX6/6 -R-3.016/3.016/-3.016/3.016 -Bf1.2064a1.2064:"X-axis":/f1.2064a1.2064:"Y-axis"::."test_3d.dat":WeSn >> thorsten2.ps
echo "Creating the scale ...."
psscale -Cthorsten2.cpt -D7/2.5/5/0.5 -L -O >> thorsten2.ps
ghostview -a4 thorsten2.ps &
echo "Done"
