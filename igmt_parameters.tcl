
################################################################################
# igmt_parameters.tcl -- dialogs used to change the parameters
#
# part of the iGMT package
#
# $Id: igmt_parameters.tcl,v 1.11 2002-11-24 05:12:49-08 becker Exp tbecker $
#
################################################################################


# TO DO:
# most of the routines do not properly handle window placement. However,
# most of them already get the name of the master window as a parameters


################################################################################
# generic routine to change rgb colors 
################################################################################

proc change_color { array first_subscript titletext w } {
    upvar $array colorarray 
    global saved
    set cl [ format #%02x%02x%02x $colorarray($first_subscript,1) $colorarray($first_subscript,2) $colorarray($first_subscript,3) ]
    set cl1 [ tk_chooseColor -title $titletext -parent $w -initialcolor $cl ]
    if { $cl1 != "" } {
	set colorarray($first_subscript,1) [ format %3d 0x[ string range "$cl1" 1 2 ] ]
	set colorarray($first_subscript,2) [ format %3d 0x[ string range "$cl1" 3 4 ] ]
	set colorarray($first_subscript,3) [ format %3d 0x[ string range "$cl1" 5 6 ] ]
	set saved 0
    }
    #
    # this patch was need since the TclTk routine tk_chooseColor would return 
    # only 0 ... 254 values. we wanted real white rather than real black
    #
    foreach i { 1 2 3 } {
	set colorarray($first_subscript,$i) [ expr $colorarray($first_subscript,$i) + 1 ]
	if {  $colorarray($first_subscript,$i) > 255 } {
	    set colorarray($first_subscript,$i) 255 
	}
    }
}





################################################################################
# geographic region dialog
################################################################################


proc enter_region {} {
    global south east west north saved oldeast \
	oldwest oldsouth oldnorth headermessage proj \
	lon0 lat0
    toplevel .er -class Dialog
    wm title .er "Enter Region" 
    wm iconname .er Dialog
    
    # save values for restoring them if cancelled
    set oldeast $east
    set oldwest $west
    set oldsouth $south
    set oldnorth $north
    
    # eastern boundary 

    frame .er.east \
	-borderwidth {2} \
	-height {30} \
	-relief {raised} \
	-width {30}
    label .er.east.label \
	-text {Eastern boundary}
    scale .er.east.scale -length {330} \
	-orient {horizontal} -resolution 0.1 -tickinterval 90\
	-from -180.0  -variable east \
	-to 360.0 -command change_reg
    .er.east.scale set $east
    entry .er.east.entry -textvariable east 
    pack .er.east.label .er.east.scale -side top
    pack .er.east.scale .er.east.entry -side left
    pack .er.east

    frame .er.middle

    # northern b.

    frame .er.middle.north \
	-borderwidth {2} \
	-height {30} \
	-relief {raised} \
	-width {30}
    label .er.middle.north.label \
	-text {Northern boundary}
    scale .er.middle.north.scale -resolution 0.1\
	-length {200} -variable north \
	-from 90.0 -tickinterval 30 \
	-to -90.0 -command change_reg
    .er.middle.north.scale  set $north
    entry .er.middle.north.entry -textvariable north
    pack .er.middle.north.label .er.middle.north.scale -side top
    pack .er.middle.north.scale .er.middle.north.entry -side top
    pack .er.middle.north
    
    
    # middle region for lat0/lon0
    
    frame .er.middle.center
    
    frame .er.middle.center.top
    label .er.middle.center.top.l -text "Center of map projection"
    pack .er.middle.center.top.l
    pack .er.middle.center.top
    

    frame .er.middle.center.lon0 
    label .er.middle.center.lon0.label \
	-text "Longitude focus"
    scale .er.middle.center.lon0.scale \
	-length {150} -orient {horizontal} -command change_reg -variable lon0 \
	-from -180.0 -to 180.0 -tickinterval 90 -width 10
    .er.middle.center.lon0.scale set $lon0
    entry .er.middle.center.lon0.entry -textvariable lon0
    pack .er.middle.center.lon0.label .er.middle.center.lon0.scale \
	.er.middle.center.lon0.entry -side top
    pack .er.middle.center.lon0
    
    frame .er.middle.center.button
    button .er.middle.center.button.buttonc -text "Center" -relief groove -command center_focus_in_region
    pack    .er.middle.center.button.buttonc
    pack    .er.middle.center.button

    frame .er.middle.center.lat0 
    label .er.middle.center.lat0.label \
	-text "Lat. focus/ref. meridian"
    scale .er.middle.center.lat0.scale \
	-length {80} -command change_reg -variable lat0 \
	-from 90.0 -to -90.0 -tickinterval 90 -width 10
    .er.middle.center.lat0.scale set $lat0
    entry .er.middle.center.lat0.entry -textvariable lat0
    pack .er.middle.center.lat0.label .er.middle.center.lat0.scale \
	.er.middle.center.lat0.entry -side top
    pack .er.middle.center.lat0

    pack .er.middle.center.top .er.middle.center.lon0 .er.middle.center.button .er.middle.center.lat0 -side top

    pack .er.middle.center

    # southern boundary

    frame .er.middle.south \
	-borderwidth {2} \
	-height {30} \
	-relief {raised} \
	-width {30}
    label .er.middle.south.label \
	-text {Southern boundary}
    scale .er.middle.south.scale \
	-length {200} -command change_reg -variable south -resolution 0.1\
	-from 90.0 -to -90.0 -tickinterval 30
    .er.middle.south.scale set $south
    entry .er.middle.south.entry -textvariable south
    pack .er.middle.south.label .er.middle.south.scale -side top
    pack .er.middle.south.scale .er.middle.south.entry -side top
    pack .er.middle.south



    pack .er.middle.north  .er.middle.center .er.middle.south -side left -padx 7
    pack .er.middle


    # western boundary

    frame .er.west \
	-borderwidth {2} \
	-height {30} \
	-relief {raised} \
	-width {30}
    label .er.west.label \
	-text {Western boundary}
    scale .er.west.scale -length {330}  -resolution 0.1\
	-orient {horizontal} -variable west \
	-from -180.0 -tickinterval 90 \
	-to 360.0 -command change_reg
    .er.west.scale set $west
    entry .er.west.entry -textvariable west
    pack .er.west.label .er.west.scale -side top
    pack .er.west.scale .er.west.entry -side left
    pack .er.west


    # lower frane with action buttons
    
    frame .er.buttons
    button .er.buttons.button1 -text "OK" -relief groove -command  check_and_exit 
    button .er.buttons.button3 -text "The whole thing!" -relief groove -command  maximum_range
    button .er.buttons.button4 -text "\"Square\" it" -relief groove -command make_region_square
#    button .er.buttons.button5 -text "-180/180 <-> 0/360" -relief groove -command change_lon_mode
    button .er.buttons.button2 -text "Cancel" -relief groove -command {set south $oldsouth ; \
							    set north $oldnorth; set east $oldeast ; \
							set west $oldwest ; ret .er }
#    pack .er.buttons.button1 .er.buttons.button3 .er.buttons.button4 .er.buttons.button5 .er.buttons.button2 -side left
     pack .er.buttons.button1  \
	     .er.buttons.button3 \
	     .er.buttons.button4 \
	     .er.buttons.button2 -side left -padx 4

    pack .er.buttons
    
    pack .er.west .er.middle .er.east .er.buttons -side top
    set oldFocus [focus]
    grab set .er
    focus .er
    bind .er <Return> check_and_exit

    # check for region inconsistencies
    
    proc change_reg value { 
	global east west south north saved
	set east [ .er.east.scale get ]
	set west [ .er.west.scale get ]
	set north [ .er.middle.north.scale get ]
	set south [ .er.middle.south.scale get ]
	set lat0 [ .er.middle.center.lat0.scale get ]
	set lon0 [ .er.middle.center.lon0.scale get ]

	if { $north < $south } { set tmp $south ; set south $north ; set north $tmp }
	if { $east < $west }   { set tmp $east ; set east $west ; set west $tmp }


	set saved 0
    }
    
    # limit the maximum range for mercator

    proc maximum_range {} {
	global east west south north \
	    proj saved mercatorlimit lon0 lat0
	if { $proj(1) == "M"  } {
	    set north $mercatorlimit(1);
	    set south $mercatorlimit(2);
	    dialog .d {Mercator region warning} \
		"The maximum latitudes for Mercator are from $mercatorlimit(2) to $mercatorlimit(1)!\nChoose a different projection if you want -90 to 90."  warning 0 {OK} 
	    set east 180;
	    set west -180;
	} else { 
	    set north 90;
	    set south -90; 
	    set east 180;
	    set west -180;
	}
	set lon0 180
	set lat0 0
	set saved 0
    }

    # move the lat0 lon0 sliders to the center of the current
    # geographic region

    proc center_focus_in_region {} {
	global east west south north lon0 lat0

	set tmp1 [ expr ($east  + $west)/2.0 ]
	set lat0 [ expr ($north + $south)/2.0 ]
	if { $tmp1  > 180 } {
	    set tmp1 [ expr $tmp1 - 360 ]
	}
	set lon0 $tmp1
	return 
    }

    #
    # attempt to achieve a square like region by moving
    # the boundaries around their centers
    # does not compute real distances 
    proc make_region_square {} {
	global east west south north saved
	if { [ expr $east-$west ]  > [ expr $north-$south ] } {
	    set tmp [ expr ($north+$south)/2.0 ]
	    set north [ expr $tmp + ($east-$west)/2.0 ]
	    set south [ expr $tmp - ($east-$west)/2.0 ]
	} else {
	    set tmp [ expr ($east+$west)/2.0 ]
	    set east [ expr $tmp + ($north-$south)/2.0 ]
	    set west [ expr $tmp - ($north-$south)/2.0 ]
	}
	if { $north > 90.0 } { set north 90 }
	if { $south < -90.0 } { set south -90 }
	if { $west > 180.0 } { set west 180}
	if { $east < -180.0 } { set east -180}
	set saved 0
    }
    #
    # go from -180 / 180 to 0 / 360 style and vice versa
    #
    proc change_lon_mode {} {
	global east west south north saved
	set mode 0
	if { ($west == -180) && ($east == 180) } {
	    set west 0 
	    set east 360
	} elseif { ($west == 0) && ($east == 360) } {
	    set west -180
	    set east 180
	} else {
	    if { $east > 180 } {
		set east [ expr $east - 360 ]
		set mode 1
	    } 
	    if { $west > 180 } {
		set west [ expr $west - 360 ]
		set mode 1
	    } 
	    if { $mode == 0 } {
		if { $east <= 0 } {
		    set east [ expr 360 + $east ]
		} 
		if {  $west <= 0  } {
		    set west [ expr 360 + $west ]
		}
	    }
	    if { $east < $west } {
		set tmp $east
		set east $west
		set west $tmp
	    }
	}
	set saved 0
    }

    proc check_and_exit {} {
	global south east west north
	set saved 0 
	set headermessage "iGMT: Changed the region to $west/$east/$north/$south."
	ret .er 
    } 
}

################################################################################
# dialog for selection of pscoast features
################################################################################

proc pscoast_features {} {
    global river boundary resolution shoreline 
    
    toplevel .pf -class Dialog
    wm title .pf "pscoast features" 
    wm iconname .pf Dialog

    frame .pf.up

    # rivers
    
    frame .pf.up.l
    label .pf.up.l.label -text "Rivers to plot" 
    checkbutton .pf.up.l.r1 -text "Permant major rivers" -relief flat -variable river(1)
    checkbutton .pf.up.l.r2 -text "Additional major rivers" -relief flat -variable river(2)
    checkbutton .pf.up.l.r3 -text "Additional rivers" -relief flat -variable river(3)
    checkbutton .pf.up.l.r4 -text "Minor rivers" -relief flat -variable river(4)
    pack .pf.up.l.label .pf.up.l.r1 .pf.up.l.r2 .pf.up.l.r3 .pf.up.l.r4 -side top
    pack .pf.up.l

    # boundaries
    
    frame .pf.up.r
    label .pf.up.r.label -text "Boundaries to plot" 
    checkbutton .pf.up.r.b1 -text "International boundaries" -relief flat -variable boundary(1)
    checkbutton .pf.up.r.b2 -text "State boundaries (only US)" -relief flat -variable boundary(2)
    pack .pf.up.r.label .pf.up.r.b1 .pf.up.r.b2 -side top -fill y
    pack .pf.up.r
    pack .pf.up.l .pf.up.r -side left
    pack .pf.up

    # shoreline on/off

    frame .pf.middle
    frame .pf.middle.l
    label .pf.middle.l.label -text "Shoreline"
    checkbutton .pf.middle.l.b1 -text "Draw shoreline" -relief flat -variable shoreline
    label .pf.middle.l.label2 -text "Wet areas"
    checkbutton .pf.middle.l.b2 -text "Draw wet areas" -relief flat -variable river(5)
    pack .pf.middle.l.label .pf.middle.l.b1 .pf.middle.l.label2 .pf.middle.l.b2 -side top
    pack .pf.middle.l 
    

    # resolution selection, high might be slow for large regions

    frame .pf.middle.r
    label .pf.middle.r.label -text "Resolution of shoreline data"
    radiobutton .pf.middle.r.b1 -text "Full" -relief flat -variable resolution -value "f"
    radiobutton .pf.middle.r.b2 -text "High" -relief flat -variable resolution -value "h"
    radiobutton .pf.middle.r.b3 -text "Intermediate" -relief flat -variable resolution -value "i"
    radiobutton .pf.middle.r.b4 -text "Low" -relief flat -variable resolution -value "l"
    radiobutton .pf.middle.r.b5 -text "Crude" -relief flat -variable resolution -value "c"
    radiobutton .pf.middle.r.b6 -text "Crude and suppress features" -relief flat -variable resolution -value "cred"
    pack .pf.middle.r.label  .pf.middle.r.b1 \
	.pf.middle.r.b2 .pf.middle.r.b3 .pf.middle.r.b4 \
	.pf.middle.r.b5 .pf.middle.r.b6 -side top
    pack .pf.middle.r
    

    pack .pf.middle.l .pf.middle.r -side left
    pack .pf.middle

    proc exit_from_here { } {
	global saved
	set saved 0 
	set headermessage "iGMT: Changed pscoast features."
	ret .pf 
    }

    frame .pf.down
    frame .pf.down.l
    pack .pf.down.l
    frame .pf.down.r
    pack .pf.down.r

    pack .pf.down.l .pf.down.r -side left
    pack .pf.down 

    frame .pf.buttons
    button .pf.buttons.button1 -text "OK" -relief groove -command exit_from_here
   
    pack .pf.buttons.button1 
    pack .pf.buttons
    pack .pf.up .pf.middle .pf.down .pf.buttons -side top

    bind .pf <Return> exit_from_here
    set oldFocus [focus]
    grab set .pf
    focus .pf
}

################################################################################
# change the map projection, calculations are done in igmt_plotting.tcl
################################################################################

# using the GMT symbols for identification

proc change_projection {} {
    global proj custom_projection saved gmt_version \
	gmt_version_boundary

    set oldproj $proj(1)
    
    toplevel .pj -class Dialog
    wm title .pj "Changing the map projection" 
    wm iconname .pj Dialog

    frame .pj.up
#
# list of used symbols for projection:
# B, D, M, Q, C, Y, X, A, S, G, E, H, W, N, I, Custom



    if { $gmt_version >= $gmt_version_boundary } {
	#
	# albers conic only works with -Jb in older versions
	# equidistant conic is only introduced later
	    label .pj.up.l1 -text "CONIC PROJECTIONS"	
	    radiobutton .pj.up.b1  -text "Albers Conic Equal-Area (-JB)" -relief flat \
		-variable proj(1) -value "B"
	    radiobutton .pj.up.b11 -text "Equidistant Conic (-JD)" \
		-relief flat -variable proj(1) -value "D"
    }	


    label .pj.up.l2 -text "CYLINDRICAL PROJECTIONS" 

    radiobutton .pj.up.b2  -text "Mercator (-JM)" -relief flat -variable proj(1) -value "M"
    radiobutton .pj.up.b12 -text "Cylindrical Equidistant (-JQ)" \
	-relief flat -variable proj(1) -value "Q"
    radiobutton .pj.up.b14 -text "Cassini Cylindrical (-JC)" \
	-relief flat -variable proj(1) -value "C"
    radiobutton .pj.up.b13 -text "General Cylindrical (-JY)" \
	-relief flat -variable proj(1) -value "Y"
    
    label .pj.up.l3 -text "LINEAR PROJECTIONS" 
    radiobutton .pj.up.b3a -text "Cylindrical Equidistant (-JQ)" \
	-relief flat -variable proj(1) -value "Q"
    radiobutton .pj.up.b3  -text "Linear (-JX)" \
	-relief flat -variable proj(1) -value "X"

    label .pj.up.l4 -text "AZIMUTHAL PROJECTIONS" 

    radiobutton .pj.up.b4 -text "Lambert Azimuthal Equal-Area (-JA)" \
	-relief flat -variable proj(1) -value "A"
    radiobutton .pj.up.b5 -text "Stereographic Equal-Angle (-JS)" \
	-relief flat -variable proj(1) -value "S"
    radiobutton .pj.up.b6 -text "Orthographic (-JG)" \
	-relief flat -variable proj(1) -value "G"
    radiobutton .pj.up.b7 -text "Azimuthal Equidistant (-JE)" \
	-relief flat -variable proj(1) -value "E"

    label .pj.up.l5 -text "MISCELLANEOUS PROJECTIONS"  

    radiobutton .pj.up.b8 -text "Hammer (-JH)" \
	-relief flat -variable proj(1) -value "H"
    radiobutton .pj.up.b9 -text "Mollweide (-JW)" \
	-relief flat -variable proj(1) -value "W"
    radiobutton .pj.up.b9a -text "Robinson (-JN)" \
	-relief flat -variable proj(1) -value "N"
    radiobutton .pj.up.b9b -text "Sinusdoidal (-JI)" \
	-relief flat -variable proj(1) -value "I"
    radiobutton .pj.up.b10 -text "Custom projection..." \
	-relief flat -variable proj(1) -value "Custom"
    entry .pj.up.entry -textvariable custom_projection
    if { $gmt_version >= $gmt_version_boundary } {
	    pack .pj.up.l1 .pj.up.b1 .pj.up.b11 .pj.up.l2 .pj.up.b2  .pj.up.b12 .pj.up.b14 \
		.pj.up.b13 .pj.up.l3 .pj.up.b3a .pj.up.b3 \
		.pj.up.l4  .pj.up.b4 .pj.up.b5 .pj.up.b6 .pj.up.b7 .pj.up.l5 .pj.up.b8 \
		.pj.up.b9 .pj.up.b9a .pj.up.b9b .pj.up.b10 .pj.up.entry -side top
    } else {
	    pack  .pj.up.l2 .pj.up.b2  .pj.up.b12 .pj.up.b14 \
		.pj.up.b13 .pj.up.l3 .pj.up.b3a .pj.up.b3 \
		.pj.up.l4  .pj.up.b4 .pj.up.b5 .pj.up.b6 .pj.up.b7 .pj.up.l5 .pj.up.b8 \
		.pj.up.b9 .pj.up.b9a .pj.up.b9b .pj.up.b10 .pj.up.entry -side top
    }
    pack .pj.up

    frame .pj.down
	
    button .pj.down.button1 -text "OK" -relief groove -command { set saved 0 ;\
	set headermessage "iGMT: Changed map projection."; ret .pj }
    pack .pj.down.button1  -side left
    pack .pj.down

    pack .pj.up .pj.down -side top
    set oldFocus [focus]
    grab set .pj
    focus .pj
    bind .pj <Return> {set saved 0 ; set headermessage "iGMT: Changed map projection.";ret .pj }

}

################################################################################
# change the resolution of the raster data set
# supported for ETOPO5 and GTOPO30 data sets so far
################################################################################


proc change_raster_resolution { rres rb raster_dataset masterwindow } {
    upvar $rres raster_resolution 
    upvar $rb raster_bounds

    set oldraster_resolution $raster_resolution
    # warn if the resulting resolution appears to be high

    proc check_res { } {
	global north east west south raster_resolution \
	    raster_bounds raster_dataset
	set span(1) [ expr abs($east - $west) ]
	set span(2) [ expr abs($north- $south)]
	set dx [ expr $raster_resolution/60.0 ] 
	set n [ expr int($span(1)/$dx) ]
	set n [ expr int($span(2)/$dx) * $n ]
	if { $n > 80000 } { dialog .d {Resolution warning} \
				"You are now attempting to plot about $n datapoints!"  warning 0 {OK} }
	if { $raster_resolution < $raster_bounds($raster_dataset,6) } {
	    set raster_resolution $raster_bounds($raster_dataset,6) 
	    dialog .d {Resolution adjustment warning} \
		"Changed the resolution to the maximum for this dataset, which is $raster_resolution arc minutes."  warning 0 {OK}
	}
    }
    proc exit_from_here {} {
	global saved
	check_res ; set saved 0 ; ret .cr 
    }

    toplevel .cr -class Dialog
    wm title .cr "Changing the raster data resolution" 
    wm iconname .cr Dialog

    frame .cr.up
    label .cr.up.l1 -text "Change the resolution of the raster dataset,\nselected dataset (R $raster_dataset) is limited to $raster_bounds($raster_dataset,6) min."

    frame .cr.up.w
    label .cr.up.w.l -text "Give value in arc minutes:"
    entry .cr.up.w.entry -textvariable raster_resolution
    pack .cr.up.w.l .cr.up.w.entry -side left
    pack .cr.up.w
    pack .cr.up.l1  .cr.up.w -side top
    pack .cr.up

    frame .cr.buttons
    button .cr.buttons.button1 -text "OK" -relief groove -command  exit_from_here
    button .cr.buttons.button2 -text "Cancel" -relief groove \
	-command  " [ list set raster_resolution $oldraster_resolution ] ; ret .cr"
    pack .cr.buttons.button1 .cr.buttons.button2 -side left
    pack .cr.buttons

    pack .cr.up .cr.buttons 
    bind .cr <Return> exit_from_here

    set oldFocus [focus]
    grab set .cr
    focus .cr
}



################################################################################
# the next two routines do nearly the same and could be realized by a 
# single reusable dialog
#


################################################################################
# this is intended as a possibility to add additional features to the pscaost line
# such as other rivers etc.

proc enter_pscoast_line { master } {
    global pscoast_add global
    toplevel .epl -class Dialog
    wm title .epl "Add to the pscoast line"
    wm iconname .epl Dialog
    set oldvar $pscoast_add

    frame .epl.up   -height 10
    entry .epl.up.entry -width 50 -textvariable pscoast_add 
    pack .epl.up.entry -fill x
    pack .epl.up
    frame .epl.buttons

    button .epl.buttons.button1 -relief groove \
	-text "OK" -command  " set saved 0;  ret .epl  "
    button .epl.buttons.button2 -relief groove \
	-text "Cancel" -command   " [ list set pscoast_add $oldvar] ;   ret .epl  "
    pack .epl.buttons.button1 .epl.buttons.button2 -side left
    pack .epl.buttons
    pack .epl.up .epl.buttons -side top
    set oldFocus [focus]
    grab set .epl
    focus .epl
    bind .epl <Return>  [list ret .epl ]
}

################################################################################
# procedure to enter a title for the plot

proc enter_title_line { master } {
    global plot_title saved
    toplevel .etl -class Dialog
    wm title .etl "Enter a plot title"
    wm iconname .etl Dialog
    set oldvar $plot_title

    frame .etl.up   -height 10
    entry .etl.up.entry -width 50 -textvariable plot_title 
    pack .etl.up.entry -fill x
    pack .etl.up
    frame .etl.buttons

    button .etl.buttons.button1 -text "OK" -relief groove \
	-command  " set saved 0;  ret .etl  "
    button .etl.buttons.button2 -text "Cancel" -relief groove \
	-command   " [ list set plot_title $oldvar] ;   ret .etl  "
    pack .etl.buttons.button1 .etl.buttons.button2 -side left
    pack .etl.buttons
    pack .etl.up .etl.buttons -side top
    set oldFocus [focus]
    grab set .etl
    focus .etl
    bind .etl <Return>  [list ret .etl ]
}


################################################################################
# papersize (i.e. plot size) selection dialog
################################################################################


proc enter_papersize { master } {
    global papersize portrait saved
    toplevel .eps -class Dialog
    wm title .eps "Enter the page size"
    wm iconname .eps Dialog
    set oldvar(1) $papersize(1)
    set oldvar(2) $papersize(2)

    frame .eps.upper
    label .eps.upper.l -text "Enter the page size (portrait orientation) in inches."
    pack .eps.upper.l
    pack .eps.upper


    frame .eps.up   -height 10
    label .eps.up.l1 -text "Pagesize in x direction"
    entry .eps.up.entry1 -width 5 -textvariable papersize(1)
    pack .eps.up.l1 .eps.up.entry1 -side left
    
    label .eps.up.l2 -text "Pagesize in y direction"
    entry .eps.up.entry2 -width 5 -textvariable papersize(2)
    pack .eps.up.l2 .eps.up.entry2 -side left

    pack .eps.up 


    frame .eps.buttons
    button .eps.buttons.button1 -text "OK" -relief groove \
	-command { set saved 0 ; check_size }
    button .eps.buttons.button2 -text "Cancel" -relief groove -command  \
	" [ list set papersize(1) $oldvar(1) ] ; [ list set papersize(2) $oldvar(2) ] ; check_size "
    pack .eps.buttons.button1 .eps.buttons.button2 -side left
    pack .eps.buttons
    pack .eps.upper .eps.up .eps.buttons -side top
    set oldFocus [focus]
    grab set .eps
    focus .eps
    bind .eps <Return>  {check_size}

    # consider a page size larger than 20 inches dangereous

    proc check_size {} {
	global papersize
	if { $papersize(1) > 20 } { 
	    dialog .d {Papersize warning} "[ list The paper size in x direction is now $papersize(1) inches. ]"  warning 0 {OK} }
	if { $papersize(2) > 20 } { 
	    dialog .d {Papersize warning} "[ list The paper size in y direction is now $papersize(2) inches. ]"  warning 0 {OK} }
	ret .eps
    }

}



################################################################################
#
# GPS velocity vector info (i.e. vector look and feel)
#
# originally contribution of Simon McClusky of MIT
#
################################################################################


proc enter_vellook { master } {
    global poly_parameter saved
    toplevel .vps -class Dialog
    wm title .vps "Enter the GPS velocity vector parameters"
    wm iconname .vps Dialog
    foreach i { 1 2 3 4 5 6 } {
	set oldvar($i) $poly_parameter(10,$i)
    }
    frame .vps.upper
    label .vps.upper.l \
	-text "Enter GPS velocity vector parameters."
    pack .vps.upper.l
    pack .vps.upper

    frame .vps.up 

    frame .vps.up.l1   -height 10
    label .vps.up.l1.1 -text "Velocity vector scaling"
    entry .vps.up.l1.entry1 -width 5 -textvariable poly_parameter(10,1)
    pack .vps.up.l1.1 .vps.up.l1.entry1 -side left
    pack .vps.up.l1
    
    frame .vps.up.l2   -height 10
    label .vps.up.l2.2 -text "Velocity uncertainty scaling"
    entry .vps.up.l2.entry2 -width 5 -textvariable poly_parameter(10,2)
    pack .vps.up.l2.2 .vps.up.l2.entry2 -side left
    pack .vps.up.l2

    frame .vps.up.l3   -height 10
    label .vps.up.l3.3 -text "Error ellipse confidence interval"
    entry .vps.up.l3.entry3 -width 5 -textvariable poly_parameter(10,3)
    pack .vps.up.l3.3 .vps.up.l3.entry3  -side left
    pack .vps.up.l3

    frame .vps.up.l4   -height 10
    label .vps.up.l4.4 -text "Max sigma plotted (mm)"
    entry .vps.up.l4.entry4 -width 5 -textvariable poly_parameter(10,5)
    pack .vps.up.l4.4 .vps.up.l4.entry4  -side left
    pack .vps.up.l4

    frame .vps.up.l5   -height 10
    label .vps.up.l5.5 -text "Site name font size"
    entry .vps.up.l5.entry5 -width 5 -textvariable poly_parameter(10,4)
    pack .vps.up.l5.5 .vps.up.l5.entry5  -side left
    pack .vps.up.l5

    frame .vps.up.l6   -height 10
    label .vps.up.l6.6 -text "Scale vector size (mm)"
    entry .vps.up.l6.entry6 -width 5 -textvariable poly_parameter(10,6)
    pack .vps.up.l6.6 .vps.up.l6.entry6  -side left
    pack .vps.up.l6

    pack .vps.up.l1 .vps.up.l2 .vps.up.l3 .vps.up.l4 .vps.up.l5 .vps.up.l6 -side top
    pack .vps.up -side top 


    frame .vps.buttons
    button .vps.buttons.button1 -text "OK" -relief groove \
	-command { set saved 0 ; ;  ret .vps  }
    button .vps.buttons.button2 -text "Cancel" -relief groove \
	-command  \
	"foreach i { 1 2 3 4 5 6 } { set poly_parameter(10,$i) $oldvar($i) } ; ret .vps "
    pack .vps.buttons.button1 .vps.buttons.button2 -side left
    pack .vps.buttons
    pack .vps.upper .vps.up .vps.buttons -side top
    set oldFocus [focus]
    grab set .vps
    focus .vps
    bind .vps <Return>  [list ret .vps ]
}


################################################################################
#
#  velocity field parameters 
#
################################################################################


proc enter_velfield { master } {
    global poly_parameter saved
    toplevel .vfield -class Dialog
    wm title .vfield "Enter the vector field parameters"
    wm iconname .vfield Dialog
    foreach i { 1 2 3 4 5 6 } {
	set oldvar($i) $poly_parameter(19,$i)
    }
    frame .vfield.upper
    label .vfield.upper.l \
	-text "Enter vector field parameters."
    pack .vfield.upper.l
    pack .vfield.upper

    frame .vfield.up 

    frame .vfield.up.l1   -height 10
    label .vfield.up.l1.1 -text "Field scaling in data units/inch"
    entry .vfield.up.l1.entry1 -width 5 -textvariable poly_parameter(19,1)
    pack .vfield.up.l1.1 .vfield.up.l1.entry1 -side left
    pack .vfield.up.l1
    
    
    frame .vfield.up.l2   -height 10
    label .vfield.up.l2.2 -text "Reference vector length in data units"
    entry .vfield.up.l2.entry2 -width 5 -textvariable poly_parameter(19,2)
    pack .vfield.up.l2.2 .vfield.up.l2.entry2 -side left
    pack .vfield.up.l2

    frame .vfield.up.l3   -height 10
    label .vfield.up.l3.3 -text "Units for reference scale"
    entry .vfield.up.l3.entry3 -width 5 -textvariable poly_parameter(19,3)
    pack .vfield.up.l3.3 .vfield.up.l3.entry3  -side left
    pack .vfield.up.l3

    frame .vfield.up.l4   -height 10
    label .vfield.up.l4.1 -text "Vector spacing in degrees"
    entry .vfield.up.l4.entry1 -width 5 -textvariable poly_parameter(19,4)
    pack .vfield.up.l4.1 .vfield.up.l4.entry1 -side left
    pack .vfield.up.l4

    frame .vfield.up.l5   -height 10
    frame .vfield.up.l5.1
    label .vfield.up.l5.1.1 -text "Reference vector display"
    pack .vfield.up.l5.1.1
    pack .vfield.up.l5.1

    frame .vfield.up.l5.2
    radiobutton  .vfield.up.l5.2.1 -text "On" -relief flat -variable poly_parameter(19,5) -value 1
    radiobutton  .vfield.up.l5.2.2 -text "Off" -relief flat -variable poly_parameter(19,5) -value 0
    pack .vfield.up.l5.2.1 .vfield.up.l5.2.2 -side left
    pack .vfield.up.l5.2
    pack  .vfield.up.l5.1 .vfield.up.l5.2 -side top
    pack .vfield.up.l5
    
    pack .vfield.up.l1 .vfield.up.l4 .vfield.up.l2 .vfield.up.l3 .vfield.up.l5 \
	-side top
    pack .vfield.up -side top 


    frame .vfield.buttons
    button .vfield.buttons.button1 -text "OK" -relief groove \
	-command { set saved 0  ;  ret .vfield  }
    button .vfield.buttons.button2 -text "Cancel" -relief groove \
	-command  \
	"foreach i { 1 2 3 4 5 6 } { set poly_parameter(19,$i) $oldvar($i) } ; ret .vfield "
    pack .vfield.buttons.button1 .vfield.buttons.button2 -side left
    pack .vfield.buttons

    pack .vfield.upper .vfield.up .vfield.buttons -side top
    set oldFocus [focus]
    grab set .vfield
    focus .vfield
    bind .vfield <Return>  [list ret .vfield ]
}

################################################################################
#
# WSM parameters for plotting stress directions
#
################################################################################


proc enter_wsmspecs { master } {
    global poly_color poly_data poly_parameter
    
    toplevel .wsmspecs -class Dialog
    wm title .wsmspecs "Enter WSM parameters..."
    wm iconname .wsmspecs Dialog
    foreach i { 1 2 3 4 5 6 7 8 9 10 } {
	set oldvar($i) $poly_parameter(15,$i)
    }

    frame .wsmspecs.upper
    label .wsmspecs.upper.l -text "Classes to plot: all better or equal than:"
    pack .wsmspecs.upper.l
    pack .wsmspecs.upper
    frame .wsmspecs.lower
    radiobutton .wsmspecs.lower.1 -text "A" -relief flat -variable poly_parameter(15,6) -value 1
    radiobutton .wsmspecs.lower.2 -text "B" -relief flat -variable poly_parameter(15,6) -value 2
    radiobutton .wsmspecs.lower.3 -text "C" -relief flat -variable poly_parameter(15,6) -value 3
    radiobutton .wsmspecs.lower.4 -text "D" -relief flat -variable poly_parameter(15,6) -value 4
    pack .wsmspecs.lower.1 .wsmspecs.lower.2 .wsmspecs.lower.3 .wsmspecs.lower.4 -side left
    pack .wsmspecs.lower

    frame .wsmspecs.upper3
    label .wsmspecs.upper3.l -text "Type of data to plot:"
    pack .wsmspecs.upper3.l
    pack .wsmspecs.upper3
    frame .wsmspecs.lower3
    checkbutton .wsmspecs.lower3.1 -text "CMT" -relief flat -variable  poly_parameter(15,1) 
    checkbutton .wsmspecs.lower3.2 -text "borehole\nbreakout" -relief flat -variable poly_parameter(15,2)
    checkbutton .wsmspecs.lower3.3 -text "hydro frac" -relief flat -variable poly_parameter(15,3) 
    checkbutton .wsmspecs.lower3.4 -text "over-coring" -relief flat -variable poly_parameter(15,4) 
    checkbutton .wsmspecs.lower3.5 -text "geological\nindicators" -relief flat -variable poly_parameter(15,5)
    pack .wsmspecs.lower3.1 .wsmspecs.lower3.2 .wsmspecs.lower3.3 \
	.wsmspecs.lower3.4 .wsmspecs.lower3.5 -side left
    pack .wsmspecs.lower3

    frame .wsmspecs.upper2
    label .wsmspecs.upper2.l -text "Vector style"
    pack .wsmspecs.upper2.l
    pack .wsmspecs.upper2
    frame .wsmspecs.lower2
    radiobutton .wsmspecs.lower2.1 -text "different\narrowheads" -relief flat -variable poly_parameter(15,7) -value 1
    radiobutton .wsmspecs.lower2.2 -text "only compressional\naxis" -relief flat -variable poly_parameter(15,7) -value 2
    pack .wsmspecs.lower2.1 .wsmspecs.lower2.2 -side left
    pack .wsmspecs.lower2

    frame .wsmspecs.buttons
    button .wsmspecs.buttons.button1 -text "OK" -relief groove \
	-command { set saved 0 ;   ret .wsmspecs  }
    button .wsmspecs.buttons.button2 -relief groove -text "Cancel" -command  \
	"foreach i { 1 2 3 4 5 6 7 8 9 10 } { set poly_parameter(15,$i) $oldvar($i) } ; [ list ret .wsmspecs ]"
    pack .wsmspecs.buttons.button1 .wsmspecs.buttons.button2 -side left
    pack .wsmspecs.buttons
    
    pack .wsmspecs.upper   .wsmspecs.lower \
	.wsmspecs.upper2 .wsmspecs.lower2 \
	.wsmspecs.lower3 \
	.wsmspecs.buttons -side top
    set oldFocus [focus]
    grab set .wsmspecs
    focus .wsmspecs
    bind .wsmspecs <Return>  [list ret .wsmspecs ]
}


################################################################################
# postscript page offsets -X and -Y
################################################################################


proc enter_offsets { master } {
    global saved ps_offset
    toplevel .epso -class Dialog
    wm title .epso "Enter the PS offsets"
    wm iconname .epso Dialog
    set oldvar(1) $ps_offset(1)
    set oldvar(2) $ps_offset(2)

    frame .epso.upper
    label .epso.upper.l -text "Enter the X and Y offsets for the PS file  in inches."
    pack .epso.upper.l
    pack .epso.upper


    frame .epso.up   -height 10
    label .epso.up.l1 -text "Offset in X direction"
    entry .epso.up.entry1 -width 5 -textvariable ps_offset(1)
    pack .epso.up.l1 .epso.up.entry1 -side left
    
    label .epso.up.l2 -text "Offset in Y direction"
    entry .epso.up.entry2 -width 5 -textvariable ps_offset(2)
    pack .epso.up.l2 .epso.up.entry2 -side left

    pack .epso.up 


    frame .epso.buttons
    button .epso.buttons.button1 -relief groove \
	-text "OK" -command { set saved 0 ; ret .epso }
    button .epso.buttons.button2 -relief groove \
	-text "Cancel" -command  \
	" [ list set ps_offset(1) $oldvar(1) ] ; [ list set ps_offset(2) $oldvar(2) ] ; ret .epso "
    pack .epso.buttons.button1 .epso.buttons.button2 -side left
    pack .epso.buttons
    pack .epso.upper .epso.up .epso.buttons -side top
    set oldFocus [focus]
    grab set .epso
    focus .epso
    bind .epso <Return>  {set saved 0; ret .epso}


}


#################################################################################
# reusable dialog for changing the parameters of the custom xys dataset number 
################################################################################

# TO DO: using a global array tmp_array is not nice


proc set_custom_xys_parameters  { nr master } {
    global poly_parameter saved polygon_dataset

    foreach i { 1 2 3 4 5 } {
	set oldvar($i) $poly_parameter($nr,$i)
    }

    toplevel .scxp_$nr -class Dialog
    wm title .scxp_$nr "Custom xys, polygon data code $nr"
    wm iconname .scxp_$nr Dialog

    frame .scxp_$nr.upper
    if { $polygon_dataset($nr) == 1 } {
	label .scxp_$nr.upper.l -text "Enter the parameters for reading custom file (On)"
    } else {
	label .scxp_$nr.upper.l -text "Enter the parameters for reading custom file (Off)"
    }
    pack .scxp_$nr.upper.l
    pack .scxp_$nr.upper

    # now tmp_array(n) corresponds to custom$nr(n)

    frame .scxp_$nr.upp

    frame .scxp_$nr.upp.r
    label .scxp_$nr.upp.r.l1 -text "Name of the ASCII column data file"
    entry .scxp_$nr.upp.r.e -width 50 -textvariable  poly_parameter($nr,5) 
    pack .scxp_$nr.upp.r.l1 .scxp_$nr.upp.r.e -side top
    pack .scxp_$nr.upp.r

    frame .scxp_$nr.upp.l
    button .scxp_$nr.upp.l.b -text "Browse" -relief groove \
	-command "[list   change_filename poly_parameter($nr,5) "Choose the data file"  $master ]"
    pack .scxp_$nr.upp.l.b
    pack .scxp_$nr.upp.l
    
    pack .scxp_$nr.upp.l .scxp_$nr.upp.r -side left
    
    pack .scxp_$nr.upp
    
    frame .scxp_$nr.up   -height 10
    label .scxp_$nr.up.l1 -text "Column with longitudes (x)"
    entry .scxp_$nr.up.entry1 -width 5 -textvariable poly_parameter($nr,1)
    
    label .scxp_$nr.up.l2 -text "Column with latitudes (y)"
    entry .scxp_$nr.up.entry2 -width 5 -textvariable poly_parameter($nr,2)

    label .scxp_$nr.up.l3 -text "Column with sizes (blank for xy-plot)"
    entry .scxp_$nr.up.entry3 -width 5 -textvariable poly_parameter($nr,3)

    label .scxp_$nr.up.l4 -text "Size mag. factor"
    entry .scxp_$nr.up.entry4 -width 5 -textvariable poly_parameter($nr,4)

    pack .scxp_$nr.up.l1 .scxp_$nr.up.entry1 .scxp_$nr.up.l2 .scxp_$nr.up.entry2 \
	.scxp_$nr.up.l3 .scxp_$nr.up.entry3 .scxp_$nr.up.l4 .scxp_$nr.up.entry4 -side top
    
    pack .scxp_$nr.up 
    
    frame .scxp_$nr.buttons
    button .scxp_$nr.buttons.button1 -relief groove \
	-text "OK" -command "set saved 0 ; [ list ret .scxp_$nr ]"
    button .scxp_$nr.buttons.button2 -relief groove \
	-text "Cancel" -command "foreach i { 1 2 3 4 5 } { set poly_parameter($nr,$i) $oldvar($i) } ;[ list ret .scxp_$nr ]"
    pack .scxp_$nr.buttons.button1 .scxp_$nr.buttons.button2  -side left
    pack .scxp_$nr.buttons
    pack .scxp_$nr.upper .scxp_$nr.upp .scxp_$nr.up .scxp_$nr.buttons -side top

    set oldFocus [focus]
    grab set .scxp_$nr
    focus .scxp_$nr
    bind .scxp_$nr <Return>  "set saved 0 ; [ list ret .scxp_$nr ]"
}


    

################################################################################
# change an input file
################################################################################

proc change_filename { var titleline masterwindow } {

    upvar $var fntc
    
    set initialfilename $fntc
    set fn [tk_getOpenFile  -initialfile $initialfilename    -parent $masterwindow \
		-title $titleline ]

    if { $fn != "" } {
	set headermessage "iGMT: Changed $fntc from $initialfilename to $fn"
	update idletasks
	set fntc $fn
    }
    return
}




################################################################################
# set the polygon data symbol size in times of the map width
################################################################################
    
proc set_symbol_size { nr titletext master } {
    global saved poly_symbol_size
    toplevel .sss -class Dialog
    wm title .sss $titletext
    wm iconname .sss Dialog
    set oldvar $poly_symbol_size($nr)
    frame .sss.upper
    label .sss.upper.l1 -text "Enter the symbol size as a fraction of the map width"
    label .sss.upper.l2 -text "(if lines are used, 0.05 translates to linewidth 1):"
    
    pack .sss.upper.l1 .sss.upper.l2
    pack .sss.upper


    frame .sss.up   -height 10
    entry .sss.up.entry1 -width 10 -textvariable poly_symbol_size($nr)
    pack .sss.up.entry1 
    pack .sss.up 


    frame .sss.buttons
    button .sss.buttons.button1 -relief groove \
	-text "OK" -command "set saved 0 ; ret .sss"
    button .sss.buttons.button2 -relief groove \
	-text "Cancel" -command  "[list set poly_symbol_size($nr) $oldvar]; ret .sss"
    pack .sss.buttons.button1 .sss.buttons.button2 -side left
    pack .sss.buttons
    pack .sss.upper .sss.up .sss.buttons -side top
    set oldFocus [focus]
    grab set .sss
    focus .sss
    bind .sss <Return>  "set saved 0 ;  ret .sss"

}
