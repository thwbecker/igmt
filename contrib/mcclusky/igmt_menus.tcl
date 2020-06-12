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
# igmt_menus.tcl -- set up the major menu bar and the sub menus
#
# part of the iGMT package
#
################################################################################


################################################################################
# master menubar
################################################################################

frame .mb 

menubutton .mb.menu1 -text "File/Plot" -menu .mb.menu1.m  \
        -underline 0
menubutton .mb.menu5 -text "Datasets" -menu .mb.menu5.m \
    -underline 0
menubutton .mb.menu2 -text "Parameters" -menu .mb.menu2.m  \
        -underline 1
menubutton .mb.menu4 -text "Scripting options" -menu .mb.menu4.m -underline 0
menubutton .mb.menu3 -text "GMT man pages" -menu .mb.menu3.m -underline 0
button .mb.button2 -text "Map it!" -underline 0 -command { 
    if { [ mk_ps ] } {   conv_ps; refresh_image  }}
button .mb.button1 -text "Quit" -command {exit_d $parameter_filename $env(PWD) }  -underline 0
pack .mb.menu1 .mb.menu5 .mb.menu2 .mb.menu4 .mb.menu3 -side left
pack .mb.button2 .mb.button1 -side left -padx 10
pack .mb

################################################################################
# Plot/File menu part

menu .mb.menu1.m
.mb.menu1.m add command -label "Create PS & display GIF (MapIt!)" -command {mk_ps ; conv_ps; refresh_image} \
    -accelerator "Ctrl+p" -underline 0
.mb.menu1.m add command -label "Create PS file" -command {mk_ps} -underline 7
.mb.menu1.m add command -label "Display PS file" -command {dsp_ps} -underline 0
.mb.menu1.m add command -label "Create and display PS" -command {mk_ps; dsp_ps} -underline 1
.mb.menu1.m add separator
.mb.menu1.m add command -label "Save PS file"  \
    -command [ list copy_file "Save the PS file as..." $ps_filename $env(HOME) .mb ] -underline 0 
.mb.menu1.m add command -label "Save GIF file" \
    -command [ list copy_file "Save the GIF file as..." $gif_filename $env(HOME) .mb ] -underline 0
.mb.menu1.m add separator
.mb.menu1.m add command -label "Load parameters" -command [ list load_parameters .mb ] \
    -underline 0 -accelerator "Ctrl+o"
.mb.menu1.m add command -label "Save parameters" -command [ list save_parameters  .mb ] \
    -underline 0 -accelerator "Ctrl+s"
.mb.menu1.m add separator
.mb.menu1.m add command -label "About iGMT/Help" -command [ list show_help .mb ]
.mb.menu1.m add separator
.mb.menu1.m add command -label "Quit" -command {exit_d $parameter_filename $env(PWD) } -underline 0 -accelerator "Ctrl+q"
pack .mb.menu1

################################################################################
# datasets part

menu .mb.menu5.m
.mb.menu5.m add command -label "Raster data choice" -command {choose_raster_datasets .mb } -underline 0
.mb.menu5.m add command -label "Polygon data choices" -command {choose_polygon_datasets .mb} -underline 0
.mb.menu5.m add separator
.mb.menu5.m add command -label "Change custom raster data file"   \
	-command {change_filename custom_raster_data "Change the custom raster data file..." .mb }

.mb.menu5.m add separator
.mb.menu5.m add command -label "Change CMT data file"   -command {change_filename cmtdata "Change the CMT file (psvelomeca format) to..." .mb }
.mb.menu5.m add command -label "Change significant quake data file" -command {change_filename xysize_data(1) "Change the significant quake data file to..." .mb}
.mb.menu5.m add command -label "Change the USGS/NEIC data file" -command {change_filename  xysize_data(2) "Change the USGS/NEIC data file to..." .mb}
.mb.menu5.m add command -label "Change velocity data file"   -command {change_filename veldata "Change the velocity file to..." .mb }

.mb.menu5.m add command -label "Parameters custom xys 1" -command { set_custom_xys_parameters  1 .mb } 
.mb.menu5.m add command -label "Parameters custom xys 2" -command { set_custom_xys_parameters  2 .mb } 
pack .mb.menu5


################################################################################
# Parameters menu part

menu .mb.menu2.m
.mb.menu2.m add command -label "Region" -command {enter_region} -accelerator "Ctrl+r" -underline 0
.mb.menu2.m add command -label "Projection" -comman {change_projection} -underline 0
.mb.menu2.m add separator
.mb.menu2.m add command -label "Pscoast polygon selection" -command {pscoast_features} -underline 8
.mb.menu2.m add cascade -label "Pscoast coloring" -menu .mb.menu2.m.pscoastcol
.mb.menu2.m add cascade -label "Pscoast linewidth" -menu .mb.menu2.m.lwpscoast
.mb.menu2.m add separator
.mb.menu2.m add cascade -label "Legend raster data" -menu .mb.menu2.m.legend 
.mb.menu2.m add command -label "Raster resolution" -command {change_raster_resolution .mb } -underline 1
.mb.menu2.m add command -label "Change colormap"   -command {change_filename colormap "Change the raster colormap to..." .mb }
.mb.menu2.m add cascade -label "Shade raster data" -menu .mb.menu2.m.shade
.mb.menu2.m add separator
.mb.menu2.m add cascade -label "Symbols polygon data" -menu .mb.menu2.m.symbols
.mb.menu2.m add cascade -label "Sizes polygon data" -menu .mb.menu2.m.sizes
.mb.menu2.m add cascade -label "Color polygon data" -menu .mb.menu2.m.cpolygon
.mb.menu2.m add cascade -label "Linewidth polygon data" -menu .mb.menu2.m.lwpolygon
.mb.menu2.m add cascade -label "Name tags" -menu .mb.menu2.m.nametags
.mb.menu2.m add separator
.mb.menu2.m add cascade -label "Grid lines" -menu .mb.menu2.m.gridlines
.mb.menu2.m add cascade -label "Frame annotation" -menu .mb.menu2.m.annotation
.mb.menu2.m add cascade -label "Longitudinal tick intervals" -menu .mb.menu2.m.xticks
.mb.menu2.m add cascade -label "Latitudinal tick intervals" -menu .mb.menu2.m.yticks
.mb.menu2.m add cascade -label "Fancy mapscale" -menu .mb.menu2.m.mapscale
.mb.menu2.m add separator
.mb.menu2.m add command -label "Plot title" -command { enter_title_line  .mb }  -underline 0
.mb.menu2.m add command -label "Page size" -command { enter_papersize .mb } -underline 5
.mb.menu2.m add command -label "Velocity vector info" -command { enter_vellook .mb } -underline 5
.mb.menu2.m add cascade -label "PS Page orientation" -menu .mb.menu2.m.orient
.mb.menu2.m add command -label "PS page offsets" -command { enter_offsets .mb } 
pack .mb.menu2

# submenues of the parameter menu part

menu .mb.menu2.m.lwpscoast
.mb.menu2.m.lwpscoast add cascade -label "Rivers"               -menu .mb.menu2.m.lwpscoast.1
.mb.menu2.m.lwpscoast add cascade -label "National boundaries"  -menu .mb.menu2.m.lwpscoast.2

foreach i { 1 2 } {
    menu .mb.menu2.m.lwpscoast.$i
    for { set j 1} { $j <= 5 } { incr j } {
	.mb.menu2.m.lwpscoast.$i  add radiobutton -label "$j" -variable psc_linewidth($i) -value $j
    }
}
menu .mb.menu2.m.pscoastcol
.mb.menu2.m.pscoastcol add command -label "Sea" -command {change_color sea_color "Color of wet areas" .mb } 
.mb.menu2.m.pscoastcol add command -label "Land" -command {change_color land_color "Color of dry areas" .mb } 


menu .mb.menu2.m.lwpolygon
.mb.menu2.m.lwpolygon add cascade -label "Plate boundaries" -menu .mb.menu2.m.lwpolygon.1
.mb.menu2.m.lwpolygon add cascade -label "Slab contours" -menu .mb.menu2.m.lwpolygon.9
.mb.menu2.m.lwpolygon add cascade -label "Velocity vectors" -menu .mb.menu2.m.lwpolygon.10

for {set i 1} { $i <= $nr_of_polygon_data } {incr i } {
    menu .mb.menu2.m.lwpolygon.$i
    for { set j 1} { $j <= 5 } { incr j } {
	.mb.menu2.m.lwpolygon.$i add radiobutton -label "$j" -variable pol_linewidth($i) -value $j
    }
}

menu .mb.menu2.m.sizes
.mb.menu2.m.sizes add command -label "Size of hotspot locations" \
    -command {set_symbol_size 7 "Hotspot locations...." .mb}
.mb.menu2.m.sizes add command -label "Size of volcano locations" \
    -command {set_symbol_size 8 "Volcano locations..." .mb}
.mb.menu2.m.sizes add command -label "Size of CMT solutions" \
    -command {set_symbol_size 6 "CMT solutions..." .mb}
.mb.menu2.m.sizes add command -label "Size of NGDC quakes" \
    -command {set_symbol_size 2 "Significant quakes of NGDC..." .mb}
.mb.menu2.m.sizes add command -label "Size of USGS/NEIC quakes" \
    -command {set_symbol_size 3 "USGS/NEIC quakes..." .mb}
.mb.menu2.m.sizes add command -label "Size of vector locations" \
    -command {set_symbol_size 10 "Vector locations..." .mb}
.mb.menu2.m.sizes add command -label "Size of custom polygon data 1" \
    -command {set_symbol_size 4 "Custom polygon data 1..." .mb }
.mb.menu2.m.sizes add command -label "Size of custom polygon data 2" \
    -command {set_symbol_size 5 "Custom polygon data 2..." .mb }

menu .mb.menu2.m.symbols
.mb.menu2.m.symbols add cascade -label "Symbol of hotspot locations"  -menu .mb.menu2.m.symbol7
.mb.menu2.m.symbols add cascade -label "Symbol of volcano locations"  -menu .mb.menu2.m.symbol8
.mb.menu2.m.symbols add cascade -label "Symbol of NGDC quakes" -menu .mb.menu2.m.symbol2
.mb.menu2.m.symbols add cascade -label "Symbol of USGS/NEIC quakes" -menu .mb.menu2.m.symbol3
.mb.menu2.m.symbols add cascade -label "Symbol of vector location" -menu .mb.menu2.m.symbol10
.mb.menu2.m.symbols add cascade -label "Symbol of custom xys data 1" -menu .mb.menu2.m.symbol4
.mb.menu2.m.symbols add cascade -label "Symbol of custom xys data 2" -menu .mb.menu2.m.symbol5

menu .mb.menu2.m.cpolygon
.mb.menu2.m.cpolygon add command -label "Color of plate boundaries" \
    -command {change_color plate_color "Color of plate boundaries" .mb } 
.mb.menu2.m.cpolygon add command -label "Color of slab contours" \
    -command {change_color slab_contour_color "Color of slab contours" .mb }
.mb.menu2.m.cpolygon add command -label "Color of hotspot locations" \
    -command {change_color quake4_color "Color of hotspot locations" .mb }
.mb.menu2.m.cpolygon add command -label "Color of volcano locations" \
    -command {change_color quake5_color "Color of volcano locations" .mb }
.mb.menu2.m.cpolygon add command -label "Color of CMT beach balls" \
    -command {change_color quake3_color  "Color of CMT beach balls" .mb } 
.mb.menu2.m.cpolygon add command -label "Color of NGDS quakes" \
    -command {change_color quake1_color  "Color of NGDS quakes" .mb } 
.mb.menu2.m.cpolygon add command -label "Color of USGS/NEIC quakes" \
    -command {change_color site1_color "Color of USGS/NEIC quakes" .mb } 
.mb.menu2.m.cpolygon add command -label "Color of vector locations" \
    -command {change_color site1_color "Color of vector locations" .mb } 
.mb.menu2.m.cpolygon add command -label "Color of velocity vectors" \
    -command {change_color vector1_color  "Color of velocity vectors" .mb } 
.mb.menu2.m.cpolygon add command -label "Color of custom xys data 1" \
    -command {change_color custom1_color "Color of custom xys data" .mb } 
.mb.menu2.m.cpolygon add command -label "Color of custom xys data 2" \
    -command {change_color custom2_color "Color of custom xys data" .mb }


menu .mb.menu2.m.nametags
.mb.menu2.m.nametags add cascade -label "Hotspots" -menu .mb.menu2.m.hotspotnametag
.mb.menu2.m.nametags add cascade -label "Volcanoes"  -menu .mb.menu2.m.volcanonametag


menu .mb.menu2.m.hotspotnametag 
.mb.menu2.m.hotspotnametag  add radiobutton -label "On" -variable hotspot_nametag -value 1
.mb.menu2.m.hotspotnametag  add radiobutton -label "Off" -variable hotspot_nametag  -value 0

menu .mb.menu2.m.volcanonametag 
.mb.menu2.m.volcanonametag  add radiobutton -label "On" -variable volcano_nametag -value 1
.mb.menu2.m.volcanonametag  add radiobutton -label "Off" -variable volcano_nametag  -value 0



menu .mb.menu2.m.legend
.mb.menu2.m.legend add radiobutton -label "On" -variable legend -value 1
.mb.menu2.m.legend add radiobutton -label "Off" -variable legend -value 0

menu .mb.menu2.m.shade
.mb.menu2.m.shade add radiobutton -label "On" -variable shading -value 1
.mb.menu2.m.shade add radiobutton -label "Off" -variable shading -value 0




menu .mb.menu2.m.orient
.mb.menu2.m.orient add radiobutton -label "Portrait" -variable portrait -value 1
.mb.menu2.m.orient add radiobutton -label "Landscape" -variable portrait -value 0

menu .mb.menu2.m.gridlines
.mb.menu2.m.gridlines add radiobutton -label "On" -variable gridlines -value 1
.mb.menu2.m.gridlines add radiobutton -label "Off" -variable gridlines -value 0

menu .mb.menu2.m.xticks
foreach ticknum { 3 6 9 12 16 18 24 } {
    .mb.menu2.m.xticks add radiobutton -label "$ticknum divisions"  -variable ticks(1) -value $ticknum
}

menu .mb.menu2.m.yticks
foreach ticknum { 3 6 9 12 16 18 24 } {
    .mb.menu2.m.yticks add radiobutton  -label "$ticknum divisions" -variable ticks(2) -value $ticknum
}

menu .mb.menu2.m.mapscale
.mb.menu2.m.mapscale add radiobutton -label "On" -variable mapscale -value 1
.mb.menu2.m.mapscale add radiobutton -label "Off" -variable mapscale -value 0

menu .mb.menu2.m.annotation
.mb.menu2.m.annotation add radiobutton -label "On" -variable annotation -value 1
.mb.menu2.m.annotation add radiobutton -label "Off" -variable annotation -value 0

for { set i 1} { $i <= $nr_of_polygon_data } { incr i } {
    menu .mb.menu2.m.symbol$i 
    .mb.menu2.m.symbol$i add radiobutton -label "Star"    -variable symbol($i) -value "a"
    .mb.menu2.m.symbol$i add radiobutton -label "Circle"  -variable symbol($i) -value "c"
     .mb.menu2.m.symbol$i add radiobutton -label "Cross" -variable symbol($i) -value "x"
    .mb.menu2.m.symbol$i add radiobutton -label "Diamond" -variable symbol($i) -value "d"
    .mb.menu2.m.symbol$i add radiobutton -label "Triangle" -variable symbol($i) -value "t"
    .mb.menu2.m.symbol$i add radiobutton -label "Square" -variable symbol($i) -value "s"
}


################################################################################
# scripting menu part

menu .mb.menu4.m
.mb.menu4.m add command -label "Show GMT script" -command { show_file $batchfile filev .mb } -underline 0
.mb.menu4.m add command -label "Add stuff to the pscoast line" \
    -command { enter_pscoast_line .mb } -underline 0
.mb.menu4.m add command -label "Show script errors" -command { show_file $batcherr filev .mb } -underline 12
.mb.menu4.m add cascade -label "Show GMT logo" -menu .mb.menu4.m.logo
pack .mb.menu4

menu .mb.menu4.m.logo
.mb.menu4.m.logo add radiobutton -label "On" -variable show_gmt_logo -value 1
.mb.menu4.m.logo add radiobutton -label "Off" -variable show_gmt_logo  -value 0

################################################################################
# GMT man pages part

menu .mb.menu3.m
.mb.menu3.m add command -label "pscoast" -command {show_man_page pscoast .mb} -underline 2
.mb.menu3.m add command -label "psbasemap" -command {show_man_page psbasemap .mb}  -underline 2
.mb.menu3.m add command -label "pstext" -command {show_man_page pstext .mb}  -underline 2
.mb.menu3.m add command -label "psxy" -command {show_man_page psxy .mb}  -underline 2
.mb.menu3.m add command -label "psscale" -command {show_man_page psscale .mb}  -underline 2
.mb.menu3.m add command -label "grdimage" -command {show_man_page grdimage .mb}  -underline 0
pack .mb.menu3


################################################################################
# bindings of buttons to menu parts

bind . <Control-p> { mk_ps ; conv_ps; refresh_image }
bind . <Control-r> { enter_region }
bind . <Control-q> [ list exit_d  $parameter_filename $env(PWD) ]
bind . <Control-s> [ list save_parameters  .mb ]
bind . <Control-o> [ list load_parameters .mb ]
