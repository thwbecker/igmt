################################################################################
#    iGMT: Interactive Mapping of Geoscientific Datasets.                      #
#               Easy access to GMT via a Tcl/Tk GUI                            #
#                                                                              #
#    Copyright (C) 1998  Thorsten W. Becker, Alexander Braun                   #
#                                                                              #
#    This program is free software; you can redistribute it and/or modify      #
#    it under the terms of the GNU General Public License as published by      #
#    the Free Software Foundation; either version 2 of the License, or         #
#    (at your option) any later version.                                       #
#                                                                              #
#    This program is distributed in the hope that it will be useful,           #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of            #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
#    GNU General Public License for more details.                              #
#                                                                              #
#                                                                              #
#    You should have received a copy of the GNU General Public License         #
#    along with this program; see the file COPYING.  If not, write to          #
#    the Free Software Foundation, Inc., 59 Temple Place - Suite 330,          #
#    Boston, MA 02111-1307, USA.                                               #
#                                                                              #
################################################################################

################################################################################
# igmt_datasetss.tcl -- dialogs used to select raster and polygone data sets
#
# part of the iGMT package
#
################################################################################


proc choose_raster_datasets { masterwindow } {
    global raster_dataset
    toplevel .crd -class Dialog
    wm title .crd "Choice of raster data sets" 
    wm iconname .crd Dialog

    frame .crd.up 
    
    label .crd.up.label -text "Raster data set choices" 
################################################################################
# list the choices for the raster sets here

    radiobutton .crd.up.r1 -text "pscoast land and sea coverage alone" \
	-relief flat -variable raster_dataset -value 1  
    radiobutton .crd.up.r2 -text "ETOPO5 topography and bathymetry" -relief flat \
	-variable raster_dataset -value 2  
    radiobutton .crd.up.r3 -text "Smith & Sandwell topography and bathymetry" \
	-relief flat -variable raster_dataset -value 3  
    radiobutton .crd.up.r4 -text "Seafloor age and pscoast land coverage"  \
	-relief flat -variable raster_dataset -value 4 
    radiobutton .crd.up.r5 -text "Free air gravity on sea and pscoast land coverage"\
	-relief flat -variable raster_dataset -value 5 
    radiobutton .crd.up.r6 -text "Geoid (osu91a1f)"\
	-relief flat -variable raster_dataset -value 6
    radiobutton .crd.up.r7 -text "Custom raster data set"\
	-relief flat -variable raster_dataset -value 7

# pack the stuff

    pack .crd.up.label .crd.up.r1 .crd.up.r2 .crd.up.r3 \
	.crd.up.r4 .crd.up.r5  .crd.up.r6 .crd.up.r7 -side top
    pack .crd.up
    frame .crd.buttons
    button .crd.buttons.button1 -text "OK" -command exit_from_here
    pack .crd.buttons.button1 
    pack .crd.buttons
    pack .crd.up .crd.buttons -side top
    set oldFocus [focus]
    grab set .crd
    focus .crd   

    # exit and choose the new colormap corresponding to the raster 
    # data sets defaults

    proc exit_from_here {} {
	global saved colormap topocolor raster_dataset agecolor \
	    gravitycolor geoidcolor
	set saved 0 

	switch $raster_dataset {
	    "1" -
	    "2" -
	    "3" { set colormap $topocolor }
	    "4" { set colormap $agecolor }
	    "5" { set colormap $gravitycolor }
	    "6" { set colormap $geoidcolor }
	    default {  set colormap $topocolor }
	}
	set headermessage "iGMT: Changed raster data sets and default colormap."
	ret .crd 
    }


}

proc choose_polygon_datasets { masterwindow } {
    global polygon_dataset
    toplevel .cpd -class Dialog
    wm title .cpd "Choice of polygon data sets" 
    wm iconname .cpd Dialog
    frame .cpd.up 
    
    label .cpd.up.label -text "Polygon data set choices" 
################################################################################
# list the choices for the polygon data sets here
    
    label .cpd.up.l1 -text "Plate boundaries etc."
    checkbutton .cpd.up.r1 -text "Plate boundaries (NUVEL)" \
	-relief flat -variable polygon_dataset(1) 
    checkbutton .cpd.up.r9 -text "Slab contours" \
	-relief flat -variable polygon_dataset(9) 
    checkbutton .cpd.up.r8 -text "Volcano locations"\
	-relief flat -variable polygon_dataset(8) 
    checkbutton .cpd.up.r7 -text "Hotspot locations"\
	-relief flat -variable polygon_dataset(7) 
    label .cpd.up.l2 -text "Earthquake data"
    checkbutton .cpd.up.r6 -text "CMT fault plane solutions" \
	-relief flat -variable polygon_dataset(6)
    checkbutton .cpd.up.r2 -text "Significant quakes (NGDC)" \
	-relief flat -variable polygon_dataset(2) 
    checkbutton .cpd.up.r3 -text "USGS/NEIC PDE quakes" \
	-relief flat -variable polygon_dataset(3) 
    label .cpd.up.l3 -text "Custom data"
    checkbutton .cpd.up.r4 -text "Custom x y size data 1"\
	-relief flat -variable polygon_dataset(4)
    checkbutton .cpd.up.r5 -text "Custom x y size data 2"\
	-relief flat -variable polygon_dataset(5)
    checkbutton .cpd.up.r10 -text "Velocity vectors" \
	-relief flat -variable polygon_dataset(10) 

# pack the stuff

    pack .cpd.up.label .cpd.up.l1 .cpd.up.r1 .cpd.up.r9 .cpd.up.r7 .cpd.up.r8  \
	.cpd.up.l2 .cpd.up.r6 .cpd.up.r2 .cpd.up.r3 \
	.cpd.up.l3 .cpd.up.r4 .cpd.up.r5 .cpd.up.r10 -side top
    pack .cpd.up
    frame .cpd.buttons
    button .cpd.buttons.button1 -text "OK" -command {set saved 0 ;\
           set headermessage "iGMT: Changed polygon data sets."; ret .cpd }
    pack .cpd.buttons.button1 
    pack .cpd.buttons
    pack .cpd.up .cpd.buttons -side top
    set oldFocus [focus]
    grab set .cpd
    focus .cpd   
}
