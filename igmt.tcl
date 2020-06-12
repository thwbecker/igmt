#
# igmt.tcl -- main procedure
#
# part of the iGMT package
#
# $Id: igmt.tcl,v 1.8 2004/03/23 17:41:10 becker Exp becker $ 
#
################################################################################
#
#                                  iGMT, version 1.2
#
# graphical user interface for the GMT tools
# interface to various datasets 
#
# documentation in manual.ps
#
# modify variables such as path names in igmt_configure.tcl
#
#
# Thorsten Becker, Alexander Braun
#
################################################################################

# load the default settings and all the global variables
source "$env(igmt_root)/igmt_configure.tcl"

# source some site specific settings that may overwrite the defaults in a
# igmt_configure (so igmt_configure needn't be changed, if the file is not
# there, ignore the error message)

if { [catch { source "$env(igmt_root)/igmt_siteconfig.tcl" } ] == 0 } { 
    puts "iGMT: read igmt_siteconfig.tcl for local settings"
}


# adjust binaries to GMT version setting

if { $gmt_version >= $gmt_version_boundary } {
    set gmtbins $higher_version_gmtbins
} else {
    set gmtbins $lower_version_gmtbins
}








# check the availability of at least one GMT command

if { [catch "[ list exec [ format %sgmtdefaults $gmtbins ] -D > /dev/null ]" var ] } {
    puts $var
    puts "iGMT: Can't execute \"[ format %sgmtdefaults $gmtbins ]\" !"
    puts "iGMT: The GMT commands are probably in the wrong place"
    puts "iGMT: or not in your path."
    puts "iGMT: Modify $igmt_root/igmt_configure.tcl, "
    puts "iGMT: $igmt_root/igmt_siteconfig.tcl or your \$path variable."
    puts "iGMT: Also, make sure that the GMTHOME environment variable "
    puts "iGMT: is set to the correct location."
    exit -1 
} 
#
# check for img2grd
#
if { [ catch "[ list exec $shell_to_use -c "type $gmtbins/img2grd" ]" var ] } {
    puts "iGMT: error:"
    puts $var
    puts "iGMT: Can't find \"[ format %simg2grd $gmtbins ]\" !"
    puts "iGMT: "
    puts "iGMT: Did you or your sysadmin remember to install the GMT img2grd tools?"
    puts "iGMT: Those are needed to process certain raster datasets,"
    puts "iGMT: iGMT will still work, but some datasets won't."
} 
#
# check for psvelo
#
if { [ catch "[ list exec $shell_to_use -c "type $gmtbins/psvelo" ]" var ] } {
    puts "iGMT: error"
    puts $var
    puts "iGMT: Can't find \"[ format %spsvelo $gmtbins ]\" !"
    puts "iGMT: "
    puts "iGMT: Did you or your sysadmin remember to install the GMT meca tools?"
    puts "iGMT: Those are needed to plot CMT solutions and GPS velocities,"
    puts "iGMT: iGMT will still work, but some datasets won't."
} 




#  if gmtbins is not set, request the general path
if { $gmtbins == "" } {
    if { [ catch "[ list exec $shell_to_use -c "type gmtdefaults" ]" gmtbins ] } {
	# could not automatically determine the binary location
	puts "iGMT: Could not determine the pathname of the GMT binaries."
	puts "iGMT: Please find out where binaries such as pscoast reside"
	puts "iGMT: (type \"which pscoast\" for example) and add a line like"
	puts "iGMT: set gmtbins /the/directory/of/GMT/bin/"
	puts "iGMT: to your igmt_siteconfig.tcl file. Then restart."
	exit -1
    }
    set gmtbins [ string range $gmtbins 0 [ expr [ string length $gmtbins ] - 13 ]  ]
}

set convert_availability [catch "[ list exec $shell_to_use -c "type $ps_to_gif_converter" ] " tmp_var ]
if { ( $convert_availability ) || ( [ string range $tmp_var  0 1 ] == "no") } {
    puts "iGMT: Couldn't check the path to the default converter,"
    puts "iGMT: \"$ps_to_gif_converter\". This means that you are probably now"
    puts "iGMT: restricted to the postscript features."

}

# igmt version number

set igmt_version 1.2


#global frame starts here
wm title . "iGMT version $igmt_version"


# source modified Tcl/Tk colorpicking routines, not working yet
# source "$env(igmt_root)/igmt_clrpick.tcl"

# load various input/output routines 
source "$env(igmt_root)/igmt_iomisc.tcl"

# call the init routine
source "$env(igmt_root)/igmt_init.tcl"   
     
# set up the menu bar with sub menus
source "$env(igmt_root)/igmt_menus.tcl"       

# load the plotting related routines
source "$env(igmt_root)/igmt_plotting.tcl"

# load the dialogs related to changing parameters
source "$env(igmt_root)/igmt_parameters.tcl"

# load the dialogs related to dataset selection
source "$env(igmt_root)/igmt_datasets.tcl"


################################################################################
# title line

label .msg -textvariable headermessage
.msg config -bg PeachPuff1
pack .msg -fill x
pack .msg .mb -side top -fill x





################################################################################
# check the availability of data files
#
if { $check_for_raster_availability } {
    set files_unavailable ""
    puts "iGMT: checking raster file availability"
    for { set i 1 } { $i <= $nr_of_raster_data } { incr i } { 
	if { $raster_data($i)  != -1 } {
	    set filename $raster_data($i)
	    set filename [ eval [ puts $filename ]]
	    if { [ catch { exec test -r $filename } ] } { 
		set files_unavailable "$files_unavailable\n$filename\n" 
	    }
	}
    }
    puts "iGMT: raster file check done"
    if { [ string trim $files_unavailable ] != "" } {
	dialog .d {Missing data sets...} \
	    "The following data sets are unavailable:\n\n$files_unavailable\n\nThis means that some of the data handling routines will not work.\nAdd the correct filenames to your igmt_siteconfig.tcl file and look\nin igmt_configure.tcl for the default names.\nIf you want to get rid of this message, set \"check_for_raster_availability\" to 0\nin your igmt_siteconfig.tcl file.\n"  warning 0 {OK} 
    }
    
}


################################################################################
# display the map in the lower part as a GIF image

# copy the default image to fill the frame the first time if there is
# no temporary file around

exec $igmt_root/igmt_helper_checkfile $gif_filename $def_gif_filename

image create photo map_image -file $gif_filename
label .mapimage -image  map_image  -bd 1 -relief sunken
pack .mapimage
pack .mb .mapimage -fill x -fill y -side top



puts "iGMT: Initialized in GMT $gmt_version mode."
#puts "iGMT: If quitting iGMT doesn't seem to get you back to the" 
#puts "iGMT: command line, hit \"RETURN\" in this shell window."

