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
# igmt_iomisc.tcl -- input, output and miscelleanous procedures
#
# part of the iGMT package
#
################################################################################


################################################################################
# generic dialog procedure from 
# "Tcl and the Tk toolkit" by J. K. Ousterhout
#

proc dialog { w title text bitmap default args} {
    global button
 
# create top-level window and divide it into two parts 

    toplevel $w -class Dialog
    wm title $w $title
    wm iconname $w Dialog

    frame $w.top -relief raised -bd 1
    pack $w.top -side top -fill both

    frame $w.bot -relief raised -bd 1
    pack $w.bot  -side bottom -fill both


# fill the top with the bitmap and the message
    
    message $w.top.msg -width 3i -text $text
    pack $w.top.msg -side right -expand 1 -fill both\
	-padx 3m -pady 3m
    if {$bitmap != ""} {
	label $w.top.bitmap -bitmap $bitmap 
	pack $w.top.bitmap -side left -padx 3m -pady 3m
    }

# create the bottom row buttons

    set i 0
    foreach but $args {
	button $w.bot.button$i -text $but -command\
	    "set button $i"
	if {$i == $default} {
	    frame $w.bot.default -relief sunken -bd 1
	    raise $w.bot.button$i
	    pack $w.bot.default -side left -expand 1 \
		-padx 3m -pady 3m
	    pack $w.bot.button$i -in $w.bot.default\
		-side left -padx 2m -pady 2m\
		-ipadx 2m -ipady 1m
	} else {
	    pack $w.bot.button$i -side left -expand 1\
		-padx 3m -pady 3m -ipadx 2m -ipady 1m
	}
	incr i
    }


    if { $default >= 0} {
	bind $w <Return> "$w.bot.button$default flash;\
                          set button $default"
    }
    set oldFocus [focus]
    grab set $w
    focus $w
    
    tkwait variable button
    destroy $w
    focus $oldFocus
    return $button
}


################################################################################
# procedure used to display man pages

proc show_man_page { command_to_show parent } {
    global igmt_root
    set w $parent.$command_to_show
    catch {destroy $w}
    toplevel $w
    wm title $w "Man page viewer for $command_to_show"
    wm iconname $w "style"
    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.dismiss -text Dismiss -command "destroy $w"
    pack $w.buttons.dismiss  -side left -expand 1
    text $w.text -yscrollcommand "$w.scroll set" -setgrid true \
	-width 80 -height 32 -wrap word
    scrollbar $w.scroll -command "$w.text yview"
    pack $w.scroll -side right -fill y
    pack $w.text -expand yes -fill both
    
    # create a temporary text file containing the man page

    exec $igmt_root/igmt_helper_create_man_page $command_to_show 

    # display it

    read_file_in_window "/tmp/igmt_mp$command_to_show.txt" $w.text
    bind $w <Return> [list destroy $w ]
 
    set oldFocus [focus]
    grab set $w
    focus $w
    
    tkwait variable button
    destroy $w
    focus $oldFocus
    return $button

}

################################################################################
# generic procedure to display any text file


proc show_file { filename daughter parent } {
    set w $parent.$daughter
    catch {destroy $w}
    toplevel $w
    wm title $w "Viewing $filename"
    wm iconname $w "style"
    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.dismiss -text Dismiss -command "destroy $w"
    pack $w.buttons.dismiss  -side left -expand 1
    text $w.text -yscrollcommand "$w.scroll set" -setgrid true \
	-width 120 -height 32 -wrap word
    scrollbar $w.scroll -command "$w.text yview"
    pack $w.scroll -side right -fill y
    pack $w.text -expand yes -fill both
    read_file_in_window $filename $w.text
    bind $w <Return> [list destroy $w ]
    
    set oldFocus [focus]
    grab set $w
    focus $w
    
    tkwait variable button
    destroy $w
    focus $oldFocus
    return $button


}

################################################################################
# helping procedure for displaying texts

proc read_file_in_window { file parent } {
    $parent delete 1.0 end
    set f [open $file]
    while {![eof $f]} {
	$parent insert end [ read $f 1000]
    }
    close $f
}

################################################################################
# function gets called when user wishes to exit
################################################################################

proc exit_d { filename cwd } {
    global saved igmt_root changed_gmtdefaults batchfile igmt_root \
	parameter_filename ps_filename gif_filename grid_filename shade_filename

    proc handle_gmt_defaults_at_exit cwd { 
	global changed_gmtdefaults igmt_root
	if { $changed_gmtdefaults != "0" } {

	    # put the user's .gmtdefaults file back or remove iGMT' own that was placed 
	    # in the current working directory if there was no .gmtdefaults at all
	    
	    if { $changed_gmtdefaults == "oum" } {
		
		# delete the .gmtdefaults file in the current directory since there was none 
		# before

		exec $igmt_root/igmt_helper_handle_gmtdefaults 2 $igmt_root 1
		
	    } else {
		
		# move back the temporarily displaced user .gmtdefault file
		
		exec $igmt_root/igmt_helper_handle_gmtdefaults 2 $igmt_root 0
		puts "iGMT: Your .gmtdefaults file in our working directory"
		puts "iGMT: $cwd is back."
	    }
	}
    }
  
    # check for saving the parameters

    if { $saved == 1 } {
	catch { exec $igmt_root/igmt_helper_rmtmp_silent $batchfile $ps_filename $gif_filename $grid_filename $shade_filename}
	  
	handle_gmt_defaults_at_exit $cwd
	exit
    }
    set value [ dialog .d {About to quit} {You are about to quit and plotting parameters have been changed. Do you want to save the parameters?} \
		    warning 0 {Save & Quit}  {Discard parameters & Quit} {Cancel} ]

    proc exit_with_save { fn cwd} {
	global igmt_root batchfile ps_filename gif_filename grid_filename shade_filename
	save_parameters .mb 
	catch { exec $igmt_root/igmt_helper_rmtmp_silent $batchfile $ps_filename $gif_filename $grid_filename $shade_filename}
	handle_gmt_defaults_at_exit $cwd
	exit
    }
    proc exit_without_save cwd {
	global igmt_root batchfile ps_filename gif_filename grid_filename shade_filename
	catch { exec $igmt_root/igmt_helper_rmtmp_silent $batchfile $ps_filename $gif_filename $grid_filename $shade_filename}
	handle_gmt_defaults_at_exit $cwd
	exit
    }
    if { $value == 0 } { exit_with_save $filename $cwd }
    if { $value == 1 } {  exit_without_save $cwd }


}




################################################################################
# save the plot parameters in a parameter file that can be reloaded in the 
# next session

proc save_parameters { parentw } {
    global west east south north proj ps_filename papersize land_color\
	sea_color batchfile portrait ticks  headermessage river_color \
	river boundary resolution shoreline batcherr pscoast_add\
        raster_dataset plot_title shell_to_use parameter_filename\
	gmtbins grid_filename verbose shade_filename topocolor\
	gtopodata agedata agecolor raster_resolution lon0 lat0 freeair_grav_data \
	gravitycolor custom_projection legend title_font_size title_font saved \
	polygon_dataset plate_boundary_data xysize_data plate_color \
	quake1_color quake2_color gridlines annotation symbol quake3_color \
	custom1_color custom1 custom2_color custom2 quake4_color quake5_color\
	volcano_nametag symbol_size hotspot_nametag nr_of_polygon_data
    
    set fn [tk_getSaveFile -defaultextension .par -initialfile $parameter_filename  -parent $parentw \
		-title "Save parameters to file..." ]
    proc puts_save { fp variable } {
	if { $variable != "" } { puts $fp $variable } else { puts $fp "*" } 
    }
# TO DO: Clean up the parameter saving routine
    if { $fn != "" } {
	set parameter_filename $fn
	set file [open $fn w]
	puts_save $file $south ; puts_save $file $north ; puts_save $file $east ; puts_save $file $west 
	puts_save $file $lat0 ; puts_save $file $lon0 ; puts_save $file $papersize(1) ; puts_save $file $papersize(2) 
	puts_save $file $proj(1) ; puts_save $file $custom_projection ; puts_save $file $raster_resolution
	puts_save $file $portrait ; puts_save $file $plot_title 
	foreach i { 1 2 3 }   { puts_save $file $sea_color($i) }
	foreach i { 1 2 3 }   { puts_save $file $land_color($i) }
	foreach i { 1 2 3 4 } { puts_save $file $river($i) } 
	puts_save $file $boundary(1); puts_save $file $boundary(2) ; 
	puts_save $file  $resolution ; puts_save $file $shoreline 
	puts_save $file $raster_dataset 
	for {set i 1} { $i <= $nr_of_polygon_data } { incr i }  { puts_save $file $polygon_dataset($i) }
	foreach i { 1 2 3 } { puts_save $file $plate_color($i) }
	foreach i { 1 2 3 } { puts_save $file $quake1_color($i) } ; 
	foreach i { 1 2 3 } { puts_save $file $quake2_color($i) } 
	foreach i { 1 2 3 } { puts_save $file $quake3_color($i) } ; 
	foreach i { 1 2 3 } { puts_save $file $quake4_color($i) } 
	puts_save $file $gridlines ; puts_save $file $annotation
	for {set i 1} { $i <= $nr_of_polygon_data } { incr i } { puts_save $file $symbol($i) }
	foreach i { 1 2 3 }   { puts_save $file $custom1_color($i) } ; 
	foreach i { 1 2 3 }   { puts_save $file $custom2_color($i) } ;
	foreach i { 1 2 3 4 5 }   { puts_save $file $custom1($i) }
	foreach i { 1 2 3 4 5 }   { puts_save $file $custom2($i) } 
	puts_save $file $ticks(1) ; puts_save $file $ticks(2)
	foreach i { 1 2 3 } { puts_save $file $quake5_color($i) } 
	puts_save $file $volcano_nametag
	for {set i 1} { $i <= $nr_of_polygon_data } { incr i } { puts_save $file $symbol_size($i)}
	puts_save $file $hotspot_nametag
	close $file
	set saved 1
	set headermessage "iGMT: Saved the parameters in $parameter_filename."
    }
}

################################################################################
# load the plot parameters
#



proc load_parameters { parentw } {

    global west east south north proj ps_filename papersize land_color\
	sea_color batchfile portrait ticks  headermessage river_color \
	river boundary resolution shoreline batcherr pscoast_add\
        raster_dataset plot_title shell_to_use parameter_filename \
	gmtbins grid_filename verbose shade_filename topocolor\
	gtopodata agedata agecolor raster_resolution lon0 lat0 freeair_grav_data \
	gravitycolor custom_projection legend title_font_size title_font saved \
	polygon_dataset plate_boundary_data xysize_data plate_color \
	quake1_color quake2_color gridlines annotation symbol\
	custom1_color custom1 custom2_color custom2 colormap quake4_color quake5_color \
	quake3_color volcano_nametag symbol_size hotspot_nametag nr_of_polygon_data
    
    set fn [tk_getOpenFile -defaultextension .par -initialfile $parameter_filename  -parent $parentw \
		 -title "Load parameters from file..." ]
    set parameter_filename $fn
    proc gets_save { fp variable } {
	upvar $variable var
	gets $fp var_tmp
	if { ($var_tmp != "*")&&($var_tmp != "") } { set var $var_tmp }
    }
    
    if { $fn != "" } {
	set parameter_filename $fn 
	set file [open $fn r]
	set nrlines_parfile  [ exec cat $fn | wc -l ]
	if { $nrlines_parfile != 98 } { 
	    dialog .d {Version incompability...} \
		"To honor Microsoft this iGMT version\ncannot understand parameterfiles other\nthan those from the new version which have 98 lines.\nSorry, use an older version to load this file."  "" 0 {OK}
	} else {
	    gets_save $file south ; gets_save $file north ; gets_save $file east ; gets_save $file west 
	    gets_save $file lat0 ; gets_save $file lon0 ; gets_save $file papersize(1) ; gets_save $file papersize(2) 
	    gets_save $file proj(1) ; gets_save $file custom_projection ; gets_save $file raster_resolution
	    gets_save $file portrait ; gets_save $file plot_title
	    foreach i { 1 2 3 }   { gets_save $file sea_color($i) }
	    foreach i { 1 2 3 }   { gets_save $file land_color($i) }
	    foreach i { 1 2 3 4 } { gets_save $file river($i) } 
	    gets_save $file boundary(1); gets_save $file boundary(2) ; gets_save $file  resolution ; gets_save $file shoreline 
	    gets_save $file raster_dataset ; 
	    for {set i 1} { $i <= $nr_of_polygon_data } { incr i } { gets_save $file polygon_dataset($i) }
	    foreach i { 1 2 3 } { gets_save $file plate_color($i) }
	    foreach i { 1 2 3 }   { gets_save $file quake1_color($i) } 
	    foreach i { 1 2 3 }   { gets_save $file quake2_color($i) }
	    foreach i { 1 2 3 }   { gets_save $file quake3_color($i) }
	    foreach i { 1 2 3 }   { gets_save $file quake4_color($i) }
	    gets_save $file gridlines ; gets_save $file annotation
	    for {set i 1} { $i <= $nr_of_polygon_data } { incr i }  { gets_save $file symbol($i) }
	    foreach i { 1 2 3 }   { gets_save $file custom1_color($i) } 
	    foreach i { 1 2 3 }   { gets_save $file custom2_color($i) } 
	    foreach i { 1 2 3 4 5 }   { gets_save $file custom1($i) } 
	    foreach i { 1 2 3 4 5 }   { gets_save $file custom2($i) } 
	    gets_save $file ticks(1) ; gets_save $file ticks(2)
	    foreach i { 1 2 3 } { gets_save $file quake5_color($i) } 
	    gets_save $file volcano_nametag
	    for {set i 1} { $i <= $nr_of_polygon_data } { incr i } { gets_save $file symbol_size($i)}
	    gets_save $file hotspot_nametag
	    close $file
	    set headermessage "iGMT: Loaded the parameters from $parameter_filename."
	}
    }
    switch $raster_dataset {
	"1" -
	"2" -
	"3" { set colormap $topocolor }
	"4" { set colormap $agecolor }
	"5" { set colormap $gravitycolor }
	default {  set colormap $topocolor }
    }


}



################################################################################
# used to return from a procedure and destroy the dialog window that was calling
proc ret {w} {
    destroy $w
    return
}


################################################################################
# generic procedures used to copy files by using the file open dialog

proc copy_file { titleline filename homedir masterwindow } {
    global headermessage igmt_root
    set initialfilename [ format %s/igmt%s $homedir [ file extension $filename ] ]
    set fn [tk_getSaveFile  -initialfile $initialfilename    -parent $masterwindow \
		-title $titleline ]
    if { $fn != "" } {
	# this is tough copying, no individual check is done if the file exists
	# rely on getSaveFile to do this
	exec cp $filename $fn
	set headermessage "iGMT: Copied $filename to $fn"
    }
    return
}
    
################################################################################
# helping procedures for the handling of the global temporary array 
# tmp_array

proc assign_tmp_array { a } {
    upvar $a c
    global tmp_array
    foreach i [ lsort [ array name c ]] { 
	set tmp_array($i) $c($i)
    }
}
proc assign_ref_array { a } {
    upvar $a c
    global tmp_array
    foreach i [ lsort [ array name c ]] { 
	set c($i) $tmp_array($i)
    }
}


################################################################################
# display a short message about the version and how to get help


proc show_help upperframe {
    dialog .d {About iGMT...} \
	"iGMT: Interactive Mapping of Geoscientific Datasets.\nCopyright (C) 1998  Thorsten W. Becker, Alexander Braun\n\nThis program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program; see the file COPYING.  If not, write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. \n\niGMT version 1.0b\n\nMay 11, 1998\n\niGMT stands for \"Interactive GMT\" or \"Interactive Mapping of Geoscientific Datasets\". It integrates the processing of various earth !
science datasets with a Tcl/Tk user interface to GMT.\nClicking on \"Map it!\" produces a GMT script whose postscript output is converted and displayed as a GIF.\n\nFind a description of the software usage in the \"manual.ps\" file that should have come with the distribution of refer to the iGMT web site\n\nhttp://www.seismology.harvard.edu/~becker/igmt"  "" 0 {OK} 


}



