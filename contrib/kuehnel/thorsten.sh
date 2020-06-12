#!/bin/sh
#
echo "Creating the basemap"
echo "Running the grid ...."
nearneighbor test_3d.dat -Ggrdfile.grd -I0.29/0.29 -R-2.9/2.9/-2.9/2.9 -N1 -S1.2064
echo "Creating the xyz plot ...."
grdview  grdfile.grd -K -JX6/6 -R-3.016/3.016/-3.016/3.016 -Cthorsten.cpt -Qs  -D3 -X1.8 -Y1.5 > thorsten.ps
psbasemap -O -K -JX6/6 -R-3.016/3.016/-3.016/3.016 -Bf1.2064a1.2064:"X-axis":/f1.2064a1.2064:"Y-axis"::."test_3d.dat":WeSn >> thorsten.ps
echo "Creating the scale ...."
psscale -Cthorsten.cpt -D7/2.5/5/0.5 -L -O >> thorsten.ps
ghostview -a4 thorsten.ps &
echo "Done"
