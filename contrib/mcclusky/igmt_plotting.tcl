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
# igmt_plotting.tcl -- routines used for plotting
#
# part of the iGMT package
#
################################################################################


################################################################################
# main procedures for plotting
# produce the GMT script and thus the postscript file
################################################################################

proc mk_ps {} {
    global west east south north proj ps_filename papersize land_color\
	sea_color batchfile portrait ticks  headermessage river_color \
	river boundary resolution shoreline batcherr pscoast_add\
        raster_dataset plot_title shell_to_use retval cmtdata quake3_color\
	gmtbins grid_filename verbose shade_filename topocolor\
	gtopodata agedata agecolor raster_resolution lon0 lat0 freeair_grav_data\
	gravitycolor custom_projection legend title_font_size title_font saved \
	polygon_dataset plate_boundary_data xysize_data plate_color \
   veldata velscale uncscale confint maxsigma sitefont vecscale vector1_color site1_color \
	quake1_color quake2_color gridlines mercatorlimit annotation symbol\
	custom1_color custom1 custom2_color custom2 pol_linewidth psc_linewidth batch_pid colormap \
	quake4_color hotspotdata hotspot_nametag quake5_color volcano_nametag volcanodata \
	custom_raster_data shading geoid_data mapscale symbol_size ps_offset\
	use_pstext_for_title show_gmt_logo slab_contour_data slab_contour_color
    set headermessage "iGMT: Creating postscript file."
    proc add_to_script { nrstr array string } {
	upvar $array ar 
	set ar($nrstr) $string
	incr nrstr
	return $nrstr
    }

 
    
    # define all used GMT commands as variables to allow for the inclusion
    # of pathnames. If new commands are needed, don't forget to include
    # them here. This procedure was chosen to increase the readability of the
    # script when gmt binaries are in the users path
    
    set pscoast       [ format %spscoast     $gmtbins ]
    set grdraster     [ format %sgrdraster   $gmtbins ]
    set grdgradient   [ format %sgrdgradient $gmtbins ]
    set grdimage      [ format %sgrdimage    $gmtbins ]
    set psscale       [ format %spsscale     $gmtbins ]
    set psxy          [ format %spsxy        $gmtbins ]
    set img2latlongrd [ format %simg2latlongrd $gmtbins ]
    set grdcut        [ format %sgrdcut $gmtbins ]
    set pstext        [ format %spstext $gmtbins ] 
    set psvelomeca    [ format %spsvelomeca $gmtbins ]
    set psbasemap     [ format %spsbasemap $gmtbins ]


    # calculate the size of the page and other geometrical stuff
   
    if { $portrait  } { set maxmap $papersize(1)  } else { set maxmap $papersize(2) }
    set span(1) [ expr ($east - $west) ]
    set span(2) [ expr ($north- $south) ]
    set mean(1) [ expr ($east + $west)/2.0 ]
    set mean(2) [ expr ($north + $south)/2.0 ]
    foreach i { 1 2 } { set interval($i) [ expr $span($i)/$ticks($i) ] }
    foreach i { 1 2 } { 
	if { $interval($i) > 0.5 } { set i_format($i) 0
	} elseif { $interval($i) > 0.05 } { set i_format($i) 1 } else { set i_format($i) 2 }
	set i_format($i) "%0[ format 3.%ilf $i_format($i) ]"
	set aspacing($i) [ format $i_format($i) [ expr 2.0 * $interval($i) ]]
	set gspacing($i) [ format %5.3lf  [ expr [ format %lf $aspacing($i)]/2.0 ] ]
    } 
    set mscale 10.0
    if  { $span(1) > 1.0   } { set mscale 40.0   } 
    if  { $span(1) > 2.0   } { set mscale 60.0   } 
    if  { $span(1) > 5.0   } { set mscale 100.0  } 
    if  { $span(1) > 10.0  } { set mscale 200.0  } 
    if  { $span(1) > 20.0  } { set mscale 600.0  } 
    if  { $span(1) > 50.0  } { set mscale 1000.0 } 
    if  { $span(1) > 100.0 } { set mscale 3000.0 } 
    if  { $span(1) > 200.0 } { set mscale 6000.0 } 

    # create the -B string for boundary annotation and grid lines
    

    if { $use_pstext_for_title } { set tmp_plot_title "" } else { set tmp_plot_title $plot_title }
    if { ($gridlines )&&($annotation ) } {
	set frame_box "-Ba$aspacing(1)g$gspacing(1)/a$aspacing(2)g$gspacing(2):.\"$tmp_plot_title\":"
    } elseif { ($gridlines == 0)&&($annotation ) } {
	set frame_box "-Ba$aspacing(1)/a$aspacing(2):.\"$tmp_plot_title\":"
    } elseif { ($gridlines )&&($annotation == 0) } {
	set frame_box "-Bg$gspacing(1)/g$gspacing(2):.\"$tmp_plot_title\":"
    } else { set frame_box "-B:.\"$plot_title\":" }
    set proj(2) [ expr ($span(1)>$span(2))?($maxmap/$span(1)):($maxmap/$span(2)) ]
    
    
    # colors for sea and land in pscoast for pscoast alone
    set sea_c  "-S[ format %03i $sea_color(1)]/[format %03i $sea_color(2)]/[format %03i $sea_color(3)]"
    set land_c "-G[ format %03i $land_color(1)]/[ format %03i $land_color(2)]/[ format %03i $land_color(3)]"

    
    ################################################################################
    # deal with the different projections and try to fit the map to the paper
    # adjust options accordingly
    # set the plotting region (different from the data set region for limited datasets)
    # here because some projection redefine the corners
    #
    
    switch $proj(1) {
	"B"  { # Albers conic equal-area
	    set prp "-JB[ format %03f $lon0 ]/[ format %03f $lat0 ]/[ format %03f [ expr $south+0.33*$span(2)]]/[ format %03f [ expr $south+0.66*$span(2)]]/[ format %03f [ expr 0.8*$maxmap ]]"
	    set reg "-R$west/$east/$south/$north" 
	}
	"M"  { # Mercator
	    set prp "-JM[ format %03f [ expr 0.8*$maxmap ]]" 
	    if { $north > $mercatorlimit(1) } { 
		set north $mercatorlimit(1)
		dialog .d {Projection warning} \
		    "Since the Mercator projection was chosen, iGMT limits the northern boundary to $mercatorlimit(1)."  warning 0 {OK} 
	    }
	    if { $south < $mercatorlimit(2) } { 
		set south $mercatorlimit(2)
		dialog .d {Projection warning} \
		    "Since the Mercator projection was chosen, iGMT limits the southern boundary to $mercatorlimit(2)."  warning 0 {OK} 
	    }
	    set reg "-R$west/$east/$south/$north" 
	}
	"X"  { 	# linear projection
	    set prp "-JX[ format %03fd [ expr 0.8*$maxmap ]]" 
	    set reg "-R$west/$east/$south/$north" 
	}
	"Q"  { 	# equidistant cylindrical
	    set prp "-JQ$lon0/[format %03f [ expr 0.8*$maxmap ]]"
	    set reg "-R$west/$east/$south/$north" 
	}
	"A" { 	# azimuthal projections, Lambert
	    set prp "-JA$mean(1)/$mean(2)/[ format %03f [ expr 0.8*$maxmap ]]" 
	    if { ( $west == -180 ) && ( $east == 180 ) && ( $south == -90 ) && ( $north == 90 ) } {
		set reg "-R0/360/-90/90" 
		set west 360.0
		set east 0.0
	    } else { 
		# choose the rectangle technique
		set reg "-R$west/$south/$east/[ format %sr $north]"
	    }
	}
	"S" { 	# azimuthal projections, Stereographic
	    if { $mean(2) > 0.0 } {
		set prp "-JS[ format %0lf $mean(1) ]/90/[ format %03f [ expr 0.8*$maxmap ]]" 
		if { $span(2) > 85.0 } {
		    set south [ expr $north - 90.0 ]
		    if { $south < 0.0 } { set south 0.0 }
		    dialog .d {Projection warning} \
			"Reducing the southern boundary to $south for the stereographic projection." \
			warning 0 {OK} 
		}
	    } else {
		set prp "-JS[ format %0lf $mean(1) ]/-90/[ format %03f [ expr 0.8*$maxmap ]]" 
		if { $span(2) > 85.0 } {
		    set north [ expr $north - 90.0 ]
		    if { $north > 0.0 } { set north 0.0 }
		    dialog .d {Projection warning} \
			"Reducing the northern boundary to $north for the stereographic projection." \
			warning 0 {OK} 
		}
	    }
	    set reg "-R$west/$east/$south/$north"
	}
	"G" -
	"E" { # orthographic and azimuthal equidistant
	    set prp "-J$proj(1)$lon0/$lat0/[ format %03f [ expr 0.8*$maxmap ]]" 
	    set reg "-R0/360/-90/90" 
	    set east 360.0 ; set west 0.0
	    set south -90.0 ; set north 90.0
	}
	"H" -
	"N" -
	"I" -
	"W" { # Hammer, Mollweide, Robinson and Sinusoidal projections
	    set prp "-J$proj(1)$lon0/[format %03f [ expr 0.8*$maxmap ]]" 
	    #	    set reg "-R0/360/-90/90" 
	    #	    set east 360.0 ; set west 0.0
	    #	    set south -90.0 ; set north 90.0
	    set reg "-R$west/$east/$south/$north"
	}
	"C" {
	    set prp $custom_projection
	    set reg "-R$west/$east/$south/$north" 
	}
	default { 
	    error "Projection $proj(1) is not implemented!"  
	    set prp "-JX[format %03f [ expr 0.8*$maxmap ]]" 
	    reg "-R$west/$east/$south/$north"
	}
    }
    

    ################################################################################
    # set some pscoast options
    #
    set addsomepscoast 0
    
    if { $shoreline  } { 
	set sl "-W" 
	set addsomepscoast 1 
    } else { set sl "" }
    if { $river(1)  } { 
	set rp "-I1/$psc_linewidth(1)/[ format %03i $river_color(1)]/[ format %03i $river_color(2)]/[ format %03i $river_color(3)] " 
	set addsomepscoast 1
    } else { set rp "" }
    if { $river(2)  } { 
	set rp "$rp -I2/$psc_linewidth(1)/[ format %03i $river_color(1)]/[ format %03i $river_color(2)]/[ format %03i $river_color(3)] " 
	set addsomepscoast 1
    }
    if { $river(3)  } { 
	set rp "$rp -I3/$psc_linewidth(1)/[ format %03i $river_color(1)]/[ format %03i $river_color(2)]/[ format %03i $river_color(3)] " 
	set addsomepscoast 1
    }
    if { $river(4)  } { 
	set rp "$rp -I4/$psc_linewidth(1)/[ format %03i $river_color(1)]/[ format %03i $river_color(2)]/[ format %03i $river_color(3)] " 
	set addsomepscoast 1
    }
    if { $boundary(1)  } { 
	set bp "-N1/$psc_linewidth(2)/000/000/000" 
	set addsomepscoast 1 
    } else { set bp "" }
    if { $boundary(2)  } { set bp "$bp -N2/$psc_linewidth(2)/000/000/000 " ; set addsomepscoast 1}
    

    # procedure used by some of the rater data set plotting commands

    proc check_maximum_resolution { maximum } {
	global raster_resolution
	if { $raster_resolution < $maximum } {
	    set raster_resolution $maximum
	    dialog .d {Resolution adjustment warning} \
		"Changed the resolution to the maximum for this dataset, which is $raster_resolution arc minutes."  warning 0 {OK}
	}
    }

    # procedure to adjust the grimage data region to possible data set limitations
    # (but not pscoast etc., they stay at the user limits as given by $reg)

    proc check_max_data_region { west east south north south_lim north_lim onlyinteger_boundary} {
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
	if { $onlyinteger_boundary } {
	    return "-R[ format %i [ expr int($west)]]/[ format %i [ expr int($east)]]/[ format %i [ expr int($south)]]/[format %i [ expr int($north)]]"
	} else {
	    return "-R$west/$east/$south/$north"
	}
    }   

    if { $portrait  } { set port "-P" } else { set port "" }
    set offsets "-X$ps_offset(1) -Y$ps_offset(2)"


    ################################################################################
    ################################################################################
    # produce the gmt script strings
    # by creating an array of strings that correspond to lines in the final script
    

    set nrs 1
    set nrs [ add_to_script  $nrs gmtstring $shell_to_use ]

    set nrs [ add_to_script  $nrs gmtstring "\# Script produced with iGMT, version 0.5"]
  
    
    ################################################################################
    # first the raster data sets
    
    switch $raster_dataset {
	"1" { # only pscoast features are plotted, i.e. land and sea are shown in a different color
	    puts "iGMT: Invoking pscoast."
	    
	    # this is the syntax for adding a line to the script
	    set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast to plot a map with different colors for land and sea"]
	    
	    # do it like this to add a long line 
	    set line "$pscoast  $sl  $reg $prp -D$resolution $bp $rp \\\n\t"
	    set line "$line $sea_c $land_c $port \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring "$line -K $pscoast_add  $offsets > $ps_filename" ]
	}
	"2" { # ETOPO5 topography and bathymetry
	    check_maximum_resolution 5
	    if { $raster_resolution != 5 } {
		foreach i { 1 2 } {
		    set rres($i) $raster_resolution
		    if { [ expr $span($i)/[ expr $rres($i)/60.0 ]] != [ expr int($span($i)/[ expr $rres($i)/60.0 ]) ] } {
			set rres($i) [ expr $span($i)/int($span($i)/[ expr $rres($i)/60.0 ])*60.0 ] 
			dialog .d {Incremtn adjustment warning} \
			    "Changed the axis $i resolution to $rres($i) to allow even sampling for ETOPO5 grdraster. Better use the full resolution of 5 arc minutes. If iGMT hangs after you click OK it might be because of grdraster."  warning 0 {OK}
		    }
		}
		set inc [ format -I%0fm/%0lfm $rres(1) $rres(2) ]
	    } else { set inc "-I5m" }
	    
	    puts "iGMT: Plotting ETOPO5, resolution [ format %s $inc ], "
	    puts "iGMT: using colormap $colormap."

	    set nrs [ add_to_script  $nrs gmtstring "\# Create a grid file from the ETOPO5 data set." ]
	    set nrs [ add_to_script  $nrs gmtstring "$grdraster 1 -G$grid_filename $verbose $reg $prp $inc" ]
	    if { $shading } {
		set nrs [ add_to_script  $nrs gmtstring "\# Create a shade file." ]
		set nrs [ add_to_script  $nrs gmtstring "$grdgradient $grid_filename -A65 $verbose -G$shade_filename -Nt" ]
	    
		set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
		set line "$grdimage $grid_filename $prp -C$colormap -K  \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring  "$line $verbose -I$shade_filename $port  $offsets > $ps_filename" ]
	    } else {
		set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
		set line "$grdimage $grid_filename $prp -C$colormap -K  \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring  "$line $verbose $port  $offsets > $ps_filename" ]
	    }
	    if { $addsomepscoast } {
		set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for possible features such as national boundaries." ]
		set line "$pscoast  $sl  $reg $prp -D$resolution $bp $rp $port   \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring "$line -O -K $pscoast_add $verbose >> $ps_filename" ]
	    }
	    if { $legend  } {
		set nrs [ add_to_script  $nrs gmtstring "\# Add a scale beneath the plot." ]
		set line "$psscale -C$colormap -D[ expr $papersize(1)*0.35]/-0.5/[expr $maxmap*0.75]/0.2h"
		set line "$line -B:\"m:\" \\\n\t -L -I$shade_filename"
		set nrs [ add_to_script $nrs gmtstring "$line  $verbose -O -K -N300 >> $ps_filename"]
	    }
	}
	"3" { # Smith & Sandwell /GTOPO30 data set 
	    
	    check_maximum_resolution 0.5
	    set inc [ format -I%sm $raster_resolution ]

	    puts "iGMT: Smith&Sandwell/GTOPO30, resolution [ format %s $inc ], "
	    puts "iGMT: using colormap $colormap."

	    set nrs [ add_to_script  $nrs gmtstring "\# Create a grid file using the img2latlongrd" ]
	    set nrs [ add_to_script  $nrs gmtstring "$img2latlongrd $gtopodata  $inc $reg -G$grid_filename -T1" ]
	    
	    if { $shading } {
		
		set nrs [ add_to_script  $nrs gmtstring "\# Create a shade file." ]
		set nrs [ add_to_script  $nrs gmtstring "$grdgradient $grid_filename -A65 $verbose -G$shade_filename -Nt" ]
	    
		set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
		set line "$grdimage $grid_filename $prp -C$colormap -K   \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring  "$line $verbose -I$shade_filename $port  $offsets > $ps_filename" ]
	    } else {
		set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
		set line "$grdimage $grid_filename $prp -C$colormap -K  \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring  "$line $verbose $port  $offsets > $ps_filename" ]
	    }
	    if { $addsomepscoast } {
		set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for possible features such as national boundaries." ]
		set line "$pscoast  $sl  $reg $prp -D$resolution $bp $rp $port   \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring "$line -O -K $pscoast_add $verbose >> $ps_filename" ]
	    }
	    if { $legend  } {
		set nrs [ add_to_script  $nrs gmtstring "\# Add a scale beneath the plot." ]
		set line "$psscale -C$colormap -D[ expr $papersize(1)*0.35]/-0.5/[expr $maxmap*0.85]/0.2h"
		set line "$line -B:\"m:\" \\\n\t -L -I$shade_filename"
		set nrs [ add_to_script $nrs gmtstring "$line  $verbose -O -K -N300 >> $ps_filename"]
	    }
	}
	"4" { # seafloor age 
	    
	    # set the resolution, maximum is -I5m
	    check_maximum_resolution 5
	    set inc [ format -I%sm $raster_resolution]

	    puts  "iGMT: Seafloor age, resolution [ format %s $inc ] "
	    puts "iGMT: using colormap $colormap."

	    # uncomment this to work with grdcut and change $agedata to $$grid_filename
	    #	    set nrs [ add_to_script  $nrs gmtstring "\# Create a grid file using grdcut" ]
	    #	    set nrs [ add_to_script  $nrs gmtstring "$grdcut $agedata $reg $verbose -G$grid_filename" ]
	    
	    set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
	    set line "$grdimage $agedata $prp -C$colormap -K   \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring  "$line $verbose $reg $port  $offsets > $ps_filename" ]
	    
	    set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for land coverage and features such as national boundaries." ]
	    set line "$pscoast  $sl  $reg $prp -D$resolution $bp $rp $port  \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring "$line -O -K $land_c $pscoast_add $verbose >> $ps_filename" ]
	    
	    if { $legend  } {
		set nrs [ add_to_script  $nrs gmtstring "\# Add a scale beneath the plot." ]
		set line "$psscale -C$colormap -D[ expr $papersize(1)*0.35]/-0.5/[expr $maxmap*0.75]/0.2h"
		set line "$line -B:\"Ma:\" \\\n\t -L "
		set nrs [ add_to_script $nrs gmtstring "$line  $verbose -O -K >> $ps_filename"]
	    }
	} 
	"5" { 	# free air gravity anomalies
 	    check_maximum_resolution 2

	    set inc [ format -I%sm $raster_resolution]
	    set data_region [ check_max_data_region $west $east $south $north -72.0 72.0 1 ]
	    
	    puts "iGMT: Freeair gravity, resolution [ format %s $inc ]"
	    puts "iGMT: using colormap $colormap."
	    
	    # comment this out and the stuff below in for the grdcut version

	    set nrs [ add_to_script  $nrs gmtstring "\# Create a grid file using the img2latlongrd" ]
	    set nrs [ add_to_script  $nrs gmtstring "$img2latlongrd $freeair_grav_data  $inc $data_region -G$grid_filename -T1" ]

	    # uncommment this for the grdcut version where you access a fixed resolution grdfile that has
	    # been produced once and for all
	    #	    
	    #	    set nrs [ add_to_script  $nrs gmtstring "\# Create a grid file using grdcut" ]
	    #	    set nrs [ add_to_script  $nrs gmtstring "$grdcut $freeair_grav_data $data_region $verbose -G$grid_filename" ]

	    if { $shading } {

		set nrs [ add_to_script  $nrs gmtstring "\# Create a shade file." ]
		set nrs [ add_to_script  $nrs gmtstring "$grdgradient $grid_filename -A65 $verbose -G$shade_filename -Nt" ]
	    
		set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
		set line "$grdimage $grid_filename $prp $reg -C$colormap -K  -I$shade_filename \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring  "$line $verbose $port  $offsets > $ps_filename" ]
	    } else {
		set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
		set line "$grdimage $grid_filename $prp $reg -C$colormap -K  \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring  "$line $verbose $port  $offsets > $ps_filename" ]
	    }
	    set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for land coverage and features such as national boundaries." ]
	    set line "$pscoast  $sl  $reg $prp -D$resolution $bp $rp $port  \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring "$line -O -K $land_c $pscoast_add $verbose >> $ps_filename" ]

	    if { $legend  } {
		set nrs [ add_to_script  $nrs gmtstring "\# Add a scale beneath the plot." ]
		set line "$psscale -C$colormap -D[ expr $papersize(1)*0.35]/-0.5/[expr $maxmap*0.85]/0.2h"
		set line "$line -B:\"mGal:\" \\\n\t -L "
		set nrs [ add_to_script $nrs gmtstring "$line  $verbose -O -K >> $ps_filename"]
	    }
	}
	"6" { # geoid dat
	    
	    # set the resolution, maximum is -I5m

	    check_maximum_resolution 0.3333333
	    set inc [ format -I%sm $raster_resolution]

	    puts  "iGMT: Geoid, resolution [ format %s $inc ] "
	    puts "iGMT: using colormap $colormap."

	    
	    set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
	    set line "$grdimage $geoid_data $prp -C$colormap -K  \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring  "$line $verbose $reg $port  $offsets > $ps_filename" ]
	    if { $addsomepscoast } {
		set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for possible features such as national boundaries." ]
		set line "$pscoast  $sl  $reg $prp -D$resolution $bp $rp $port  \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring "$line -O -K  $pscoast_add $verbose >> $ps_filename" ]
	    }
	    if { $legend  } {
		set nrs [ add_to_script  $nrs gmtstring "\# Add a scale beneath the plot." ]
		set line "$psscale -C$colormap -D[ expr $papersize(1)*0.35]/-0.5/[expr $maxmap*0.8]/0.2h"
		set line "$line -B:\"m:\" \\\n\t -L "
		set nrs [ add_to_script $nrs gmtstring "$line  $verbose -O -K >> $ps_filename"]
	    }
	} 

	"7" { 	# custom raster data file

 	    # check_maximum_resolution 2
	    
	    set inc [ format -I%sm $raster_resolution]
	    
	    # set data_region [ check_max_data_region $west $east $south $north -72.0 72 ]

	    set data_region $reg
	    
	    puts "iGMT: Custom raster data file"
	    puts "iGMT: $custom_raster_data,"
	    puts "iGMT: resolution [ format %s $inc ],"
	    puts "iGMT: using colormap $colormap."


	    set nrs [ add_to_script  $nrs gmtstring "\# Create a shade file." ]
	    set nrs [ add_to_script  $nrs gmtstring "$grdgradient $custom_raster_data -A65 $verbose -G$shade_filename -Nt" ]
	    
	    set nrs [ add_to_script  $nrs gmtstring "\# Use grdimage to create a raster map." ]
	    set line "$grdimage $custom_raster_data $prp -C$colormap -K  $reg -I$shade_filename \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring  "$line $verbose $port  $offsets > $ps_filename" ]

	    # comment this out if you want land coverage	    
	    # set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for land coverage and features such as national boundaries." ]
	    # set line "$pscoast  $sl  $reg $prp -D$resolution $bp $rp $port  \\\n\t"
	    # set nrs [ add_to_script  $nrs gmtstring "$line -O -K $land_c $pscoast_add $verbose >> $ps_filename" ]

	    if { $addsomepscoast } {
		set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for possible features such as national boundaries." ]
		set line "$pscoast  $sl  $reg $prp -D$resolution $bp $rp $port   \\\n\t"
		set nrs [ add_to_script  $nrs gmtstring "$line -O -K $pscoast_add $verbose >> $ps_filename" ]
	    }

	    if { $legend  } {
		set nrs [ add_to_script  $nrs gmtstring "\# Add a scale beneath the plot." ]
		set line "$psscale -C$colormap -D[ expr $papersize(1)*0.35]/-0.5/[expr $maxmap*0.5]/0.2h"
		set line "$line -B:\"custom:\" \\\n\t -L "
		set nrs [ add_to_script $nrs gmtstring "$line  $verbose -O -K >> $ps_filename"]
	    }
	}
	
	default { error "Raster dataset $raster_dataset is not implemented!" ; set raster_dataset "1" }
    }
    
    
    ################################################################################
    # now the polygon datasets, all optional and "superimposable"
    ################################################################################

    # NUVEL plate boundaries, dataset P1

    if { $polygon_dataset(1)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add NUVEL1 plate boundaries to the plot." ]
	set line "$psxy $plate_boundary_data -: $verbose \\\n\t"
	set line "$line -M $reg $prp -O -K  "
	set line "$line -W$pol_linewidth(1)/[format %03i $plate_color(1)]/[format %03i $plate_color(2)]/[format %03i $plate_color(3)]  >> $ps_filename"
	set nrs [ add_to_script  $nrs gmtstring "$line" ] 
    }
    
    # slab contour data, dataset P9


    if { $polygon_dataset(9)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add slab contours to the plot." ]
	set line "$psxy $slab_contour_data  $verbose \\\n\t"
	set line "$line -M $reg $prp -O -K  "
	set line "$line -W$pol_linewidth(9)/[format %03i $slab_contour_color(1)]/[format %03i $slab_contour_color(2)]/[format %03i $slab_contour_color(3)]  >> $ps_filename"
	set nrs [ add_to_script  $nrs gmtstring "$line" ] 
    }
    
    



    # Steinberger hotspots, P7

    if { $polygon_dataset(7)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add hotspot locations from the Steinberger compilation." ]
	set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"\"))print(\$5,\$4,$symbol_size(7)*$maxmap)}'"
	set line "$line \\\n\t $hotspotdata | \\\n\t"
	set line "$line  $psxy $verbose $reg $prp -O "
	set line "$line -G[format %03i $quake4_color(1)]/[format %03i $quake4_color(2)]/[format %03i $quake4_color(3)]"
	set line "$line -K -S$symbol(7)   >> $ps_filename"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
	if { $hotspot_nametag } { # add the name of the hotspot
	    set nrs [ add_to_script  $nrs gmtstring "\# Add name tags for the hotspot locations." ]
	    set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"\"))printf(\"%g %g %g %g %g %g %s\\n\",\$5-0.02*$maxmap,\$4,10,0,15,3,\$1)}'"
	    set line "$line \\\n\t $hotspotdata | \\\n\t"
	    set line "$line $pstext $reg $prp  -G[format %03i $quake4_color(1)]/[format %03i $quake4_color(2)]/[format %03i $quake4_color(3)]  -O -K >> $ps_filename"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	}
    }


    # volcano list from the Smithsonian Institution, P8

    if { $polygon_dataset(8)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add volcano locations from the Smithsonian." ]
	set line "awk '{if((\$1!=\"#\")&&(\$1!=\"\"))print substr(\$0,61,20)}' $volcanodata |\\\n\t"
	set line "$line awk '{la=\$1;lo=\$3;if(\$2==\"S\")la*=-1;if(\$4==\"W\")lo*=-1;print(lo,la)}'|\\\n\t"
	set line "$line awk '{print(\$1,\$2,$symbol_size(8)*$maxmap)}' | \\\n\t"
	set line "$line  $psxy $verbose $reg $prp -O "
	set line "$line -G[format %03i $quake5_color(1)]/[format %03i $quake5_color(2)]/[format %03i $quake5_color(3)]"
	set line "$line -K -S$symbol(8)   >> $ps_filename"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
	if { $volcano_nametag } { # add the name of the volcano
	    set nrs [ add_to_script  $nrs gmtstring "\# Add name tags for the volcano locations." ]
	    set line "awk '{if((\$1!=\"#\")&&(\$1!=\"\"))print(substr(\$0,61,20),substr(\$0,10,30))}' $volcanodata |\\\n\t"
	    set line "$line awk '{la=\$1;lo=\$3;if(\$2==\"S\")la*=-1;if(\$4==\"W\")lo*=-1;print(lo,la,\$5,\$6,\$7,\$8)}'|\\\n\t"
	    set line "$line awk '{print(\$1-0.08*$maxmap,\$2,10,0,15,3,\$3,\$4,\$5,\$6)}'| \\\n\t"
	    set line "$line $pstext $reg $prp  -G[format %03i $quake5_color(1)]/[format %03i $quake5_color(2)]/[format %03i $quake5_color(3)] -O -K >> $ps_filename"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	}
    }

    
    # CMT solutions, P6

    if { $polygon_dataset(6)  } { 
 	set nrs [ add_to_script  $nrs gmtstring "\# Add CMT solutions in psvelomeca format to the plot." ]
 	set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"\"))print(\$0)}' $cmtdata |\\\n\t"
	set line "$line $psvelomeca $reg $verbose "
	set line "$line -G[format %03i $quake3_color(1)]/[format %03i $quake3_color(2)]/[format %03i $quake3_color(3)]\\\n\t"
 	set line "$line $prp -O -K -Sc[format %03f [ expr $symbol_size(6)*$maxmap ]] >> $ps_filename"
 	set nrs [ add_to_script  $nrs gmtstring "$line" ] 
    }
    
    # significant quakes, take only the ones with magnitude assignment, P2

    if { $polygon_dataset(2)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add significant NGDC earthquakes with magnitudes to the plot" ]
	set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"*\")&&(\$1!=\"\")&&(\$9 != \"0\"))print(\$7,\$6,\$9*$symbol_size(2)*$maxmap)}'"
	set line "$line \\\n\t $xysize_data(1) | \\\n\t"
	set line "$line  $psxy $verbose $reg $prp -O "
	set line "$line -G[format %03i $quake1_color(1)]/[format %03i $quake1_color(2)]/[format %03i $quake1_color(3)]"
	set line "$line -K -S$symbol(2)   >> $ps_filename"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
    }

    # USGS/NEIS PDE catalog quakes above 5, 1973-1998, P3

    if { $polygon_dataset(3)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add significant USGS/NEIC 73-98 >5 " ]
	set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"\"))print(\$7,\$6,\$9*$symbol_size(3)*$maxmap)}'"
	set line "$line \\\n\t $xysize_data(2) | \\\n\t"
	set line "$line  $psxy $verbose $reg $prp -O "
	set line "$line -G[format %03i $quake2_color(1)]/[format %03i $quake2_color(2)]/[format %03i $quake2_color(3)]"
	set line "$line  -K -S$symbol(3)   >> $ps_filename"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
    }

    # first custom data set, P4

    if { $polygon_dataset(4)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add custom data from $custom1(5) " ]
	set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"\"))print(\$$custom1(1),\$$custom1(2),\$$custom1(3)*$custom1(4)*$maxmap*$symbol_size(4))}'"
	set line "$line \\\n\t $custom1(5) | \\\n\t"
	set line "$line  $psxy $verbose $reg $prp -O "
	set line "$line -G[format %03i $custom1_color(1)]/[format %03i $custom1_color(2)]/[format %03i $custom1_color(3)]"
	set line "$line  -K -S$symbol(4)   >> $ps_filename"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
    }

    # second custom data set, P5

    if { $polygon_dataset(5)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add custom data from $custom2(5) " ]
	set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"\"))print(\$$custom2(1),\$$custom2(2),\$$custom2(3)*$custom2(4)*$maxmap*$symbol_size(5))}'"
	set line "$line \\\n\t $custom2(5) | \\\n\t"
	set line "$line  $psxy $verbose $reg $prp -O "
	set line "$line -G[format %03i $custom2_color(1)]/[format %03i $custom2_color(2)]/[format %03i $custom2_color(3)]"
	set line "$line  -K -S$symbol(5)   >> $ps_filename"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
    }
      

    # uncomment this for an attempt to plot the plot_title using pstext instead of the -B version below
    # title location is some percent of vertical plot size above northern boundary
    if { ($use_pstext_for_title) && ($plot_title != "") } {
	set line "echo  [ expr $mean(1)*1.02 ]  [ expr $north+0.07*$span(2)] $title_font_size 0 $title_font  6 \"$plot_title\" | "
	set line "$line $pstext $reg $prp "
	set nrs [ add_to_script  $nrs gmtstring "$line $port -N -O -K >> $ps_filename" ]
    } 
    

    # Velocity solutions, P10

    if { $polygon_dataset(10)  } { 
 	set nrs [ add_to_script  $nrs gmtstring "\# Add station positions in psxy format to the plot." ] 
 	set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"\")&&(\$7<=ms)&&(\$8<=ms))print(\$1,\$2,$symbol_size(10))}' ms=$maxsigma(1) $veldata |\\\n\t"
   set line "$line $psxy $verbose $reg $prp -O "
	set line "$line -W1/[format %03i $site1_color(1)]/[format %03i $site1_color(2)]/[format %03i $site1_color(3)]"
	set line "$line  -K -S$symbol(10)   >> $ps_filename" 
 	set nrs [ add_to_script  $nrs gmtstring "$line" ] 

 	set nrs [ add_to_script  $nrs gmtstring "\# Add Velocity solutions in psvelomeca format to the plot." ] 
 	set line "awk '{if((\$1!=\"\#\")&&(\$1!=\"\")&&(\$7<=ms)&&(\$8<=ms))print(\$1,\$2,\$3,\$4,\$7,\$8,\$9,substr(\$13,1,4))}' ms=$maxsigma(1) $veldata |\\\n\t"
	set line "$line $psvelomeca $reg $verbose "
	set line "$line -G[format %03i $vector1_color(1)]/[format %03i $vector1_color(2)]/[format %03i $vector1_color(3)]"
   set line "$line -W1/[format %03i $vector1_color(1)]/[format %03i $vector1_color(2)]/[format %03i $vector1_color(3)]"
   set line "$line -A[format %5.4f [expr $pol_linewidth(10)/100.0]]/[format %5.4f [expr $pol_linewidth(10)/20.0]]/[format %5.4f [expr $pol_linewidth(10)/60.0]]\\\n\t"
 	set line "$line $prp -O -K -Se[format %03f [ expr $velscale(1)/25.4]]/[format %03f $confint(1)]/[format %03i $sitefont(1)] -D[format %03f $uncscale(1)] >> $ps_filename"
 	set nrs [ add_to_script  $nrs gmtstring "$line" ] 

 	set nrs [ add_to_script  $nrs gmtstring "\# Add Velocity scale vector to the plot." ]
   if { $vecscale(1) != 0. } {
   set line "echo [ expr $east-($east-$west)/5.0 ] [ expr $south+($north-$south)/12.0 ] 0.0 $vecscale(1) 0.0 0.0 0.0 $vecscale(1) mm/yr |\\\n\t"
   set line "$line $psvelomeca $reg $verbose $prp -O -K -Se[format %03f [ expr $velscale(1)/25.4]]/.95/15" 
	set line "$line -G[format %03i $vector1_color(1)]/[format %03i $vector1_color(2)]/[format %03i $vector1_color(3)]"
   set line "$line -A[format %5.4f [expr $pol_linewidth(10)/100.0]]/[format %5.4f [expr $pol_linewidth(10)/20.0]]/[format %5.4f [expr $pol_linewidth(10)/60.0]] >> $ps_filename"
 	set nrs [ add_to_script  $nrs gmtstring "$line" ]
      }
    }
  
    
    ################################################################################
    # add a frame for the map using psbasemap and complete the plot
    #

    set nrs [ add_to_script  $nrs gmtstring "\# Use psbasemap for basic map layout, possible title"]
    set nrs [ add_to_script  $nrs gmtstring "\#     and complete the plot"]
    set line "$psbasemap  $reg $verbose $prp $port $frame_box \\\n\t"
    if { $show_gmt_logo } { set line "$line -U" }
    if { $mapscale } { 
	set nrs [ add_to_script  $nrs gmtstring "\#     map-scale is correct in the middle of the plot"]
#	set line "$line -Lf[ expr $west + $span(1)*0.09 ]/[ expr $south + $span(2)*0.05]/$mean(2)/[ format %05.0lf [ expr $span(1)*15 ]]"
	set line "$line -Lfx1.3/0.3/$mean(2)/[ format %05.0lf $mscale]"
    }
    set nrs [ add_to_script  $nrs gmtstring "$line -O $pscoast_add  >> $ps_filename" ]

    
    
    ################################################################################
    # print the script strings into a file


    set file [open $batchfile w]
    foreach i [lsort -integer [ array names gmtstring ]] {
	puts $file $gmtstring($i)
    }
    close $file

    ################################################################################
    # execute the GMT script and save error messages
    # allow for process being killed 
    # return 1 for success, 0 is killed 
    #
    # idea of command batch handling from Alexandre Ferrieux
    #
   
    proc sad_return {  } { 
	global  headermessage 
	set headermessage "iGMT: Script was interrupted."
	update idletasks	
	catch { exec rm ./.gmtcommands 2> /dev/null &}
	destroy .panel
    }
    
    proc happy_return {   } {
	global headermessage batchfile  
	set headermessage "iGMT: Done, commands in $batchfile."
	update idletasks
	catch { exec rm ./.gmtcommands 2> /dev/null &}
	destroy .panel
    }

    # show a kill panel
   
    set headermessage "iGMT: Running the script..."
    update idletasks
    set retval 1
    
    toplevel .panel 
    wm title .panel "Script control..."

    # set the file_pointer to the piped batchfile command

    if { [ catch  [  list set file_pipe [open "| $batchfile 2> $batcherr " r] ] ] } {
	error "While trying to execute $batchfile. Make sure that the file exists and is executable (usually checked by the iGMT start-up sequence). If you want to recreate the file, type \"touch $batchfile\" and \"chmod +x $batchfile\" in a shell window. Quitting and restarting might be a better idea."
	sad_return
	set retval 0
    } 
    set batch_pid [pid $file_pipe]
    fileevent $file_pipe readable "happy_return"
    label .panel.label -text "Now running the GMT script $batchfile.\nThis might take a while. If errors occur or raster data sets look strange,\n check the stderr output (under menu item \"Scripting option\") first.\nInterrupt the background job with the \"Panic!\" button below.\n\n"
    button .panel.kill -text "Panic!" -command { 

	# try to kill child processes first

	catch { exec ps -f | grep $batch_pid | awk "{printf(\"%i \",\$2)}" } tmp_var 
	if { $tmp_var != "" } {
	    foreach child $tmp_var {
		catch { exec kill -9 $child }
	    }
	}
	
	# now kill the batch itself, if not already killed
	catch { exec kill -9 $batch_pid  }

	sad_return 
	set retval 0
    }
    pack .panel.label .panel.kill -side top
    grab set .panel
    focus .panel
    tkwait window .panel
    catch { close $file_pipe }

    return $retval
}

################################################################################
# display the postscript file using the default UNIX program
################################################################################

proc dsp_ps {} {
    global ps_filename psviewer_command_landscape portrait\
	psviewer_command_portrait
    
    # check for possible rotation
    
    if { $portrait == 0 } { 
	set tmp_pid [ eval "exec $psviewer_command_landscape $ps_filename &" ]
    } else {
	set tmp_pid [ eval "exec $psviewer_command_portrait  $ps_filename &"]
    }
    return 
}

################################################################################
# convert the postscript file to be able to display it, 
# only GIF is supported so far
################################################################################

proc conv_ps {} {
    global gif_filename ps_filename headermessage portrait ps_to_gif_command_landscape\
	ps_to_gif_command_portrait

    set headermessage "iGMT: Converting $ps_filename to $gif_filename..."
    update idletasks
    if { $portrait == 0 } { 
	set tmp_pid [ eval "exec $ps_to_gif_command_landscape"]
    } else {
	set tmp_pid [ eval "exec $ps_to_gif_command_portrait"]
    }	
    set headermessage "iGMT: Converting done."
    update idletasks
    return
}


################################################################################
# delete the old and display the new GIF image in the lower frame
################################################################################


proc refresh_image {} {
    global  map_image gif_filename
    image delete map_image
    image create photo map_image -file $gif_filename
}



