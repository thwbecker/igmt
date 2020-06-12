
################################################################################
# igmt_iomisc.tcl -- input, output and miscelleanous procedures
#
# part of the iGMT package
#
# $Id: igmt_iomisc.tcl,v 1.13 2001/08/08 15:49:54 becker Exp becker $
#
################################################################################


################################################################################
# generic dialog procedure modified from 
# "Tcl and the Tk toolkit" by J. K. Ousterhout
#

proc dialog { w title text bitmap default args} {
    global button
 
    # obtain top level geometry
    set w_x_pos [expr [ winfo x . ] + 100 ]
    set w_y_pos [expr [ winfo y . ] + 50 ]

    # create top-level window and divide it into two parts 
    toplevel $w -class Dialog
    wm geometry $w +$w_x_pos+$w_y_pos
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
	button $w.bot.button$i -relief groove -text $but -command\
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
    global igmt_root gmtmanpath
    set w $parent.$command_to_show
    catch {destroy $w}
    # obtain top level geometry
    set w_x_pos [expr [ winfo x . ] + 25 ]
    set w_y_pos [expr [ winfo y . ] + 50 ]

    toplevel $w
    wm geometry $w +$w_x_pos+$w_y_pos
    wm title $w "Man page viewer for $command_to_show"
    wm iconname $w "style"
    
    
    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.dismiss -relief groove -text Dismiss -command "destroy $w"
    pack $w.buttons.dismiss  -side left -expand 1
    text $w.text -yscrollcommand "$w.scroll set" -setgrid true \
	-width 80 -height 32 -wrap word
    scrollbar $w.scroll -command "$w.text yview"
    pack $w.scroll -side right -fill y
    pack $w.text -expand yes -fill both
    
    # create a temporary text file containing the man page

    exec $igmt_root/igmt_helper_create_man_page $command_to_show $gmtmanpath

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

    # obtain top level geometry
    set w_x_pos [expr [ winfo x . ] + 25 ]
    set w_y_pos [expr [ winfo y . ] + 25 ]

    toplevel $w
    wm title $w "Viewing $filename"
    wm iconname $w "style"
    wm geometry $w +$w_x_pos+$w_y_pos
    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.dismiss -relief groove -text Dismiss -command "destroy $w"
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
	parameter_filename ps_filename gif_filename temp_grid_filename \
	temp_shade_filename temp_cont_int_filename


   
  
    # check for saving the parameters

    if { $saved == 1 } {
	catch { exec $igmt_root/igmt_helper_rmtmp_silent $batchfile $ps_filename $gif_filename $temp_grid_filename $temp_shade_filename $cwd/.gmtcommands }
	  
	exit
    }
    set value [ dialog .d {About to quit} {You are about to quit and plotting parameters have been changed. Do you want to save the parameters?} \
		    warning 0 {Save & Quit}  {Discard parameters & Quit} {Cancel} ]

    proc exit_with_save { fn cwd} {
	global igmt_root batchfile ps_filename gif_filename temp_grid_filename temp_shade_filename saved
	save_parameters .mb 
	catch { exec $igmt_root/igmt_helper_rmtmp_silent $batchfile $ps_filename $gif_filename $temp_grid_filename $temp_shade_filename  }
	if { $saved == 1 } exit
    }
    proc exit_without_save cwd {
	global igmt_root batchfile ps_filename gif_filename temp_grid_filename temp_shade_filename temp_cont_int_filename
	catch { exec $igmt_root/igmt_helper_rmtmp_silent $batchfile $ps_filename $gif_filename $temp_grid_filename $temp_shade_filename  }
	exit
    }
    if { $value == 0 } { exit_with_save $filename $cwd }
    if { $value == 1 } {  exit_without_save $cwd }


}




################################################################################
# save the plot parameters in a parameter file that can be reloaded in the 
# next session

proc save_parameters { parentw } {
    global  west east south north proj ps_filename papersize batchfile portrait ticks  headermessage  \
	river boundary resolution shoreline batcherr pscoast_add raster_dataset plot_title \
	shell_to_use parameter_filename gmtbins temp_grid_filename verbose temp_shade_filename \
	raster_resolution lon0 lat0  custom_projection legend title_font_size title_font saved \
	polygon_dataset  gridlines annotation colormap  nr_of_polygon_data nr_of_raster_data \
	parameter_file_format raster_dataset  temp_grid_filename psc_linewidth \
	poly_data poly_color poly_symbol nr_of_polygon_parameters \
	poly_linewidth poly_symbol_size poly_parameter \
	raster_data raster_colormap pscoast_color show_gmt_logo contour_para
	
   
    set fn [tk_getSaveFile -defaultextension .par -initialfile $parameter_filename  -parent $parentw \
		-title "Save parameters to file..." ]
    proc puts_save { fp variable } {
	if { $variable != "" } { puts $fp $variable } else { puts $fp "*" } 
    }

    if { $fn != "" } {
	set parameter_filename $fn
	set file [open $fn w]
	if { $parameter_file_format < 1.2 } {
	    # nr of poygon settings to save, varies since it has increased from 
	    # version to version
#	    if { $parameter_file_format <= 1.0 } {
	    set nr_par_to_save 9 
#	    } elseif { $parameter_file_format <= 1.1 } {
#		set nr_par_to_save 11
#	    } 
	    puts_save $file $south ; 
	    puts_save $file $north ; 
	    puts_save $file $east ; 
	    puts_save $file $west 
	    puts_save $file $lat0 ; 
	    puts_save $file $lon0 ; 
	    puts_save $file $papersize(1) 
	    puts_save $file $papersize(2) 
	    puts_save $file $proj(1) ; 
	    puts_save $file $custom_projection ; 
	    puts_save $file $raster_resolution
	    puts_save $file $portrait ; 
	    puts_save $file $plot_title
	    foreach i { 1 2 3 } { puts_save $file $pscoast_color(2,$i) }
	    foreach i { 1 2 3 } { puts_save $file $pscoast_color(1,$i) }
	    foreach i { 1 2 3 4 } { puts_save $file $river($i) } 
	    puts_save $file $boundary(1); 
	    puts_save $file $boundary(2) ; 
	    puts_save $file  $resolution ; 
	    puts_save $file $shoreline 
	    puts_save $file $raster_dataset ; 
	    for {set i 1} { $i <= $nr_par_to_save } { incr i } { 
		puts_save $file $polygon_dataset($i) 
	    }
	    foreach j { 1 2 3 6 9 } {
		foreach i { 1 2 3 }   { puts_save $file $poly_color($j,$i) } 
	    }
	    
	    puts_save $file $gridlines ; 
	    puts_save $file $annotation
	    for {set i 1} { $i <= $nr_par_to_save } { incr i }  { 
		puts_save $file $poly_symbol($i) 
		if { [ string length $poly_symbol($i) ] == 1 } {
		    set poly_symbol($i) [ format -S%s $poly_symbol($i) ]
		}
	    }
	    foreach i { 1 2 3 }   { puts_save $file $poly_color(4,$i) } 
	    foreach i { 1 2 3 }   { puts_save $file $poly_color(5,$i) } 
	    foreach i { 1 2 3 4 5 }   { puts_save $file $poly_parameter(4,$i) } 
	    foreach i { 1 2 3 4 5 }   { puts_save $file $poly_parameter(5,$i) } 
	    puts_save $file $ticks(1) ; puts_save $file $ticks(2)
	    foreach i { 1 2 3 } { puts_save $file $poly_color(9,$i) } 
	    puts_save $file $poly_parameter(8,1)
	    for {set i 1} { $i <= $nr_par_to_save } { incr i } { 
		puts_save $file $poly_symbol_size($i)
	    }
	    puts_save $file poly_parameter(7,1)
	    if { $parameter_file_format >= 1.1 } {
		puts_save $file $poly_data(10)
		foreach i { 1 2 3 4 5 } {
		    puts_save $file $poly_parameter(10,$i)
		}
		foreach i { 1 2 3 } { puts_save $file $poly_color(10,$i) }
		foreach i { 1 2 3 } { puts_save $file $poly_color(11,$i) }
	    }
	} else { # iGMT version 1.2 
	    # first all map based stufff
	    puts_save $file $south ; 
	    puts_save $file $north ; 
	    puts_save $file $east ; 
	    puts_save $file $west 
	    puts_save $file $lat0 ; 
	    puts_save $file $lon0 ; 
	    puts_save $file $papersize(1) 
	    puts_save $file $papersize(2) 
	    puts_save $file $proj(1) ; 
	    puts_save $file $custom_projection ; 
	    puts_save $file $raster_resolution
	    puts_save $file $portrait ; 
	    puts_save $file $plot_title
	    foreach i { 1 2 3 }   { 
		foreach j { 1 2 3 } {
		    puts_save $file $pscoast_color($j,$i) 
		}
	    }
	    foreach i { 1 2 3 4 } { puts_save $file $river($i) } 
	    foreach i { 1 2 } { puts_save $file $boundary($i); }
	    puts_save $file $resolution ; 
	    puts_save $file $shoreline 
	    puts_save $file $raster_dataset ; 
	    puts_save $file $gridlines ; 
	    foreach i { 1 2 } { puts_save $file $ticks($i) }
	    # now write all raster parameters 
	    for { set i 1 } { $i <=  $nr_of_raster_data } { incr i } {
		puts_save $file $raster_data($i)
		puts_save $file $raster_colormap($i)
	    }
	    # all polygon type parameters
	    for { set i 1 } { $i <=  $nr_of_polygon_data } { incr i } {
		puts_save $file $poly_symbol($i)
		puts_save $file $poly_symbol_size($i)
		puts_save $file $poly_linewidth($i)
		puts_save $file $polygon_dataset($i)
		foreach j { 1 2 3 } { puts_save $file $poly_color($i,$j) }
		for { set j 1 } { $j <= $nr_of_polygon_parameters } { incr j } {
		    puts_save $file $poly_parameter($i,$j) 
		}
	    }
	    puts_save $file $show_gmt_logo
	    # contour line settings
	    foreach i { 1 2 3 4 5 } { 
		if { $i == 3 } {
		    foreach j { 1 2 3 } { puts_save $file $contour_para($i,$j) }
		} else { 
		    puts_save $file $contour_para($i);
		}
	    }
	}
	close $file
	set saved 1
	set headermessage "iGMT: Saved parameters for iGMT $parameter_file_format in $parameter_filename."
    }
}

################################################################################
# load the plot parameters
#



proc load_parameters { parentw } {
    global west east south north proj ps_filename papersize batchfile portrait ticks  headermessage  \
	river boundary resolution shoreline batcherr pscoast_add raster_dataset plot_title \
	shell_to_use parameter_filename gmtbins temp_grid_filename verbose temp_shade_filename \
	raster_resolution lon0 lat0  custom_projection legend title_font_size title_font saved \
	polygon_dataset  gridlines annotation colormap  nr_of_polygon_data nr_of_raster_data \
	parameter_file_format raster_dataset  temp_grid_filename psc_linewidth \
	poly_data poly_color poly_symbol nr_of_polygon_parameters \
	poly_linewidth poly_symbol_size poly_parameter \
	raster_data raster_colormap pscoast_color show_gmt_logo \
	contour_para
	
    # length of the parameter files of different versions
    # length of version 1.0
    set pfl1_0 95
    # length of version 1.1
    set pfl1_1 95
    # length of version 1.2
    set pfl1_2 507

    proc gets_save { fp variable } {
	upvar $variable var
	gets $fp var_tmp
	if { ($var_tmp != "*")&&($var_tmp != "") } { set var $var_tmp }
    }
    
    set fn [tk_getOpenFile -defaultextension .par -initialfile $parameter_filename  -parent $parentw \
		-title "Load parameters from file..." ]
    
    if { $fn != "" } {
	set parameter_filename $fn 
	set file [open $fn r]
	set nrlines_parfile  [ exec cat $fn | wc -l ]
	if { ( $parameter_file_format == 1.2 ) && ( $nrlines_parfile != $pfl1_2 ) } { 
	    dialog .d {Version incompability...} \
		"You selected parameter files for version 1.2 which have $pfl1_2 lines.\nThe parameter file you want to load has length $nrlines_parfile.\nIf it is an older version, say for iGMT v1.1/v1.0 ($pfl1_1/$pfl1_0 lines), select the corresponding format."  "" 0 {OK}
	} elseif { ( $parameter_file_format == 1.1 ) && ( $nrlines_parfile != $pfl1_1 ) } { 
	    dialog .d {Version incompability...} \
		"You selected parameter files for version 1.1 which have $pfl1_1 lines.\nThe parameter file you want to load has length $nrlines_parfile.\nIf it is an older version, say for iGMT v1.0/v1.2 ($pfl1_0/$pfl1_2 lines), select the corresponding format."  "" 0 {OK}
	} elseif { ( $parameter_file_format == 1.0 ) && ( $nrlines_parfile != $pfl1_0 ) } { 
	    dialog .d {Version incompability...} \
		"You selected parameter files for version 1.0 which have $pfl1_0 lines.\nThe parameter file you want to load has length $nrlines_parfile.\nIf it is a newer version, say for iGMT v1.1/v1.2 ($pfl1_1/$pfl1_2 lines), select a different format."  "" 0 {OK}
	} else { 
	    if { $parameter_file_format < 1.2 } {
#		if { $parameter_file_format <= 1.0 } {
		    set nr_par_to_load 9 
#		} elseif { $parameter_file_format <= 1.1 } {
#		    set nr_par_to_load 11
#		}
		    gets_save $file south ; 
		    gets_save $file north ; 
		    gets_save $file east ; 
		    gets_save $file west 
		    gets_save $file lat0 ; gets_save $file lon0 ; 
		    gets_save $file papersize(1) 
		    gets_save $file papersize(2) 
		    gets_save $file proj(1) ; 
		    gets_save $file custom_projection ; 
		    gets_save $file raster_resolution
		    gets_save $file portrait ; gets_save $file plot_title
		    foreach i { 1 2 3 } { gets_save $file pscoast_color(2,$i) }
		    foreach i { 1 2 3 } { gets_save $file pscoast_color(1,$i) }
		    foreach i { 1 2 3 4 } { gets_save $file river($i) } 
		    gets_save $file boundary(1); 
		    gets_save $file boundary(2) ; 
		    gets_save $file  resolution ; 
		    gets_save $file shoreline 
		    gets_save $file raster_dataset ; 
		    for {set i 1} { $i <= $nr_par_to_load } { incr i } { 
			gets_save $file polygon_dataset($i) 
		    }
		    foreach j { 1 2 3 6 9 } {
			foreach i { 1 2 3 }   { gets_save $file poly_color($j,$i) } 
		    }
		    
		    gets_save $file gridlines ; 
		    gets_save $file annotation
		    for {set i 1} { $i <= $nr_par_to_load } { incr i }  { 
			gets_save $file poly_symbol($i) 
			if { [ string length $poly_symbol($i) ] == 1 } {
			    set poly_symbol($i) [ format -S%s $poly_symbol($i) ]
			}
		    }
		    foreach i { 1 2 3 }   { gets_save $file poly_color(4,$i) } 
		    foreach i { 1 2 3 }   { gets_save $file poly_color(5,$i) } 
		    foreach i { 1 2 3 4 5 }   { gets_save $file poly_parameter(4,$i) } 
		    foreach i { 1 2 3 4 5 }   { gets_save $file poly_parameter(5,$i) } 
		    gets_save $file ticks(1) ; gets_save $file ticks(2)
		    foreach i { 1 2 3 } { gets_save $file poly_color(9,$i) } 
		    gets_save $file poly_parameter(8,1)
		    for {set i 1} { $i <= $nr_par_to_load } { incr i } { 
			gets_save $file poly_symbol_size($i)
		    }
		    gets_save $file poly_parameter(7,1)
		    if { $parameter_file_format >= 1.1 } {
			gets_save $file poly_data(10)
			foreach i { 1 2 3 4 5 } {
			    gets_save $file poly_parameter(10,$i)
			}
			foreach i { 1 2 3 } { gets_save $file poly_color(10,$i) }
			foreach i { 1 2 3 } { gets_save $file poly_color(11,$i) }
		    }
		} else { # iGMT version 1.2 
		    # first all map based stufff
		    gets_save $file south ; 
		    gets_save $file north ; 
		    gets_save $file east ; 
		    gets_save $file west 
		    gets_save $file lat0 ; gets_save $file lon0 ; 
		    gets_save $file papersize(1) 
		    gets_save $file papersize(2) 
		    gets_save $file proj(1) ; 
		    gets_save $file custom_projection ; 
		    gets_save $file raster_resolution
		    gets_save $file portrait ; gets_save $file plot_title
		    foreach i { 1 2 3 }   { 
			foreach j { 1 2 3 } {
			    gets_save $file pscoast_color($j,$i) 
			}
		    }
		    foreach i { 1 2 3 4 } { gets_save $file river($i) } 
		    gets_save $file boundary(1); 
		    gets_save $file boundary(2) ; 
		    gets_save $file resolution ; 
		    gets_save $file shoreline 
		    gets_save $file raster_dataset ; 
		    gets_save $file gridlines ; 
		    gets_save $file ticks(1) ; gets_save $file ticks(2)
		    # now write all raster parameters 
		    for { set i 1 } { $i <=  $nr_of_raster_data } { incr i } {
			gets_save $file raster_data($i)
			gets_save $file raster_colormap($i)
		    }
		    # all polygon type parameters
		    for { set i 1 } { $i <=  $nr_of_polygon_data } { incr i } {
			gets_save $file poly_symbol($i)
			gets_save $file poly_symbol_size($i)
			gets_save $file poly_linewidth($i)
			gets_save $file polygon_dataset($i)
			foreach j { 1 2 3 } { gets_save $file poly_color($i,$j) }
			for { set j 1 } { $j <= $nr_of_polygon_parameters } { incr j } {
			    gets_save $file poly_parameter($i,$j) 
			}
		    }
		    gets_save $file show_gmt_logo
		    foreach i { 1 2 3 4 5 } {
			if { $i == 3 } {
			    foreach j { 1 2 3 } { gets_save $file contour_para($i,$j) }
			} else {
			    gets_save $file contour_para($i)
			}
		    }
		}
	    set colormap $raster_colormap($raster_dataset) 
	    close $file
	    set headermessage "iGMT: Loaded parameters for iGMT $parameter_file_format from $parameter_filename."
	}

    }
}



################################################################################
# used to return from a procedure and destroy the dialog window that was calling
proc ret { w } {
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
# display a short message about the version and how to get help


proc show_help parent {
    global igmt_root  
    
    set w $parent.about
    catch {destroy $w}
    
    set w_x_pos [expr [ winfo x . ] + 25 ]
    set w_y_pos [expr [ winfo y . ] + 25 ]
    toplevel $w
    wm geometry $w +$w_x_pos+$w_y_pos
    wm title $w "About iGMT..."

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.dismiss -relief groove -text Dismiss -command "destroy $w"
    pack $w.buttons.dismiss  -side left -expand 1
    text $w.text -yscrollcommand "$w.scroll set" -setgrid true \
	-width 80 -height 32 -wrap word
    scrollbar $w.scroll -command "$w.text yview"
    pack $w.scroll -side right -fill y
    pack $w.text -expand yes -fill both
    read_file_in_window "$igmt_root/README.TXT" $w.text
    bind $w <Return> [list destroy $w ]
}



################################################################################
# display postscript file using the default UNIX program
################################################################################

proc dsp_ps { filename } {
    global psviewer_command_landscape portrait\
	psviewer_command_portrait
    
    # check for possible rotation
    
    if { $portrait == 0 } { 
	set tmp_pid [ eval "exec $psviewer_command_landscape $filename &" ]
    } else {
	set tmp_pid [ eval "exec $psviewer_command_portrait  $filename &"]
    }
    return 
}

################################################################################
# create a colormap using grd2cpt
################################################################################


proc create_colormap { scale masterw } {
    global gmtbins colormap gmt_version  temp_grid_filename\
	headermessage new_colormap gmt_version_boundary\
	our_awk igmt_root
    
    # for later GMT version, use certain scheme to produce cpt file
    switch $scale {
	1 { set scheme cool }
	2 { set scheme copper }
	3 { set scheme gebco }
	4 { set scheme gray }
	5 { set scheme haxby }
	6 { set scheme hot }
	7 { set scheme jet }
	8 { set scheme polar }
	9 { set scheme rainbow }
	10 { set scheme red2green }
	11 { set scheme relief }
	12 { set scheme topo }
	13 { set scheme sealand }
	0 -
	default { set scheme rainbow }
    }
    set grd2cpt [ format %sgrd2cpt     $gmtbins ]
    
    # execute grd2cpt
    if { $gmt_version >= $gmt_version_boundary } {
	set command_string "exec $grd2cpt $temp_grid_filename -C$scheme"
    } else {
	set command_string "exec $grd2cpt $temp_grid_filename"
    }
    set command_string "$command_string | $our_awk -f $igmt_root/formatcpt.awk \> $new_colormap"

    if { [ catch { exec ls  $temp_grid_filename } ] } {
	dialog .d {grd2cpt error...} \
		"Can not create colormap since the temporary grd file $temp_grid_filename is not (yet?) there.\nDid you plot raster data already?"  warning 0 {OK}
	return
    } else {
	set headermessage "iGMT: creating $scheme colormap for $temp_grid_filename ..."
	update idletasks
	catch {  eval $command_string  } output 
	if { $output != "" } {
	    puts "iGMT: $output"
	    dialog .d {grd2cpt error...} \
		"Could not create colormap $new_colormap\nusing grd2cpt. Check if grd-file\n $temp_grid_filename\n exists, or, if $new_colormap exists, \ncheck if we can overwrite it (noclobber?)\n"  warning 0 {OK}
	    return
	} else {
	    set headermessage "iGMT: created colormap $new_colormap, ready for use with next plot"
	    update idletasks
	    set colormap $new_colormap
	    return
	}
    }

}

################################################################################
# adjust for different GMT versions


proc adjust_settings_to_gmt_version { l_gmt_version } {
    global gmt_version gmt_version_boundary gmtbins\
	lower_version_gmtbins higher_version_gmtbins \
	headermessage

    set gmt_version $l_gmt_version
    
    if { $gmt_version >= $gmt_version_boundary } {
	set gmtbins $higher_version_gmtbins
    } else {
	set gmtbins $lower_version_gmtbins
    }
    set headermessage "iGMT: settings for GMT version $gmt_version"
    update idletasks
}

