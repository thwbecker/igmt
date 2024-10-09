################################################################################
#    iGMT: Interactive Mapping of Geoscientific Datasets.                      #
#                                                                              #
#    Copyright (C) 1998 - 2005  Thorsten W. Becker, Alexander Braun            #
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
#    In addition, we strongly suggest that iGMT users comply with the goals    #
#    as expressed in the Student Pugwash Pledge (www.spusa.org/pugwash/).      #
#                                                                              #
#    You should have received a copy of the GNU General Public License         #
#    along with this program; see the file COPYING.  If not, write to          #
#    the Free Software Foundation, Inc., 59 Temple Place - Suite 330,          #
#    Boston, MA 02111-1307, USA.                                               #
#                                                                              #
################################################################################
################################################################################
#
# igmt_plotting.tcl -- routines used for plotting
#
# part of the iGMT package
#
# $Id: igmt_plotting.tcl,v 1.32 2004/03/23 17:41:00 becker Exp becker $
#
################################################################################



################################################################################
# main procedures for plotting
# produce the GMT script and thus the postscript file
################################################################################

proc mk_ps {} {
    global west east south north proj ps_filename \
	papersize pscoast_color  batchfile no_convert_complaints  \
	portrait ticks  headermessage   raster_bounds \
	river boundary resolution shoreline batcherr \
	pscoast_add raster_dataset plot_title shell_to_use \
	retval poly_data poly_color poly_symbol \
	poly_linewidth poly_symbol_size poly_parameter \
	raster_data raster_colormap \
	gmtbins temp_grid_filename verbose \
	temp_shade_filename topocolor raster_resolution \
	lon0 lat0 use_img2latlon_batch \
	custom_projection legend title_font_size \
	title_font saved polygon_dataset  \
	gridlines mercatorlimit annotation \
	psc_linewidth batch_pid colormap \
	shading mapscale  ps_offset \
	use_pstext_for_title show_gmt_logo  \
	gmt_version igmt_version  wet_areas  \
	igmt_root gmt_version_boundary our_awk \
	temp_cont_int_filename contour_para rasterpath


    set headermessage "iGMT: Creating postscript file."



    # this routine works by 
    # a) defining strings such as the projection
    # b) assembling a sequence of strings calling the GMT commands within the script
    # c) writing and executing the script


    # initialize the strings to be formed later
    set scale_unit_string "" 

    
    # use psvelomeca or the separate programs psmeca 
    # and psvelo for plotting
    #set psmeca    psvelomeca
    #set psvelo    psvelomeca
    set psmeca "psmeca -o"
    set psvelo psvelo


    ################################################################################
    # calculate the size of the page and other geometrical stuff
    
    if { $portrait  } { set maxmap $papersize(1)  } else { set maxmap $papersize(2) }
    set span(1) [ expr ($east  - $west) ]
    set span(2) [ expr ($north - $south) ]
    set mean(1) [ expr ($east  + $west)/2.0 ]
    set mean(2) [ expr ($north + $south)/2.0 ]
    # standard parallels 
    foreach i { 1 2 } {
	set std_par($i) [ expr $south+0.33*$span($i)]
    }
    # distance of name tags from location to be named
    set tagdist [ expr $span(1)/1000. ]
    foreach i { 1 2 } { set interval($i) [ expr $span($i)/($ticks($i)+1) ] }
    foreach i { 1 2 } { 
	if { $interval($i) > 0.5 } { 
	    set i_format($i) 0
	} elseif { $interval($i) > 0.05 } { 
	    set i_format($i) 1 
	} elseif { $interval($i) > 0.005 } { 
	    set i_format($i) 2 
	} elseif { $interval($i) > 0.0005 } { 
	    set i_format($i) 3
	} else {
	    set i_format($i) 4
	}
	# generate a format string
	set i_length($i) [ expr $i_format($i) + 5 ]

	#set i_format($i) "%0[ format %i.%if  $i_length($i) $i_format($i) ]"
	set i_format($i) "%0[ format %i.%if  $i_length($i) $i_format($i) ]"
	
	# spacing of annotation around map

	set aspacing($i) [ format $i_format($i) [ expr $interval($i) ]]

	# required by tcl 8.5
	scan $aspacing($i) %f aspacing_nozero($i)

	#
	# want it to be even numbers
	if { ($aspacing($i) > 1)  && ([ expr $aspacing($i) % 2 ] != 0) } {
	    incr aspacing($i)  
	}
	# spacing of grid
        set gspacing($i) [ format %5.3f  [ expr [ format %f $aspacing_nozero($i) ] / 2.0 ] ]
	# spacing of black/white intervals
	set fspacing($i) [ format %5.3f  [ expr [ format %f $aspacing_nozero($i) ] / 2.0 ] ]
    }

    
    # mapscale hack, originally from Simon Mc Clusky

    set mscale 10.0
    if  { $span(1) > 1.0   } { set mscale 20.0   } 
    if  { $span(1) > 2.0   } { set mscale 50.0   } 
    if  { $span(1) > 5.0   } { set mscale 100.0  } 
    if  { $span(1) > 10.0  } { set mscale 200.0  } 
    if  { $span(1) > 20.0  } { set mscale 500.0  } 
    if  { $span(1) > 50.0  } { set mscale 1000.0 } 
    if  { $span(1) > 100.0 } { set mscale 2000.0 } 
    if  { $span(1) > 200.0 } { set mscale 5000.0 } 

    # create the -B string for boundary annotation and grid lines
    

    if { $use_pstext_for_title } { set tmp_plot_title "" } else { set tmp_plot_title $plot_title }
    if { ($gridlines) && ($annotation) } {
	set frame_box "-Ba$aspacing(1)f$fspacing(1)g$gspacing(1)/a$aspacing(2)f$fspacing(2)g$gspacing(2)"
    } elseif { ($gridlines == 0)&&($annotation) } {
	set frame_box "-Ba$aspacing(1)f$fspacing(1)/a$aspacing(2)f$fspacing(2)"
    } elseif { ($gridlines )&&($annotation == 0) } {
	set frame_box "-Bg$gspacing(1)/g$gspacing(2)"
    } else { set frame_box "-B" }
    # add title, even if empty
    set frame_box "[ format %s:.\"$plot_title\": $frame_box ]"
    # add type of annotation
    if { $annotation == 1 } { 
	set frame_box "[ format %sWESN $frame_box  ]"
    } elseif { $annotation == 2 } {
	set frame_box "[ format %sWeSn $frame_box  ]"
    }


    set proj(2) [ expr ($span(1)>$span(2))?($maxmap/$span(1)):($maxmap/$span(2)) ]

    
    #
    # colors for sea, land and rivers
    #
    set sea_c   "-S[ format %03i/%03i/%03i $pscoast_color(2,1) $pscoast_color(2,2) $pscoast_color(2,3)]"
    set land_c  "-G[ format %03i/%03i/%03i $pscoast_color(1,1) $pscoast_color(1,2) $pscoast_color(1,3)]"
    set river_c "[ format %03i/%03i/%03i   $pscoast_color(3,1) $pscoast_color(3,2) $pscoast_color(3,3)]"
    
    ################################################################################
    # deal with the different projections and try to fit the map to the paper
    # adjust options accordingly
    # set the plotting region (different from the data set region for limited datasets)
    # here because some projection redefine the corners
    #
    
    switch $proj(1) {
	"B"  { # Albers conic equal-area
	    set prp "-JB[ format %03f/%03f/%03f/%03f/%03f $mean(1) $mean(2) $std_par(1) $std_par(2) [ expr 0.8*$maxmap ]]in"
	}
	"D"  { # Equidistant Conic projection
	    set prp "-JD[ format %03f/%03f/%03f/%03f/%03f $mean(1) $mean(2) $std_par(1) $std_par(2) [ expr 0.8*$maxmap ]]in"
	}
	"Y"  { # General Cylindrical Projections
	    puts "iGMT: General Cylindrical Projection: using $lat0 as reference latitude"
	    set prp "-JY[ format %03f/%03f/%03f $mean(1) $lat0 [ expr 0.8*$maxmap ]]i"
	}
	"C"  { # Cassini
	    set prp "-JC[ format %03f/%03f/%03f  $mean(1) $mean(2) [ expr 0.8*$maxmap ]]i"
	}
	"M"  { # Mercator
            if { $gmt_version == 3.0 } {
	    	set prp "-JM[ format %03f [ expr 0.8*$maxmap ]]i" 
	    	puts "iGMT: Mercator projection, GMT 3.0 style"
            } else {
	    	set prp "-JM[ format %03f/%03f/%03f $mean(1) $lat0 [ expr 0.8*$maxmap ]]i" 
	    	puts "iGMT: Mercator projection, using $lat0 as reference latitude"
	    }
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
	}
	"X"  { 	# linear projection
	    set prp "-JX[ format %03fd [ expr 0.8*$maxmap ]]i" 
	}
	"Q"  { 	# equidistant cylindrical
	    set prp "-JQ$lon0/[format %03f [ expr 0.8*$maxmap ]]i"
	}
	"A" { 	# azimuthal projections, Lambert
	    set prp "-JA[ format %03f/%03f/%03f $mean(1) $mean(2) [ expr 0.8*$maxmap ]]i" 
	    if { ( $west == -180 ) && ( $east == 180 ) && ( $south == -90 ) && ( $north == 90 ) } {
		set west 360.0
		set east 0.0
	    } else { 
		# choose the rectangle technique
		set reg "-R$west/$south/$east/[ format %sr $north]"
	    }
	}
	"S" { 	# azimuthal projections, Stereographic
	    if { $mean(2) > 0.0 } {
		set prp "-JS[ format %0f/90/%03f $mean(1) [ expr 0.8*$maxmap ]]i" 
		if { $span(2) > 85.0 } {
		    set south [ expr $north - 90.0 ]
		    if { $south < 0.0 } { set south 0.0 }
		    dialog .d {Projection warning} \
			"Reducing the southern boundary to $south for the stereographic projection." \
			warning 0 {OK} 
		}
	    } else {
		set prp "-JS[ format %0f/-90/%03f $mean(1) [ expr 0.8*$maxmap ]]i" 
		if { $span(2) > 85.0 } {
		    set north [ expr $north - 90.0 ]
		    if { $north > 0.0 } { set north 0.0 }
		    dialog .d {Projection warning} \
			"Reducing the northern boundary to $north for the stereographic projection." \
			warning 0 {OK} 
		}
	    }
	}
	"G" -
	"E" { # orthographic and azimuthal equidistant
	    set prp "-J$proj(1)$lon0/$lat0/[ format %03f [ expr 0.8*$maxmap ]]i" 
	    set east 360.0 ; set west 0.0
	    set south -90.0 ; set north 90.0
	}
	"H" -
	"N" -
	"I" -
	"W" { # Hammer, Mollweide, Robinson and Sinusoidal projections
	    set prp "-J$proj(1)$lon0/[format %03f [ expr 0.8*$maxmap ]]i" 
	}
	"Custom" {
	    set prp $custom_projection
	}
	default { 
	    error "Projection $proj(1) is not implemented!"  
	    set prp "-JX[format %03f [ expr 0.8*$maxmap ]]i" 
	    
	}
    }
    ################################################################################@
    # set the plotting region
    set region "[ format -R%g/%g/%g/%g $west $east $south $north]"

    ################################################################################
    # obtain raster data set specific settgins such as
    # the data_region variable: adjust data region for grdimage for different raster data sets
    #                if raster data sets cover whole earth, will be the same as $region
    # the increment (resolution)
    # and the resample on/off switch
    # routine is in igmt_datasets.tcl
    #
    obtain_raster_data_specs data_region inc resample $raster_dataset $raster_resolution \
	span  raster_bounds $west $east $south $north 

    ################################################################################
    # set some pscoast options
    #
    # this is the switch to activate the pscoast line
    set addsomepscoast 0
    foreach i { 1 2 3 4 5 } { set addsomepscoast [ expr $addsomepscoast + $river($i) ] }
    set addsomepscoast [ expr $addsomepscoast + $shoreline ]
    foreach i { 1 2  } { set addsomepscoast [ expr $addsomepscoast + $boundary($i) ] }

    if { $shoreline  } { 
	set sl "-W$psc_linewidth(3)p/[ format %03i $pscoast_color(4,1)]/[ format %03i $pscoast_color(4,2)]/[ format %03i $pscoast_color(4,3)]" 
    } else { set sl "" }
    if { $river(1)  } { 
	set river_polygons "-I1/$psc_linewidth(1)p/$river_c" 
    } else { set river_polygons "" }
    if { $river(2)  } { 
	set river_polygons "$river_polygons -I2/$psc_linewidth(1)p/$river_c " 
    }
    if { $river(3)  } { 
	set river_polygons "$river_polygons -I3/$psc_linewidth(1)p/$river_c " 
    }
    if { $river(4)  } { 
	set river_polygons "$river_polygons -I4/$psc_linewidth(1)/$river_c " 
    }
    if { $river(5) } {
	set river_polygons "$river_polygons -S$river_c" 
    }
    if { $boundary(1)  } { 
	set natbound_polygons "-N1/$psc_linewidth(2)p/0" 
    } else { set natbound_polygons "" }
    if { $boundary(2)  } { set natbound_polygons "$natbound_polygons -N2/$psc_linewidth(2)p/0 " }

    # create the resolution string for pscoast

    if { $resolution == "cred" } {
	set resolution_string "-Dc -A50000"
    } else {
	set resolution_string "-D$resolution"
    }
    
    if { $portrait  } { set port "-P" } else { set port "" }
    # 
    # adjust offset for some datasets
    if { ($portrait) && ($legend) && ($raster_dataset==10) } {
	set offsets "-X$ps_offset(1)i -Y[ format %g [ expr $ps_offset(2)+1 ]]i"
    } else {
	set offsets "-X$ps_offset(1)i -Y$ps_offset(2)i"
    }


    ################################################################################
    # produce the gmt script strings
    # by creating an array of strings that correspond to lines in the final script
    #

    # header
    set nrs 1
    set nrs [ add_to_script  $nrs gmtstring "\#!$shell_to_use" ]
    set nrs [ draw_script_line $nrs gmtstring ]
    set nrs [ add_to_script  $nrs gmtstring "\#\n\# script produced with iGMT, version $igmt_version\n\#"]
    set nrs [ add_to_script  $nrs gmtstring "\# All commands are in bash resp. ksh syntax:"]
    set nrs [ add_to_script  $nrs gmtstring "\# \"\#\" leads a comment line, \"\\\" means line continuation"]
    set nrs [ add_to_script  $nrs gmtstring "\# and variables are declared as \"a=1\" and referenced as \"echo \$a\"\n\#"]
    set nrs [ draw_script_line $nrs gmtstring ]
    
    
    ################################################################################
    # begin the  block of shell variables that are set within the 
    # script

    set nrs [ add_to_script  $nrs gmtstring "\# The following variables are used for all the GMT commands."]
    set nrs [ add_to_script  $nrs gmtstring "\# Modify the settings here, further down all references in the script"]
    set nrs [ add_to_script  $nrs gmtstring "\# such as \"\$region\" are replaced by the shell.\n"]

    
    
    if { $gmtbins != "" } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Location of the GMT binaries: "]
	set nrs [ add_to_script  $nrs gmtstring "gmtbin=$gmtbins\n"]
    }

    set nrs [ add_to_script  $nrs gmtstring "\#	save old gmtdefaults paper size setting and use EPS"]
    set nrs [ add_to_script  $nrs gmtstring "old_psize=`\$gmtbin/gmtdefaults -L | grep PAPER_MEDIA | gawk '{print(\$3)}'`"]
    set nrs [ add_to_script  $nrs gmtstring "\$gmtbin/gmtset PAPER_MEDIA letter+\n"]


    set nrs [ add_to_script  $nrs gmtstring "\# Geographical variables: \n"]
    #  this sets the variable for the projection
    set nrs [ add_to_script  $nrs gmtstring "\# Set the projection, typically the last number is the mapwidth "]
    set nrs [ add_to_script  $nrs gmtstring "projection=$prp\n"]

    # this sets the variable for the region
    set nrs [ add_to_script  $nrs gmtstring "\# Set the plotting region (west/east/south/north boundaries)"]
    set nrs [ add_to_script  $nrs gmtstring "region=$region\n"]

    if { $raster_dataset != 1 } { # if we are not only using pscoast
	# set the data region
	set nrs [ add_to_script  $nrs gmtstring "\# Set the data region (might be different from  plotting region)"]
	set nrs [ add_to_script  $nrs gmtstring "data_region=$data_region\n"]
	if { $inc != "" } {
	    # set the raster data resolution
	    set nrs [ add_to_script  $nrs gmtstring "\# Set the raster data resolution"]
	    set nrs [ add_to_script  $nrs gmtstring "raster_inc=$inc\n"]
	}
    }


    set nrs [ add_to_script  $nrs gmtstring "\# Postscript output: \n"]
    # this sets the variable for the output file
    set nrs [ add_to_script  $nrs gmtstring "\# Set the name of the output (postscript) file "]
    set nrs [ add_to_script  $nrs gmtstring "ps_filename=$ps_filename\n"]
    # ps offset setting
    set nrs [ add_to_script  $nrs gmtstring "\# Set the X and Y offset on the postscript plot (in inches)"]
    set nrs [ add_to_script  $nrs gmtstring "offsets='$offsets'\n"]
    # portrait/landscape swith
    set nrs [ add_to_script  $nrs gmtstring "\# set this to -P for portrait mode, else landscape"]
    set nrs [ add_to_script  $nrs gmtstring "portrait=$port\n"]
    # verbosity
    set nrs [ add_to_script  $nrs gmtstring "\# set this to -V for verbose GMT output, else leave blank for quite mode"]
    set nrs [ add_to_script  $nrs gmtstring "verbose=$verbose\n"]
    


    # main data location
    set nrs [ add_to_script  $nrs gmtstring "\# main directory for data, mainly raster (grd) type: \n"]
    set nrs [ add_to_script  $nrs gmtstring "rasterpath=$rasterpath\n"]
    
    if { $raster_dataset != 1 } {
	# raster data set variable that are not used if only pscoast coverage selected 
	set nrs [ add_to_script  $nrs gmtstring "\# raster data set specific: \n"]




	# this sets the variable for the colormap
	set nrs [ add_to_script  $nrs gmtstring "\# Set the name of the colormap used for imaging a grid file"]
	set nrs [ add_to_script  $nrs gmtstring "colormap=$colormap\n"]
	# this sets the variable for the output grd file
	set nrs [ add_to_script  $nrs gmtstring "\# Set the name of the temporary grd file output"]
	set nrs [ add_to_script  $nrs gmtstring "temp_grid_filename=$temp_grid_filename\n"]
	#
	# if generic or special plotting shading is set:
	#
	if { ($shading)||($raster_dataset == 10) } { 
	    # this sets the filename for the shade output
	    set nrs [ add_to_script  $nrs gmtstring "\# Set the name of the temporary shade file output"]
	    set nrs [ add_to_script  $nrs gmtstring "temp_shade_filename=$temp_shade_filename\n"]
	}
	if { $contour_para(1) } {
	    set nrs [ add_to_script $nrs gmtstring "\# Set the name of the contour intervals file" ]
	    set nrs [ add_to_script $nrs gmtstring "temp_cont_int_filename=$temp_cont_int_filename\n"]
	}
	
    }
    
    # World Stress Map data location P15
    if { $polygon_dataset(15)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# location of WSM data file" ]
	set nrs [ add_to_script  $nrs gmtstring "wsm_data=$poly_data(15)\n" ]
    }


    ################################################################################
    # now GMT commands
    
    
    set nrs [ draw_script_line $nrs gmtstring ]
    set nrs [ add_to_script  $nrs gmtstring "\#\n\# GMT plotting commands follow\n\#"]
    set nrs [ draw_script_line $nrs gmtstring ]
    
    ################################################################################
    # first the RASTER DATA SETS
    ################################################################################

    # all raster data sets besides 'pscoast only' (which is of course not really a
    # raster data set) need another call to pscoast to add shoreline etc.
    if { $raster_dataset != 1 } { set wantpscoast 1 } else { set wantpscoast 0 }


    

    # new philosophy: always create a temporary grid file that other procedures
    # such as 'create grid image' and 'create colormap' operate on
    # has advantages in terms of speed, too


    switch $raster_dataset {
	"1" { # only pscoast features are plotted, i.e. land and sea are shown in a different color
	    puts "iGMT: calling pscoast"
	    # this is the syntax for adding a line to the script
	    set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast to plot a map with different colors for land and sea"]
	    # do it like this to add a long line 
	    set line "\$gmtbin/pscoast  $sl  \$region \$projection $resolution_string $natbound_polygons $river_polygons \\\n\t"
	    set line "$line $sea_c $land_c \$portrait \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring "$line -K $pscoast_add  \$offsets > \$ps_filename\n" ]
	    # we do not need another pscoast call
	    set wantpscoast 0
	}
	"2" { # ETOPO5 topography and bathymetry
	    # create strings for GMT version dependent commands such as psscale with -B option
	    version_dependent_strings   "m"  scale_unit_string 
	    puts "iGMT: Plotting ETOPO5, resolution $inc, max is $raster_bounds(2,6) m"
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\# Create a temporary grid file from the ETOPO5 data set." ]
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\$gmtbin/grdraster 1 -G\$temp_grid_filename \$verbose \$data_region \$projection  \\\n\t\$raster_inc" ]
	    # plot the temporary grid file
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose $legend $papersize(1) $maxmap\
			  $scale_unit_string "-C\$colormap" 1 contour_para ]

	}
	"3" { # Smith & Sandwell /GTOPO30 data set 
	    puts "iGMT: Smith & Sandwell/GTOPO30, resolution $inc, max is $raster_bounds(3,6) m "
	    # create strings for GMT version dependent commands such as psscale with -B option
	    version_dependent_strings   "m"  scale_unit_string 
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\# Plotting GTOPO30 topography " ]
	    if { $use_img2latlon_batch } { # use our own script for circumventing the absence of img2latlongrd
		puts "iGMT: using img2grd script, resolution fixed"
       		set nrs [ add_to_script  $nrs gmtstring \
			      "\# Create a temporary grid file using the img2grd script" ]
		set line "\$gmtbin/img2grd $raster_data(3) \\\n\t"
		set line "$line \$data_region -T1 -G\$temp_grid_filename -S1" 
		set nrs [ add_to_script  $nrs gmtstring $line ]
	    } else {
		set nrs [ add_to_script  $nrs gmtstring \
			      "\# Create a temporary grid file using img2latlongrd" ]
		set nrs [ add_to_script  $nrs gmtstring \
			      "\$gmtbin/img2latlongrd $raster_data(3) \$raster_inc \$data_region -G\$temp_grid_filename -T1 -S1" ]
	    }
	    # plot the temporary grid file
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose \
			  $legend  $papersize(1) $maxmap $scale_unit_string  "-C\$colormap" 1 \
			  contour_para ]
	}
	"4" { # seafloor age 
	    puts  "iGMT: Seafloor age, resolution fixed to avoid extrapolation"
	    # create strings for GMT version dependent commands such as psscale with -B option
	    version_dependent_strings   "Ma"  scale_unit_string 
	    # create temporary grid file
	    set nrs [ create_temp_grid $nrs gmtstring "sea-floor age" \
			  $raster_data(4)  $data_region $resample $inc \
			  $temp_grid_filename $region 1 $raster_bounds(4,6) $raster_resolution ]
	    # plot the temporary grid file
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose \
			  $legend $papersize(1) $maxmap $scale_unit_string  "-C\$colormap" 1 \
			  contour_para ]
	    # pscoast land coverage 
	    set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for land overlay" ]
	    set line "\$gmtbin/pscoast  $sl  \$region \$projection $resolution_string"
	    set line "$line $natbound_polygons $river_polygons \$portrait  \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring \
			  "$line -O -K $land_c $pscoast_add \$verbose >> \$ps_filename\n" ]

	} 
	"5" { 	# free air gravity anomalies on sea
	    puts "iGMT: Freeair gravity, resolution $inc, max is $raster_bounds(5,6) m"
	    # create strings for GMT version dependent commands such as psscale with -B option
	    version_dependent_strings   "mGal"  scale_unit_string 
	    set nrs [ add_to_script  $nrs gmtstring "\# Plotting seafloor gravity" ]

	    # comment this out and the stuff below in for the grdcut version
	    if { $use_img2latlon_batch } { 
		puts "iGMT: using img2grd script, resolution fixed"
       		set nrs [ add_to_script  $nrs gmtstring \
			      "\# Create a temporary grid file using the img2grd script" ]
		set line "\$gmtbin/img2grd $raster_data(5) \\\n\t"
		set line "$line \$data_region -T1 -G\$temp_grid_filename -S0.1" 
		set nrs [ add_to_script  $nrs gmtstring $line ]
	    } else { # use the old img2latlongrd
		set nrs [ add_to_script  $nrs gmtstring "\# Create a grid file using img2latlongrd" ]
		set nrs [ add_to_script  $nrs gmtstring \
			      "\$gmtbin/img2latlongrd $raster_data(5)  \\\n\t$raster_inc \$data_region -G\$temp_grid_filename -T1" ]
	    }
	    # uncommment this for the grdcut version where you access a fixed resolution grdfile that has
	    # been produced once and for all
	    #	    
	    #	    set nrs [ add_to_script  $nrs gmtstring "\# Create a grid file using grdcut" ]
	    #	    set nrs [ add_to_script  $nrs gmtstring "\$gmtbin/grdcut $freeair_grav_data $data_region \$verbose -G\$temp_grid_filename" ]

	    # plot the temporary grid file
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose \
			  $legend $papersize(1) $maxmap $scale_unit_string  \
			  "-C\$colormap" 1 contour_para ]

	    # pscoast land coverage 
	    set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for land overlay" ]
	    set line "\$gmtbin/pscoast  $sl  \$region \$projection "
	    set line "$line $resolution_string $natbound_polygons $river_polygons \$portrait  \\\n\t"
	    set nrs [ add_to_script  $nrs gmtstring \
			  "$line -O -K $land_c $pscoast_add \$verbose >> \$ps_filename\n" ]

	}
	"6" { # geoid data from EGM360 geopotential model
            puts "iGMT: EGM360 geoid, resolution  $inc, max is $raster_bounds(6,6) m"
	    version_dependent_strings   "m"  scale_unit_string 
	    set nrs [ create_temp_grid $nrs gmtstring "geoid" \
			  $raster_data(6)  $data_region $resample $inc \
			  $temp_grid_filename $region 1 $raster_bounds(6,6) $raster_resolution ]
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose \
			  $legend $papersize(1) $maxmap $scale_unit_string  "-C\$colormap" 1 \
			  contour_para ]
	} 

	"7" { 	# custom raster data file
	    puts "iGMT: Custom raster data file"
	    puts "iGMT: $raster_data(7)"
	    puts "iGMT: resolution $inc"
	    # create strings for GMT version dependent commands such as psscale with -B option
	    version_dependent_strings   "custom"  scale_unit_string 
	    set nrs [ create_temp_grid $nrs gmtstring "custom raster data" \
			  $raster_data(7)  "" $resample $inc \
			  $temp_grid_filename $region 1 $raster_bounds(7,6) $raster_resolution ]

	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose \
			  $legend $papersize(1) $maxmap $scale_unit_string  "-C\$colormap" 1 \
			  contour_para ]

	    # comment this out if you want land coverage	    
	    # set nrs [ add_to_script  $nrs gmtstring "\# Use pscoast for land coverage 
	    # and features such as national boundaries." ]
	    # set line "$pscoast  $sl  \$region \$projection $resolution_string $natbound_polygons $river_polygons \$portrait  \\\n\t"
	    # set nrs [ add_to_script  $nrs gmtstring "$line -O -K $land_c $pscoast_add \$verbose >> \$ps_filename\n" ]

	}
	"8" { #Laske and Masters (1997) sediment thickness 1 by 1 degree grid
            puts  "iGMT: sediment thickness, resolution  $inc, max is $raster_bounds(8,6) m"
	    set resample 1
            version_dependent_strings   "km"  scale_unit_string
	    set nrs [ create_temp_grid $nrs gmtstring "sediment thickness" \
			  $raster_data(8)  $data_region $resample $inc \
			  $temp_grid_filename $region 1 $raster_bounds(8,6) $raster_resolution ]
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose \
			  $legend $papersize(1) $maxmap $scale_unit_string  "-C\$colormap" 1 \
			  contour_para ]

        }
	"9" { 	# global free-air gravity anomalies from the geopotential model EGM360
            puts "iGMT: EGM360 freeair gravity, resolution  $inc, max is $raster_bounds(9,6) m"
	    # create strings for GMT version dependent commands such as psscale with -B option
	    version_dependent_strings   "mGal"  scale_unit_string 
	    set nrs [ create_temp_grid $nrs gmtstring "freeair gravity from geoid" \
			  $raster_data(9)  $data_region $resample $inc \
			  $temp_grid_filename $region 1 $raster_bounds(9,6) $raster_resolution ]
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose \
			  $legend $papersize(1) $maxmap $scale_unit_string  "-C\$colormap" 1 \
			  contour_para ]
	}
	"10" { # ETOPO5 bathymetry and GSHAP peak ground acceleration
	    #
	    # remember to switch on the temp_shade file line above if you request shading independent
	    # from the $shading option
	    #
	    # create strings for GMT version dependent commands such as psscale with -B option
	    version_dependent_strings   "m/s@+2@+"  scale_unit_string 
	    # check resolution for resampling
	    puts "iGMT: Plotting ETOPO5 and GSHAP PGA, resolution $inc, max is $raster_bounds(10,6) m"
	    # create bathymetry backdrop
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\# Create a temporary grid file from the ETOPO5 data set." ]
	    # adjust the raster resolution for ETOPO5
	    set  tmpinc [ grdraster_adjust $raster_resolution $raster_bounds(2,6) "ETOPO5"  $west $east $south $north ]
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\$gmtbin/grdraster 1 -G\$temp_grid_filename \$verbose \$data_region \$projection  \\\n\t$tmpinc" ]
	    set nrs [ image_temp_grid $nrs gmtstring 1 $verbose 0 $papersize(1) $maxmap\
			  $scale_unit_string  "-C$raster_colormap(11)" 1 \
			  contour_para ]
	    # begin clip path
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\# begin coastline clipping" ]
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\$gmtbin/pscoast \$region \$projection -O -K $resolution_string -Gc >> \$ps_filename\n" ]
	    # plot actual data
	    set nrs [ create_temp_grid $nrs gmtstring "GSHAP peak ground acceleration" \
			  $raster_data(10)  $data_region 1 $inc $temp_grid_filename $region 0 $raster_bounds(10,6) $raster_resolution ]
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose 0 $papersize(1) $maxmap\
			  $scale_unit_string  "-C\$colormap" 0 \
			  contour_para ]
	    # end clip path
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\# end coastline clipping" ]
	    set nrs [ add_to_script  $nrs gmtstring \
			  "\$gmtbin/pscoast \$region \$projection -O -K -Q >> \$ps_filename\n" ]
	    if { $legend } {
		# add a colorbar here, else it would be outside clipping path
		set nrs [ add_to_script  $nrs gmtstring "\# Add a scale beneath the plot." ]
		# change size of font
		set nrs [ add_to_script  $nrs gmtstring "\$gmtbin/gmtset LABEL_FONT_SIZE 9p"]
		set line "\$gmtbin/psscale -C\$colormap -D[ expr $papersize(1)*0.38]/-1.1/[expr $maxmap*0.75]/0.3h"
		set line "$line \\\n\t-B:\"GSHAP Peak Ground Acceleration - 10% probability of exceedance\\\n"
		set line "$line in 50 years (475-years return-period)\":/:\"m/s@+ 2@\":\\\n\t -L"
		set nrs [ add_to_script $nrs gmtstring "$line  \$verbose -O -K  >> \$ps_filename\n"]
		# reset
		if { ($gmt_version == 3.0) || ($gmt_version == 3.1) } {
		    set tmpstring "24" 
		} elseif { $gmt_version == 3.2 } {
		    set tmpstring "16p"
		} else {
		    set tmpstring "24p"
		}
		set nrs [ add_to_script  $nrs gmtstring "\$gmtbin/gmtset LABEL_FONT_SIZE $tmpstring"]
	    }
	}
	"12" { # ETOPO1 topography data from grd file
            puts "iGMT: ETOPO1 topography, resolution  $inc, max is $raster_bounds(12,6) m"
	    version_dependent_strings   "m"  scale_unit_string 
	    set nrs [ create_temp_grid $nrs gmtstring "topo" \
			  $raster_data(12)  $data_region $resample $inc \
			  $temp_grid_filename $region 1 $raster_bounds(12,6) $raster_resolution ]
	    set nrs [ image_temp_grid $nrs gmtstring $shading $verbose \
			  $legend $papersize(1) $maxmap $scale_unit_string  "-C\$colormap" 1 \
			  contour_para ]
	} 


	default { error "Raster dataset $raster_dataset is not implemented!" ; set raster_dataset "1" }
    }
    
    
    if { ($addsomepscoast) && ($wantpscoast) } {
	set nrs [ add_to_script  $nrs gmtstring \
		      "\# Use pscoast for possible features such as national boundaries." ]
	set line "\$gmtbin/pscoast  $sl  \$region \$projection $resolution_string $natbound_polygons $river_polygons \$portrait   \\\n\t"
	set nrs [ add_to_script  $nrs gmtstring "$line -O -K $pscoast_add \$verbose >> \$ps_filename\n" ]
    }

    ################################################################################
    # now the polygon datasets, all optional and "superimposable"
    ################################################################################



    # NUVEL plate boundaries, dataset P1

    if { $polygon_dataset(1)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add NUVEL1 plate boundaries to the plot." ]
	set line "\$gmtbin/psxy $poly_data(1) -: \$verbose \\\n\t"
	set line "$line -m \$region \$projection -O -K  "
	add_linetype_string  line poly_linewidth poly_color 1 
	set line "$line   >> \$ps_filename\n"
	set nrs [ add_to_script  $nrs gmtstring "$line" ] 
    }
    
    # slab contour data, dataset P9
    if { $polygon_dataset(9)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add slab contours to the plot." ]
	set line "\$gmtbin/psxy $poly_data(9)  \$verbose \\\n\t"
	set line "$line -m \$region \$projection -O -K  "
	add_linetype_string  line poly_linewidth poly_color 9
	set line "$line   >> \$ps_filename\n"
	set nrs [ add_to_script  $nrs gmtstring "$line" ] 
    }

    # Steinberger hotspots, P7

    if { $polygon_dataset(7)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add hotspot locations from the Steinberger compilation." ]
	set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\"))printf(\"%g %g\\n\",\$5,\$4)}'"
	set line "$line \\\n\t $poly_data(7) | \\\n\t"
	set line "$line  \$gmtbin/psxy \$verbose \$region \$projection "
	add_scolor_symb_string line poly_color poly_symbol poly_symbol_size maxmap 1 7
	set line "$line -O -K   >> \$ps_filename\n"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
	if { $poly_parameter(7,1) } { # add the name of the hotspot
	    set nrs [ add_to_script  $nrs gmtstring "\# Add name tags for the hotspot locations." ]
	    set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\"))printf(\"%g %g %g %g %g %s %s\\n\",\$5-$tagdist*$maxmap,\$4,11,0,15,\"BR\",\$1)}'"
	    set line "$line \\\n\t $poly_data(7) | \\\n\t"
	    set line "$line \$gmtbin/pstext \$region \$projection"
	    add_scolor_string line poly_color 7 
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	}
    }


    # volcano list from the Smithsonian Institution, P8

    if { $polygon_dataset(8)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add volcano locations from the Smithsonian." ]
	set line "$our_awk '{if((substr(\$1,1,1) != \"#\")&&(\$1!=\"\"))print substr(\$0,61,20)}' $poly_data(8) |\\\n\t"
	set line "$line $our_awk '{la=\$1;lo=\$3;if(\$2==\"S\")la*=-1;if(\$4==\"W\")lo*=-1;print(lo,la)}'|\\\n\t"
	set line "$line $our_awk '{printf(\"%g %g\\n\",\$1,\$2)}' | \\\n\t"
	set line "$line  \$gmtbin/psxy \$verbose \$region \$projection "
	add_scolor_symb_string line poly_color poly_symbol poly_symbol_size maxmap 1 8
	set line "$line -O -K    >> \$ps_filename\n"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
	if { $poly_parameter(8,1) } { # add the name of the volcano
	    set nrs [ add_to_script  $nrs gmtstring "\# Add name tags for the volcano locations." ]
	    set line "$our_awk '{if((substr(\$1,1,1) != \"#\")&&(\$1!=\"\"))print(substr(\$0,61,20),substr(\$0,10,30))}' $poly_data(8) |\\\n\t"
	    set line "$line $our_awk '{la=\$1;lo=\$3;if(\$2==\"S\")la*=-1;if(\$4==\"W\")lo*=-1;print(lo,la,\$5,\$6,\$7,\$8)}'|\\\n\t"
	    set line "$line $our_awk '{print(\$1-0.08*$maxmap,\$2,11,0,15,3,\$3,\$4,\$5,\$6)}'| \\\n\t"
	    set line "$line \$gmtbin/pstext \$region \$projection"
	    add_scolor_string line poly_color 8 
	    set line "$line  -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	}
    }

    
    # CMT solutions, P6

    if { $polygon_dataset(6)  } { 
 	set nrs [ add_to_script  $nrs gmtstring "\# Add CMT solutions in psmeca format to the plot." ]
 	set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\"))print(\$0)}' $poly_data(6) | \\\n\t"
	set line "$line $our_awk '{print(\$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$1,\$2,\$11)}' | \\\n\t"
	set line "$line \$gmtbin/$psmeca \$region \$verbose "
	add_scolor_string line poly_color 6 
 	set line "$line \\\n\t \$projection -O -K -Sc[format %03f [ expr $poly_symbol_size(6)*$maxmap ]]in >> \$ps_filename\n"
 	set nrs [ add_to_script  $nrs gmtstring "$line" ] 
    }
    
    # significant quakes, take only the ones with magnitude assignment, P2
    # need to add rasterpath if data is in grd-data directory!!!

    if { $polygon_dataset(2)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add significant NGDC earthquakes with magnitudes to the plot" ]
	set nrs [ add_to_script  $nrs gmtstring "rasterpath=$rasterpath\n"]
	set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"*\")&&(\$1!=\"\")&&(\$9 != \"0\"))printf(\"%g %g %g\\n\",\$7,\$6,\$9*$poly_symbol_size(2))}'"
	set line "$line \\\n\t $poly_data(2) | \\\n\t"
	set line "$line  \$gmtbin/psxy \$verbose \$region \$projection -O "
	add_scolor_symb_string line poly_color poly_symbol poly_symbol_size  mscale 0 2
	set line "$line -K    >> \$ps_filename\n"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
    }

    # USGS/NEIS PDE catalog quakes above 5, 1973-1998, P3
    # need to add rasterpath if data is in grd-data directory!!!

    if { $polygon_dataset(3)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add significant USGS/NEIC 73-98 >5 " ]
	set nrs [ add_to_script  $nrs gmtstring "rasterpath=$rasterpath\n"]
	set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\"))printf(\"%g %g %g\\n\",\$7,\$6,\$9*$poly_symbol_size(3))}'"
	set line "$line \\\n\t $poly_data(3) | \\\n\t"
	set line "$line  \$gmtbin/psxy \$verbose \$region \$projection  "
	add_scolor_symb_string line poly_color poly_symbol poly_symbol_size  mscale 0 3
	set line "$line  -K -O  >> \$ps_filename\n"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
    }
    
    # first and second custom polygon data sets P4 and P5
    
    foreach i { 4 5 } {
	if { $polygon_dataset($i)  } then { 
	    if { $poly_parameter($i,5) == "" } then { 
		dialog .d {File warning}  "Custom xy filename 1 not defined, skipping this polygon set!"  warning 0 {OK} 
	    } else {
		set nrs [ add_to_script  $nrs gmtstring "\# check if polygon data available" ]
		set nrs [ add_to_script  $nrs gmtstring "if \[ \! -s $poly_parameter($i,5) \];then" ]
		set nrs [ add_to_script  $nrs gmtstring "     echo can not find polygon data file $poly_parameter($i,5)" ]
		set nrs [ add_to_script  $nrs gmtstring "     exit" ]
		set nrs [ add_to_script  $nrs gmtstring "fi" ]
		if { $poly_parameter($i,3) == "" } then { # no size column, use fixed xy data plotting
		    set nrs [ add_to_script  $nrs gmtstring "\# Add custom xy-data from $poly_parameter($i,5) " ]
		    set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\"))print(\$$poly_parameter($i,1),\$$poly_parameter($i,2),5.*$poly_parameter($i,4)*$maxmap*$poly_symbol_size($i))}'" 
		} else { # $custom1(3) column contains sizes
		    set nrs [ add_to_script  $nrs gmtstring "\# Add custom xys-data from $poly_parameter($i,5) " ]
		    set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\"))print(\$$poly_parameter($i,1),\$$poly_parameter($i,2),\$$poly_parameter($i,3)*$poly_parameter($i,4)*$maxmap*$poly_symbol_size($i))}'" 
		} 
		set line "$line \\\n\t $poly_parameter($i,5) | \\\n\t"
		set line "$line  \$gmtbin/psxy \$verbose \$region \$projection -O -K "
		add_scolor_symb_string line poly_color poly_symbol poly_symbol_size  mscale 0 $i
		set line "$line >> \$ps_filename\n"
		set nrs [ add_to_script  $nrs gmtstring "$line" ]
	    }
	}
    }
    
    

    ################################################################################
    #
    # Velocity solutions, P10/P11 using psxy and psvelo. originally by Simone McClusky
    #

    if { $polygon_dataset(10)  } { 
	#
	# first site locations
 	set nrs [ add_to_script  $nrs gmtstring "\# Add station positions in psxy format to the plot." ] 
 	set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\")&&(\$7<=ms)&&(\$8<=ms))print(\$1,\$2,$poly_symbol_size(10)*$maxmap)}' ms=$poly_parameter(10,5) $poly_data(10) |\\\n\t"
	set line "$line \$gmtbin/psxy \$verbose \$region \$projection -O "
	add_linetype_string line poly_linewidth poly_color 10
	set line "$line  -K $poly_symbol(10)   >> \$ps_filename\n" 
 	set nrs [ add_to_script  $nrs gmtstring "$line" ] 
	#
	# now vectors, first set arrow scale
	set astring "-A[format %5.4f/%5.4f/%5.4f [expr $poly_linewidth(10)/100.0] [expr $poly_linewidth(10)/20.0] [expr $poly_linewidth(10)/60.0]]"
	# velocity part of the scaling string
	set sstring "[format %03f [ expr $poly_parameter(10,1)/25.4]]"
	
 	set nrs [ add_to_script  $nrs gmtstring "\# Add Velocity solutions in psvelo format to the plot." ] 
 	set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\")&&(\$7<=ms)&&(\$8<=ms))print(\$1,\$2,\$3,\$4,\$7,\$8,\$9,substr(\$13,1,4))}' ms=$poly_parameter(10,5) $poly_data(10) |\\\n\t"
	set line "$line \$gmtbin/$psvelo \$region \$verbose "
	add_linetype_string line poly_linewidth poly_color 11
	add_scolor_string line poly_color 11
	set line "$line $astring\\\n\t"
 	set line "$line \$projection -O -K -Se[ format %s/%03f/%03i $sstring $poly_parameter(10,3) $poly_parameter(10,4)] -D[format %03f $poly_parameter(10,2)] >> \$ps_filename\n"
 	set nrs [ add_to_script  $nrs gmtstring "$line" ] 

	# legend

 	set nrs [ add_to_script  $nrs gmtstring "\# Add Velocity scale vector to the plot." ]
	if { $poly_parameter(10,6) != 0. } {
	    set line "echo [ expr $east-$span(1)/5.0 ] [ expr $south+$span(2)/12.0 ] 0.0 $poly_parameter(10,6) 0.0 0.0 0.0 $poly_parameter(10,6) mm/yr |\\\n\t"
	    set line "$line \$gmtbin/$psvelo \$region \$verbose \$projection -O -K -Se[format %s/.95/15 $sstring ]" 
	    add_scolor_string line poly_color 11
	    set line "$line $astring >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	}
    }
    
    # City names, P12/P13

    if { $polygon_dataset(12)  } { 
	set nrs [ add_to_script  $nrs gmtstring "\# Add city locations and names" ]
	set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\"))printf(\"%g %g\\n\",\$1,\$2)}'"
	set city_code [ expr 12 + $poly_parameter(12,1) ]
	set line "$line \\\n\t $poly_data($city_code) | \\\n\t"
	set line "$line  \$gmtbin/psxy \$verbose \$region \$projection -O -K"

	add_scolor_symb_string line poly_color poly_symbol poly_symbol_size  mscale 1 12
	set line "$line   >> \$ps_filename\n"
	set nrs [ add_to_script  $nrs gmtstring "$line" ]
	if { $poly_parameter(12,2) } { # add the name of the city
	    set nrs [ add_to_script  $nrs gmtstring "\# Add name tags for the city locations." ]
	    set line "$our_awk '{if((substr(\$1,1,1)!=\"\#\")&&(\$1!=\"\"))printf(\"%g %g %g %g %g %s %s\\n\",\$1-$tagdist*$maxmap,\$2,11,0,15,\"BR\",\$3)}'"
	    set line "$line \\\n\t  $poly_data($city_code) | \\\n\t"
	    set line "$line \$gmtbin/pstext \$region \$projection"
	    add_scolor_string line poly_color 12
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	}
    }
    
    # World Stress Map data, P15/16/17/18

    if { $polygon_dataset(15)  } { 
	# set colors and type selection string
	foreach i { 1 2 3 4 } {
	    set j [ expr 14 + $i ]
	    set wsm_color_string($i) \
		"[format %03i/%03i/%03i $poly_color($j,1) $poly_color($j,2) $poly_color($j,3)]"
	}
	set scr_tp_str "t1=$poly_parameter(15,1) t2=$poly_parameter(15,2) t3=$poly_parameter(15,3) t4=$poly_parameter(15,4) t5=$poly_parameter(15,5)"
	
	# plot different vectors for extension and compressional mechanism derived data
	if { $poly_parameter(15,7) == 1 } { 
	    set wsm_veclen [  expr $maxmap*$poly_symbol_size(15)*0.7 ]
	    
	    set nrs [ add_to_script  $nrs gmtstring "\# Add WSM data points" ]
	    set nrs [ add_to_script  $nrs gmtstring "\# extensional (maybe with some strike slip component)" ]
	    set line "$our_awk -f $igmt_root/sortwsm.awk pregime=1 pquality=$poly_parameter(15,6)"
	    set line "$line \\\n\t  $scr_tp_str \$wsm_data | \\\n\t"
	    set line "$line \$gmtbin/$psvelo \$region \$projection \$verbose "
	    set line "$line -W$poly_linewidth(15)/$wsm_color_string(1) [ format -Sx%f $wsm_veclen] "
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	    
	    set nrs [ add_to_script  $nrs gmtstring "\# pure strike slip" ]
	    set line "$our_awk -f $igmt_root/sortwsm.awk pregime=2 pquality=$poly_parameter(15,6)"
	    set line "$line \\\n\t  $scr_tp_str \$wsm_data  | \\\n\t"
	    set line "$line \$gmtbin/$psvelo \$region \$projection \$verbose "
	    set line "$line -W$poly_linewidth(15)/$wsm_color_string(2) [ format -Sx%f $wsm_veclen] "
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	    
	    set nrs [ add_to_script  $nrs gmtstring "\# compressional (maybe with strike slip component)" ]
	    set line "$our_awk -f $igmt_root/sortwsm.awk pregime=3 pquality=$poly_parameter(15,6) "
	    set line "$line \\\n\t  $scr_tp_str \$wsm_data  | \\\n\t"
	    set line "$line \$gmtbin/$psvelo \$region \$projection \$verbose "
	    set line "$line -W$poly_linewidth(15)/$wsm_color_string(3) [ format -Sx%f $wsm_veclen] "
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	    
	    set nrs [ add_to_script  $nrs gmtstring "\# undetermined " ]
	    set line "$our_awk -f $igmt_root/sortwsm.awk pregime=4 pquality=$poly_parameter(15,6) "
	    set line "$line \\\n\t  $scr_tp_str \$wsm_data | \\\n\t"
	    set line "$line \$gmtbin/$psvelo \$region \$projection \$verbose "
	    set line "$line -W$poly_linewidth(15)/$wsm_color_string(4) [ format -Sx%f $wsm_veclen] "
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]

	} else  { # plot single line along compressional axis
	    set wsm_veclen [  expr $maxmap*$poly_symbol_size(15)*0.5 ]
	    set wsm_vec_with [ expr 0.02*$poly_linewidth(15)/0.5 ]
	    set nrs [ add_to_script  $nrs gmtstring "\# Add WSM data points" ]

	    set nrs [ add_to_script  $nrs gmtstring "\# extensional (maybe with some strike slip component)" ]
	    set line "$our_awk -f $igmt_root/sortwsm.awk pregime=1 pquality=$poly_parameter(15,6) "
	    set line "$line \\\n\t $scr_tp_str  \$wsm_data | \\\n\t"
	    set line "$line $our_awk '{printf(\"%g %g %g %g\\n%g %g %g %g\\n\",\$1,\$2,\$5,f,\$1,\$2,\$5+180,f);}' f=$wsm_veclen | \\\n\t"
	    set line "$line \$gmtbin/psxy \$region \$projection \$verbose -SV$wsm_vec_with/0./0. "
	    set line "$line -G$wsm_color_string(1)"
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]

	    
	    set nrs [ add_to_script  $nrs gmtstring "\# strike slip" ]
	    set line "$our_awk -f $igmt_root/sortwsm.awk pregime=2 pquality=$poly_parameter(15,6) "
	    set line "$line \\\n\t $scr_tp_str  \$wsm_data | \\\n\t"
	    set line "$line $our_awk '{printf(\"%g %g %g %g\\n%g %g %g %g\\n\",\$1,\$2,\$5,f,\$1,\$2,\$5+180,f);}' f=$wsm_veclen | \\\n\t"
	    set line "$line \$gmtbin/psxy \$region \$projection \$verbose -SV$wsm_vec_with/0./0. "
	    set line "$line -G$wsm_color_string(2)"
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	    

	    set nrs [ add_to_script  $nrs gmtstring "\# compressional (with strike-slip)" ]
	    set line "$our_awk -f $igmt_root/sortwsm.awk pregime=3 pquality=$poly_parameter(15,6) "
	    set line "$line \\\n\t $scr_tp_str  \$wsm_data | \\\n\t"
	    set line "$line $our_awk '{printf(\"%g %g %g %g\\n%g %g %g %g\\n\",\$1,\$2,\$5,f,\$1,\$2,\$5+180,f);}' f=$wsm_veclen | \\\n\t"
	    set line "$line \$gmtbin/psxy \$region \$projection \$verbose -SV$wsm_vec_with/0./0. "
	    set line "$line -G$wsm_color_string(3)"
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]
	    
	    set nrs [ add_to_script  $nrs gmtstring "\# undetermined" ]
	    set line "$our_awk -f $igmt_root/sortwsm.awk pregime=4 pquality=$poly_parameter(15,6) "
	    set line "$line \\\n\t $scr_tp_str  \$wsm_data | \\\n\t"
	    set line "$line $our_awk '{printf(\"%g %g %g %g\\n%g %g %g %g\\n\",\$1,\$2,\$5,f,\$1,\$2,\$5+180,f);}' f=$wsm_veclen | \\\n\t"
	    set line "$line \$gmtbin/psxy \$region \$projection \$verbose -SV$wsm_vec_with/0./0. "
	    set line "$line -G$wsm_color_string(4)"
	    set line "$line -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring "$line" ]


	}
    }
    # 
    # P19/20: plotting of vector fields given as grid files
    # 
    if { $polygon_dataset(19)  } { 
	# make sure field and reference vectors have same color
	foreach i { 1 2 3 } { 
	    set poly_color(20,$i) $poly_color(19,$i)
	}
	puts "iGMT: plotting vector field based on $poly_data(19) and"
	puts "iGMT: $poly_data(20)"
	set tmpvecsize "[format %g/%g/%g [ expr 0.03*$poly_linewidth(19) ] [ expr 0.06*$poly_linewidth(19) ] [ expr 0.045*$poly_linewidth(19) ]]"
	set nrs [ add_to_script  $nrs gmtstring "\# add vector field" ]
	set nrs [ add_to_script  $nrs gmtstring  "vecsize=$tmpvecsize" ]
	set nrs [ add_to_script  $nrs gmtstring  "velscale=$poly_parameter(19,1)\n" ]
	
	set line "\$gmtbin/grdvector $poly_data(19)\\\n\t$poly_data(20)\\\n\t"
	set line "$line -T \$region \$projection \$verbose\\\n\t"
	set line "$line -I$poly_parameter(19,4) -S\$velscale -Q\$vecsize\\\n\t"
	add_scolor_string line poly_color 19
	set line "$line  -O -K >> \$ps_filename\n"
	set nrs [ add_to_script  $nrs gmtstring $line ]
	if { $poly_parameter(19,5) } {
	    set nrs [ add_to_script  $nrs gmtstring "\# add reference vector" ]
	    set tmpstring "\"$poly_parameter(19,2) $poly_parameter(19,3)\""
	    set line "echo [ expr $west + 0.15*$span(1) ] [ expr $south + 0.08*$span(2) ] "
	    set line "$line $poly_parameter(19,2) 0 0 0 0 $tmpstring | \\\n\t"
	    set line "$line\$gmtbin/$psvelo -A\$vecsize -Se`echo \$velscale | gawk '{print(1/\$1)}'`/0.95/14"
	    add_linetype_string  line poly_linewidth poly_color 20
	    add_scolor_string line poly_color 20
	    set line "$line  \$region \\\n\t\$projection \$verbose -N -O -K >> \$ps_filename\n"
	    set nrs [ add_to_script  $nrs gmtstring $line ]
	}

    }
    
    ################################################################################
    # End of polygon data


    # possible extra title item
    # uncomment this for an attempt to plot the plot_title using pstext instead of the -B version below
    # title location is some percent of vertical plot size above northern boundary

    if { ($use_pstext_for_title) && ($plot_title != "") } {
	set line "echo  [ expr $mean(1)*1.02 ]  [ expr $north+0.07*$span(2)] $title_font_size 0 $title_font  6 \"$plot_title\" | "
	set line "$line $pstext \$region \$projection "
	set nrs [ add_to_script  $nrs gmtstring "$line  -N -O -K >> \$ps_filename\n" ]
    } 
    
    
    
    ################################################################################
    # add a frame for the map using psbasemap and complete the plot
    #

    set nrs [ add_to_script  $nrs gmtstring "\# Use psbasemap for basic map layout, possible title"]
    set nrs [ add_to_script  $nrs gmtstring "\#     and complete the plot"]
    set line "\$gmtbin/psbasemap  \$region \$verbose \$projection \\\n\t  $frame_box \\\n\t"
    #    if { $show_gmt_logo } { set line "$line -U\"iGMT $igmt_version\"" }
    if { $show_gmt_logo } { set line "$line -U/0.0/-0.47/\"iGMT $igmt_version\"" }
    if { $mapscale } { 
	set nrs [ add_to_script  $nrs gmtstring "\#     map-scale is correct at mid latitude"]
	if { $mapscale == 2 } { # fancy
	    set line "$line -Lfx1.1/0.4/$mean(2)/[ format %05.0f $mscale]"
	} else { # plain
	    set line "$line -Lx1.1/0.4/$mean(2)/[ format %05.0f $mscale]"

	}
    }
    set nrs [ add_to_script  $nrs gmtstring "$line -O $pscoast_add  >> \$ps_filename\n" ]

    if { $raster_dataset != 1 } {
	################################################################################
	# add a commented out line that would delete the temporary files
	# iGMT needs these temporary files to operate on them when creating, eg., a new
	# colormap
	#
	set nrs [ add_to_script  $nrs gmtstring "\# comment out (remove the \#) the line after next to delete temporary files after script execution"]
	set nrs [ add_to_script  $nrs gmtstring "\# remove temporary files" ]
	set filestring "\$temp_grid_filename \$temp_shade_filename"
	if { $contour_para(1) } { set filestring "$filestring \$temp_cont_int_filename" }
	set nrs [ add_to_script  $nrs gmtstring "\#rm -f  $filestring 2> /dev/null" ]
    }

    set nrs [ add_to_script  $nrs gmtstring "\$gmtbin/psconvert -Te -A+m0.1 \$ps_filename -Ftmp.$$ ; mv tmp.$$.eps \$ps_filename\n"]
    set nrs [ add_to_script  $nrs gmtstring "\$gmtbin/gmtset PAPER_MEDIA \$old_psize\n"]
    
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
    
    
    # show a kill panel
    
    set headermessage "iGMT: Running the script..."
    update idletasks
    set retval 1
    # obtain top level geometry
    set w_x_pos [expr [ winfo x . ] + 100 ]
    set w_y_pos [expr [ winfo y . ] + 50 ]
    toplevel .panel 
    wm title .panel "Script control..." 
    wm geometry .panel +$w_x_pos+$w_y_pos
    # deal with batch aborts
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

    # set the file_pointer to the piped batchfile command

    if { [ catch  [  list set file_pipe [open "| $batchfile 2> $batcherr" r] ] ] } {
	error "While trying to execute $batchfile. Make sure that the file exists and is executable (usually checked by the iGMT start-up sequence). If you want to recreate the file, type \"touch $batchfile\" and \"chmod +x $batchfile\" in a shell window. Quitting and restarting might be a better idea."
	sad_return
	set retval 0
    } 
    set batch_pid [pid $file_pipe]
    fileevent $file_pipe readable "happy_return"
    label .panel.label -text "Now running the GMT script\n$batchfile.\nThis might take a while. If errors occur or raster data sets look strange,\n check the stderr output (under menu item \"Scripting option\") first.\nInterrupt the background job with the \"CANCEL\" button below.\n\n"
    button .panel.kill -text "CANCEL" -relief groove -command { 
	# try to kill child processes first
	catch { exec ps -f | grep $batch_pid | $our_awk "{printf(\"%i \",\$2)}" } tmp_var 
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
# convert the postscript file to be able to display it, 
# only GIF is supported so far
################################################################################

proc conv_ps {} {
    global gif_filename ps_filename headermessage portrait ps_to_gif_command_landscape\
	ps_to_gif_command_portrait no_convert_complaints

    set headermessage "iGMT: Converting $ps_filename to $gif_filename..."

    update idletasks 
    if { $portrait == 0 } { 
	set command_string "exec $ps_to_gif_command_landscape"
    } else {
	set command_string "exec $ps_to_gif_command_portrait" 
    }	

    catch {  eval $command_string  } output 

    if { $no_convert_complaints  } {
	set headermessage "iGMT: Converting probably done."
    } else {
	if { $output != "" } {
	    dialog .d {PS to GIF conversion error...} \
		"PS to GIF conversion might have failed, the error message was\n$output\nLikely causes are:\na) the conversion program can not be found by iGMT (wrong path),\nb) the script file did not produce proper postscript output, or,\nc) the temporary GIF file that iGMT tries to write ($gif_filename)\ncan not be created.\nYou might still be able to use iGMT by only creating Postscript output."  warning 0 {OK}
	    puts $output
	    set headermessage "iGMT: PS to GIF conversion failed."
        } else {
	    set headermessage "iGMT: Converting done."
        }
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


################################################################################
# procedure to plot the temporary grid file
#
# using grdimage and the like
#
################################################################################
proc image_temp_grid { nrstr array shading verbose legend papersize1 maxmap \
			   scale_unit_string colormap start_plot cp } {
    upvar $array ar 
    upvar $cp contour_para
    global gmtbins  igmt_root our_awk
    #
    # if contour_para(1) is not set to 2 (solely contour lines) add grdimage type
    # plot 
    #
    if { ($shading) && ($contour_para(1) != 2) } { # gradient shading for relief is on
	set nrstr [ add_to_script  $nrstr ar "\# Create a shade file." ]
	set nrstr [ add_to_script  $nrstr ar "\$gmtbin/grdgradient \$temp_grid_filename -A65 $verbose -G\$temp_shade_filename -Nt" ]
	#
	set nrstr [ add_to_script  $nrstr ar "\# Use grdimage to create a raster map." ]
	set line "\$gmtbin/grdimage \$temp_grid_filename \$region \$projection \\\n\t$colormap \\\n\t-I\$temp_shade_filename \\\n\t"
	if { $start_plot } {
	    set nrstr [ add_to_script  $nrstr ar  "$line \$verbose \$portrait  -K \$offsets > \$ps_filename\n" ]
	} else {
	    set nrstr [ add_to_script  $nrstr ar  "$line \$verbose \$portrait  -K -O >> \$ps_filename\n" ]
	}
	if { $legend  } { # add a colorbar
	    set nrstr [ add_to_script  $nrstr ar "\# Add a scale beneath the plot." ]
	    set line "\$gmtbin/psscale $colormap -D[ expr $papersize1*0.38]/-1.1/[expr $maxmap*0.75]/0.3h"
	    set line "$line $scale_unit_string \\\n\t -L -I\$temp_shade_filename"
	    set nrstr [ add_to_script $nrstr ar "$line  \$verbose -O -K  >> \$ps_filename\n"]
	}
    } elseif { $contour_para(1) != 2 } { # flat representation as in defaults
	set nrstr [ add_to_script  $nrstr ar "\# Use grdimage to create a raster map." ]
	set line "\$gmtbin/grdimage \$temp_grid_filename \$region \$projection \\\n\t$colormap  \\\n\t\$verbose "
	if { $start_plot } {
	    set nrstr [ add_to_script  $nrstr ar  "$line \$portrait  \$offsets -K > \$ps_filename\n" ]
	} else {
	    set nrstr [ add_to_script  $nrstr ar  "$line \$portrait   -K -O >> \$ps_filename\n" ]
	}
	if { $legend  } { # add a colorbar
	    set nrstr [ add_to_script  $nrstr ar "\# Add a scale beneath the plot." ]
	    set line "\$gmtbin/psscale $colormap \\\n\t-D[ expr $papersize1*0.38]/-1.1/[expr $maxmap*0.75]/0.3h"
	    set line "$line $scale_unit_string \\\n\t -L"
	    set nrstr [ add_to_script $nrstr ar "$line  \$verbose -O -K  >> \$ps_filename\n"]
	}
    }
    if { $contour_para(1) != 0 } { # add a contour plot
	# color
	set ccol   "[ format %03i/%03i/%03i $contour_para(3,1) $contour_para(3,2) $contour_para(3,3)]"
	# linewidths
	set wa [ format "-Wa%0g/%s" [ expr $contour_para(2)*2 ] $ccol ]
	set wc [ format "-Wc%0g/%s" [ expr $contour_para(2)   ] $ccol ]
	# annotation
	if { $contour_para(5) == "-" } { set cann "-A-" ; set ae -1 } else { set cann [ format "-Af%i" $contour_para(5) ] ; set ae 2}
	# make contour interval file
	set nrstr [ add_to_script  $nrstr ar "\# produce contour interval file for grdcontour" ]
	set nrstr [ add_to_script  $nrstr ar "$igmt_root/igmt_helper_create_ci_file \$temp_grid_filename $contour_para(4) \$gmtbin  $our_awk $ae > \$temp_cont_int_filename" ]
	if { $contour_para(1) == 1 } { 
	    # call grdcontour for overlay plot
	    set nrstr [ add_to_script  $nrstr ar "\# Use grdcontour to overlay contour lines" ]
	    set nrstr [ add_to_script  $nrstr ar "\$gmtbin/grdcontour $cann -C\$temp_cont_int_filename \$temp_grid_filename \\" ]
	    set nrstr [ add_to_script  $nrstr ar "\t\$region \$projection -O -K -S2 $verbose $wa $wc >> \$ps_filename\n" ]
	} else { # begin plot with grdcontour
	    set nrstr [ add_to_script  $nrstr ar "\# Use grdcontour to start plot with contour lines" ]
	    set nrstr [ add_to_script  $nrstr ar "\$gmtbin/grdcontour $cann -C\$temp_cont_int_filename \$temp_grid_filename \\" ]
	    set nrstr [ add_to_script  $nrstr ar "\t\$region \$projection -K -S2 $verbose $wa $wc \$portrait > \$ps_filename\n" ]
	}
    }
    return $nrstr
}

################################################################################
# procedure to add a line to the script string

proc add_to_script { nrstr array string } {
    upvar $array ar 
    set ar($nrstr) $string
    incr nrstr
    return $nrstr
}
################################################################################
# procedure for adding a beautiful line with 80 dashes to the script
proc draw_script_line { nrstr array } {
    upvar $array ar 
    set a "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#"
    set ar($nrstr) [ format "%s%s%s%s" $a $a $a $a ]
    incr nrstr
    return $nrstr
}

################################################################################    
# produce strings called by the plotting routines 
# that GMT versions 3.0 and 3.x handle differently

proc version_dependent_strings { unit b_string } {
    upvar $b_string s
    global gmt_version
    
    # string for the units next to the psscale scale
    if { $gmt_version == 3.0 } {
	set s "-B:\"$unit\":" 
    } else {
	set s "-B/:\"$unit\":" 
    }
}


################################################################################
#
# create temporary grid files for plotting
#

proc create_temp_grid {  nrstr array data_decription_string data \
			     limit_region resample spacing temp_grid_filename region \
			     use_data_region min_res_in_minutes res_in_minutes } {
    upvar $array ar 
    global gmtbins our_awk
    
    set nrstr [ add_to_script  $nrstr ar "\# Plotting $data_decription_string" ]
    if { $resample } { 
	#
	# possible resampling
	#
	set line "res_in_min=\`echo \$raster_inc | $our_awk '{r=substr(\$1,3);\\\n\tif(substr(r,length(r),1)==\"m\")r=substr(r,1,length(r)-1);else r=r*60.;print(r)}'\`"
	set nrstr [ add_to_script  $nrstr ar "\n\# determine the resolution in minutes and compare it with the minimum resolution of the dataset" ]
	set nrstr [ add_to_script  $nrstr ar $line ]
	set nrstr [ add_to_script  $nrstr ar "min_res_in_min=$min_res_in_minutes\n" ]
	set line "if \[ \`echo \$min_res_in_min \$res_in_min | $our_awk '{if(\$1 != \$2)print(1);else print(0);}'\` -eq 1 \];then"
	set nrstr [ add_to_script  $nrstr ar  $line ]
	set nrstr [ add_to_script  $nrstr ar "\t\# resolution different from minimum, need to resample" ]
	set line "\tif \[ \`echo \$min_res_in_min \$res_in_min | $our_awk '{if(\$1 < \$2)print(1);else print(0);}'\` -eq 1 \];then" 
	set nrstr [ add_to_script  $nrstr ar $line ]
	set nrstr [ add_to_script  $nrstr ar "\t\techo \$0: WARNING: resolution is reduced, possible aliasing 2> /dev/null" ]
	set nrstr [ add_to_script  $nrstr ar "\tfi" ]
	if { $use_data_region } {
	    set nrstr [ add_to_script  $nrstr ar "\t\$gmtbin/grdsample $data \\\n\t\t\$data_region \$raster_inc \$verbose -G\$temp_grid_filename\n" ]
	} else {
	    set nrstr [ add_to_script  $nrstr ar "\t\$gmtbin/grdsample $data \\\n\t\t\$region \$raster_inc \$verbose -G\$temp_grid_filename\n" ]
	}
	set nrstr [ add_to_script  $nrstr ar "else" ]
	set nrstr [ add_to_script  $nrstr ar "\t\# \$raster_inc is same as minimum resolution of \$min_res_in_deg, hence use  grdcut" ]
	if { $use_data_region } {
	    set nrstr [ add_to_script  $nrstr ar "\t\$gmtbin/grdcut $data \\\n\t\t\$data_region \$verbose -G\$temp_grid_filename\n" ]
	} else {
	    set nrstr [ add_to_script  $nrstr ar "\t\$gmtbin/grdcut $data \\\n\t\t\$region  \$verbose -G\$temp_grid_filename\n" ]
	}
	set nrstr [ add_to_script  $nrstr ar "fi\n" ]
	if { $min_res_in_minutes != $res_in_minutes } {
	    puts "iGMT: setting the resolution (now $res_in_minutes m) to the minimum ($min_res_in_minutes m) could speed up the script"
	}
	if { $min_res_in_minutes < $res_in_minutes } {
	    puts "iGMT: WARNING: at this raster resolution ($res_in_minutes m versus minimum of $min_res_in_minutes m)"
	    puts "iGMT: the script will use grdsample to coarsen the resolution, which might lead to aliasing"
	}
    } else {
	# 
	# no resampling
	#
	set nrstr [ add_to_script  $nrstr ar "\# Create a temporary grid file using grdcut" ]
	if { $use_data_region } {
	    set nrstr [ add_to_script  $nrstr ar "\$gmtbin/grdcut $data \\\n\t\$data_region \$verbose -G\$temp_grid_filename\\\n" ]
	} else {
	    set nrstr [ add_to_script  $nrstr ar "\$gmtbin/grdcut $data \\\n\t\$region \$verbose -G\$temp_grid_filename\\\n" ]
	}
    }
    return $nrstr
}

################################################################################
# procedures to produce string with polygone linewidth and color specifications
# or symbol fill colors
proc add_linetype_string { ref_line pl pc i } {
    upvar $ref_line line
    upvar $pl poly_linewidth
    upvar $pc poly_color
    set line "$line -W$poly_linewidth($i)p/[format %03i/%03i/%03i $poly_color($i,1) $poly_color($i,2) $poly_color($i,3)]"
}
#
# add a string with a fill color specification 
proc add_scolor_string { ref_line pc i } {
    upvar $ref_line line
    upvar $pc poly_color
    set line "$line -G[format %03i/%03i/%03i $poly_color($i,1) $poly_color($i,2) $poly_color($i,3)]"
}
#
# add a string with a fill color specification if symbols are chose
# or line color of lines are chosen
#
proc add_scolor_symb_string { ref_line pc ps pss ms use_fix_size i } {
    upvar $ref_line line
    upvar $pc poly_color
    upvar $ps poly_symbol
    upvar $pss poly_symbol_size
    upvar $ms mscale
    if { [ string range $poly_symbol($i) 0 1 ] == "-S" } {
	#
	# this is a symbol string
	#
	set line "$line -G[format %03i/%03i/%03i $poly_color($i,1) $poly_color($i,2) $poly_color($i,3)]"
	if { $use_fix_size == 1 } { # use a fixed symbol size
	    set line "$line $poly_symbol($i)[ format %g [ expr $poly_symbol_size($i) ]]i"
	} else { # read in from third column
	    set line "$line $poly_symbol($i)"
	}
    } else {
	#
	# this is a linewidth
	#
	set lw [ format %0i [ expr int($poly_symbol_size($i)/0.05) ] ]p
	if { $poly_symbol($i) == "-Lo" } { # non-filled lines
	    set line "$line -W$lw/[format %03i/%03i/%03i $poly_color($i,1) $poly_color($i,2) $poly_color($i,3)] -m"
	} elseif {  $poly_symbol($i) == "-Lc" } {
	    set line "$line -G[format %03i/%03i/%03i $poly_color($i,1) $poly_color($i,2) $poly_color($i,3)] -L -m"
	}
    }
}
