
################################################################################
# igmt_datasetss.tcl -- dialogs used to select raster and polygone data sets
#
# also holds the raster data set specific settings that are use by igmt_plotting.tcl
#
#
# part of the iGMT package
#
# $Id: igmt_datasets.tcl,v 1.11 2002-11-06 10:10:34-08 tbecker Exp $
#
################################################################################


proc choose_raster_datasets { masterwindow } {
    global raster_dataset agedata  custom_raster_data\
	gridfile freeair_grav_data geoid_data\
	seddata freeair_grav_data_2
    

    toplevel .crd -class Dialog
    wm title .crd "Selection of raster data sets" 
    wm iconname .crd Dialog

    frame .crd.up 
    
################################################################################
# list the choices for the raster sets here

    radiobutton .crd.up.r1 -text "Land and Sea Coverage\nShorelines by GMT's pscoast" \
	-relief flat -variable raster_dataset -value 1  
    radiobutton .crd.up.r2 -text "Topography and Bathymetry\nETOPO5" -relief flat \
	-variable raster_dataset -value 2  
    radiobutton .crd.up.r12 -text "Topography and Bathymetry\nETOPO1" -relief flat \
	-variable raster_dataset -value 12  
    radiobutton .crd.up.r3 -text "Topography and Bathymetry\nGTOPO30 (Smith & Sandwell 1997)" \
	-relief flat -variable raster_dataset -value 3  
    radiobutton .crd.up.r4 -text "Seafloor Age and Pscoast Land Coverage\n(Mueller et al, 1997)"  \
	-relief flat -variable raster_dataset -value 4 
    radiobutton .crd.up.r5 -text "Free-air Gravity on Sea & Pscoast Land Coverage\n(Smith & Sandwell, 1997)"\
	-relief flat -variable raster_dataset -value 5 
    radiobutton .crd.up.r6 -text "Geoid\n(EGM360 of Rapp et al., 1997, corrected)"\
	-relief flat -variable raster_dataset -value 6
    radiobutton .crd.up.r9 -text "Gravity\n(EGM360 of Rapp et al., 1997, corrected)"\
	-relief flat -variable raster_dataset -value 9
    radiobutton .crd.up.r8 -text "Sediment Thickness & Pscoast Land Coverage\n(Laske & Masters, 1997)"  \
        -relief flat -variable raster_dataset -value 8
    radiobutton .crd.up.r10 -text "GSHAP peak ground acceleration\n(Giardini et al., 2000)"\
	-relief flat -variable raster_dataset -value 10
 

    radiobutton .crd.up.r7 -text "Custom Raster Data Set"\
	-relief flat -variable raster_dataset -value 7

    # pack the stuff

    pack  .crd.up.r1 .crd.up.r2 .crd.up.r12 .crd.up.r3 \
	.crd.up.r4 .crd.up.r5  .crd.up.r9 .crd.up.r6 \
	.crd.up.r8  .crd.up.r10 .crd.up.r7 -side top
    pack .crd.up
    frame .crd.buttons
    button .crd.buttons.button1 -text "OK" -relief groove -command exit_from_here 
    pack .crd.buttons.button1 
    pack .crd.buttons
    pack .crd.up .crd.buttons -side top
    set oldFocus [focus]
    grab set .crd
    focus .crd   

    # exit and choose the new colormap corresponding to the raster 
    # data sets defaults

    proc exit_from_here {} {
	global saved raster_colormap colormap  \
	    raster_dataset raster_resolution
	set saved 0 
	set colormap $raster_colormap($raster_dataset)
	set headermessage "iGMT: Changed raster data sets and default colormap."
	ret .crd 
    }
    bind .crd <Return> exit_from_here
}

proc choose_polygon_datasets { masterwindow } {
    global polygon_dataset shoreline
    toplevel .cpd -class Dialog
    wm title .cpd "Polygon data selection" 
    wm iconname .cpd Dialog
    frame .cpd.up 
    
    label .cpd.up.label -text "Polygon data selection" 

    ################################################################################
    # list the choices for the polygon data sets here

    label .cpd.up.l1 -text "Contours:"
    checkbutton  .cpd.up.r12 -text "Shorelines" \
	-relief flat -variable shoreline
    checkbutton .cpd.up.r1 -text "Plate boundaries (NUVEL)" \
	-relief flat -variable polygon_dataset(1) 
    checkbutton .cpd.up.r9 -text "Slab contours" \
	-relief flat -variable polygon_dataset(9) 

    label .cpd.up.l2 -text "Point data:"
    checkbutton .cpd.up.r11 -text "Cities" \
	-relief flat -variable polygon_dataset(12) 
    checkbutton .cpd.up.r8 -text "Volcano locations"\
	-relief flat -variable polygon_dataset(8) 
    checkbutton .cpd.up.r7 -text "Hotspot locations"\
	-relief flat -variable polygon_dataset(7) 
    checkbutton .cpd.up.r10 -text "GPS velocity vectors" \
	-relief flat -variable polygon_dataset(10) 
    checkbutton .cpd.up.r14 -text "Vector field" \
	-relief flat -variable polygon_dataset(19) 
    checkbutton .cpd.up.r6 -text "CMT fault plane solutions" \
	-relief flat -variable polygon_dataset(6)
    checkbutton .cpd.up.r2 -text "Significant quakes (NGDC)" \
	-relief flat -variable polygon_dataset(2) 
    checkbutton .cpd.up.r3 -text "USGS/NEIC PDE quakes" \
	-relief flat -variable polygon_dataset(3) 
    checkbutton .cpd.up.r13 -text "WSM data" \
	-relief flat -variable polygon_dataset(15) 
    label .cpd.up.l6 -text "Custom data"
    checkbutton .cpd.up.r4 -text "Custom x y data 1"\
	-relief flat -variable polygon_dataset(4)
    checkbutton .cpd.up.r5 -text "Custom x y data 2"\
	-relief flat -variable polygon_dataset(5)

    # pack the stuff

    pack .cpd.up.label  \
	.cpd.up.l1 .cpd.up.r12 .cpd.up.r1 .cpd.up.r9 \
	.cpd.up.l2 .cpd.up.r11  .cpd.up.r8 .cpd.up.r7   \
	.cpd.up.r10  .cpd.up.r14 .cpd.up.r6 .cpd.up.r2 .cpd.up.r3 .cpd.up.r13 \
	.cpd.up.l6 .cpd.up.r4 .cpd.up.r5 -side top
    pack .cpd.up
    frame .cpd.buttons
    button .cpd.buttons.button1 -relief groove -text "OK" -command {set saved 0 ;\
       set headermessage "iGMT: Changed polygon data sets."; ret .cpd }
    pack .cpd.buttons.button1 
    pack .cpd.buttons
    pack .cpd.up .cpd.buttons -side top
    set oldFocus [focus]
    grab set .cpd
    focus .cpd   

    bind .cpd <Return> {set saved 0 ;\
       set headermessage "iGMT: Changed polygon data sets."; ret .cpd } 
}


################################################################################
#
# check for the data specific regions and increments
#
################################################################################
proc obtain_raster_data_specs { dr space res raster_data \
				    raster_resolution \
				    sp \
				    raster_b \
				    west east south north } {
    # limited data region
    upvar $dr data_region
    # max increment of raster data 
    upvar $space inc
    # resample this kind of data?
    upvar $res resample 
    # span of region
    upvar $sp span
    # raster data set bounds 
    upvar $raster_b raster_bounds
    # by default, resample grd files
    set resample 1
    # and use the user specified resolution
    set inc [ format -I%sm $raster_resolution ]
    # and make raster file region the plotting region
    set data_region [ format -R%g/%g/%g/%g $west $east $south $west ]
    # we might modify any or all of this further down
    switch $raster_data {
	"1" { 
	    set resample 1
	}
	"2" { 
	    # ETOPO5 
	    # check resolution for resampling
	    set raster_resolution [ check_maximum_resolution $raster_bounds($raster_data,6) $raster_resolution ]
	    
	    set inc [ grdraster_adjust $raster_resolution $raster_bounds($raster_data,6) "ETOPO5"  \
			  $west $east $south $north ]
	    set data_region [ check_max_data_region $west $east $south $north \
				  $raster_bounds($raster_data,1) $raster_bounds($raster_data,2)  \
				  $raster_bounds($raster_data,3) $raster_bounds($raster_data,4)  \
				  $raster_bounds($raster_data,5) ]
	    
	    # all following raster data sets behave in a standard way
	    # R3: GTOPO30
	    # R4: sea-floor age
	    # R5: free air gravity anomalies on sea
	    # R6: geoid data from EGM360 geopotential model
	    # R7: custom data
	    # R8: Laske and Masters (1997) sediment thickness 1 by 1 degree grid
	    # R9: global free-air gravity anomalies from the geopotential model EGM360
	    # R10: ETOPO5 bathymetry and GSHAP peak ground acceleration
	}
	"3" -
	"4" -   
	"5" - 	
	"6" -	
	"7" -   
	"8" - 	 
	"9" -	 
	"10" -
	"12" { 	
	    # standard raster data routine
	    set data_region [ check_max_data_region $west $east $south $north \
				  $raster_bounds($raster_data,1) $raster_bounds($raster_data,2)  \
				  $raster_bounds($raster_data,3) $raster_bounds($raster_data,4)  \
				  $raster_bounds($raster_data,5) ]
	    if { $raster_bounds($raster_data,7) == 0 } { # no resampling
		set resample 0 
		set inc ""
	    } else { # allow for resampling and check for max resolution
		set raster_resolution [ check_maximum_resolution $raster_bounds($raster_data,6) $raster_resolution ]
		set inc [ format -I%sm $raster_resolution ]
	    }
	}
	default {
	    dialog .d {Data region warning} \
		    "Raster data set $raster_data was selected but not found in\nobtain_raster_data_region (igmt_datasets.tcl)\nPlease add the data set's region restrictions to that list.\nFor now, we will assume that the plotting region fits.\n"  warning 0 {OK} 
	    set data_region "[ format -R%g/%g/%g/%g $west $east $south $west ]"
	}
    }
}

proc check_maximum_resolution { maximum raster_resolution } {
    if { $raster_resolution < $maximum } {
	set raster_resolution $maximum
	dialog .d {Resolution adjustment warning} \
	    "Changed the resolution to the maximum for this dataset, which is $raster_resolution arc minutes."  warning 0 {OK}
    }
    return $raster_resolution
}
################################################################################
# procedure to adjust the grimage data region to possible data set limitations
# (but not pscoast etc., they stay at the user limits as given by $reg)

proc check_max_data_region { west east south north \
				 west_lim east_lim \
				 south_lim north_lim \
				 onlyinteger_boundary  } {
    if { $south < $south_lim } { 
	dialog .d {Data set limit warning} \
	    "Changed the southern boundary of the data to its limit, $south_lim degrees south."  warning 0 {OK}
	set south $south_lim 
    } 
    if { $north > $north_lim } { 
	dialog .d {Data set limit warning} \
		"Changed the northern boundary of the data to its limit, $north_lim degress north."  warning 0 {OK}
	set north $north_lim 
    }
    #
    # adjustr for different global settings
    #
    if { (($west == 0) && ($east==360)) && ($west_lim==-180) && ($east_lim==180) } {
	set west -180
	set east 180
    } elseif { (($west == -180) && ($east==180)) && ($west_lim==0) && ($east_lim==360) } {
	set west 0
	set east 360
    } else {
	if { $west < $west_lim } { 
#	    dialog .d {Data set limit warning} "Changed the western boundary of the data to its limit, $west_lim degrees west."  warning 0 {OK}
	    set west [ expr 360 - $west]
	    set east [ expr 360 - $east]
	} 
	if { $east > $east_lim } { 
#	    dialog .d {Data set limit warning} "Changed the eastern boundary of the data to its limit, $east_lim degrees east."  warning 0 {OK}
	    set west [ expr - (360 - $west) ]
	    set east [ expr - (360 - $east) ]

	}
    }

    if { $onlyinteger_boundary == 1 } {
	return "-R[ format %i/%i/%i/%i [ expr int(floor($west))] [ expr int(ceil($east))] [ expr int(floor($south))] [ expr int(ceil($north))]]"
    } else {
	return "-R$west/$east/$south/$north"
    }
}   

proc grdraster_adjust { raster_resolution min_resolution name w e s n } {
    set w [ expr int(floor($w)) ] 
    set e [ expr int(ceil($e)) ]
    set s [ expr int(floor($s)) ] 
    set n [ expr int(ceil($n)) ]
    set span(1) [ expr $e-$w ]
    set span(2) [ expr $n-$s ]
    foreach i { 1 2 } {
	# make inc even multiples of minimum resolution
	set rres($i) [ expr int($raster_resolution+0.5) ]
	if { ($rres($i) % $min_resolution) != 0 } {
	    set n [ expr int($rres($i)/$min_resolution) ]	    
	    if { $n < 1 } { set n 1 } 
	    set rres($i) [ expr $n*$min_resolution ]
	}
	set tmpq [expr $span(1)/($rres($i)/60.0) ]
	while { ([expr int($tmpq) ] != $tmpq) && ($n>=2) } {
	    set n [ expr $n - 1 ]
	    set rres($i) [ expr $n*$min_resolution ]
	    set tmpq [expr $span(1)/($rres($i)/60.0) ]
	} 

	if { $rres($i) != $raster_resolution } {
	    puts "iGMT: changed the $name axis $i resolution to $rres($i)"
	}
    }
    set inc [ format -I%gm/%gm $rres(1) $rres(2) ]
    return $inc
}
