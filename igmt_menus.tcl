

################################################################################
# igmt_menus.tcl -- set up the major menu bar and the sub menus
#
# part of the iGMT package
#
# $Id: igmt_menus.tcl,v 1.16 2001/08/08 15:50:01 becker Exp becker $
#
################################################################################


################################################################################
# master menubar
################################################################################

frame .mb 

menubutton .mb.menu1 -text "File" -menu .mb.menu1.m  \
        -underline 0
menubutton .mb.menu5 -text "Datasets" -menu .mb.menu5.m \
    -underline 0
menubutton .mb.menu2 -text "Data parameters" -menu .mb.menu2.m  \
        -underline 1
menubutton .mb.menu6 -text "Map parameters" -menu .mb.menu6.m  
menubutton .mb.menu4 -text "Script" -menu .mb.menu4.m -underline 0
menubutton .mb.menu3 -text "GMT help" -menu .mb.menu3.m -underline 0
button .mb.button2 -text "Map it!" -relief groove -underline 0 -command { 
    if { [ mk_ps ] } {   conv_ps; refresh_image  }}
button .mb.button1 -text "Quit" -relief groove -command {exit_d $parameter_filename $env(PWD) }  -underline 0
pack .mb.menu1 .mb.menu5 .mb.menu2 .mb.menu6 .mb.menu4 .mb.menu3 -side left
pack .mb.button2 .mb.button1 -side left -padx 8
pack .mb

################################################################################
# sub menus

################################################################################
# Plot/File menu part

menu .mb.menu1.m
.mb.menu1.m add command -label "Create PS & display GIF" \
    -command {mk_ps ; conv_ps; refresh_image} \
    -accelerator "Ctrl+p" -underline 0
.mb.menu1.m add command -label "Create PS file" \
    -command {mk_ps} -underline 7
.mb.menu1.m add command -label "Display PS file" \
    -command { dsp_ps $ps_filename } -underline 0
.mb.menu1.m add command -label "Create and display PS" \
    -command { mk_ps; dsp_ps $ps_filename } -underline 1
.mb.menu1.m add separator
.mb.menu1.m add command -label "Save PS file"  \
    -command [ list copy_file "Save the PS file as..." $ps_filename $env(HOME) .mb ] -underline 0 
.mb.menu1.m add command -label "Save GIF file" \
    -command [ list copy_file "Save the GIF file as..." $gif_filename $env(HOME) .mb ] 
.mb.menu1.m add separator
.mb.menu1.m add command -label "Save sript file as..." \
    -command [ list copy_file "Save the script file as..." $batchfile $env(HOME) .mb ]
.mb.menu1.m add separator
.mb.menu1.m add command -label "Load parameters" -command [ list load_parameters .mb ] \
    -underline 0 -accelerator "Ctrl+o"
.mb.menu1.m add command -label "Save parameters" -command [ list save_parameters  .mb ] \
    -underline 0 -accelerator "Ctrl+s"
.mb.menu1.m add cascade -label "Parameter file Format" -menu .mb.menu1.m.parfileformat
.mb.menu1.m add separator
.mb.menu1.m add command -label "Display manual" \
    -command { dsp_ps $igmt_root/manual.ps }
.mb.menu1.m add command -label "About iGMT/Help" -command [ list show_help .mb ]
.mb.menu1.m add separator
.mb.menu1.m add command -label "Quit" -command {exit_d $parameter_filename $env(PWD) } \
    -underline 0 -accelerator "Ctrl+q"
pack .mb.menu1

# sub menu to choose the parameter file version

menu .mb.menu1.m.parfileformat
foreach l_igmt_version { 1.1 1.2 } {
    .mb.menu1.m.parfileformat add radiobutton -label "iGMT v$l_igmt_version" \
	-variable parameter_file_format -value $l_igmt_version
}



################################################################################
# datasets part

menu .mb.menu5.m
.mb.menu5.m add command -label "Raster data selection" \
    -command {choose_raster_datasets .mb } \
    -underline 0
.mb.menu5.m add command -label "Polygon data selection"\
    -command {choose_polygon_datasets .mb} \
    -underline 0
.mb.menu5.m add separator
.mb.menu5.m add command -label "Change custom raster data file"   \
	-command {change_filename raster_data(7) "Change the custom raster data file..." .mb }
.mb.menu5.m add separator
.mb.menu5.m add command -label "Change CMT data file"   \
    -command {change_filename poly_data(6) "Change the CMT file (psvelomeca format) to..." .mb }
.mb.menu5.m add command -label "Change significant quake data file" \
    -command {change_filename poly_data(2) "Change the significant quake data file to..." .mb}
.mb.menu5.m add command -label "Change the USGS/NEIC data file" \
    -command {change_filename  poly_data(3) "Change the USGS/NEIC data file to..." .mb}
.mb.menu5.m add command -label "Change GPS velocity data file"   \
    -command {change_filename poly_data(10) "Change the velocity file to..." .mb }
.mb.menu5.m add command -label "Change WSM data file"   \
    -command {change_filename poly_data(15) "Change the WSM file to..." .mb }
.mb.menu5.m add command -label "Change vector field grd x component"   \
    -command {change_filename poly_data(19) "Change the v_x to ..." .mb }
.mb.menu5.m add command -label "Change vector field grd y component"   \
    -command {change_filename poly_data(20) "Change the v_y to ..." .mb }



.mb.menu5.m add command -label "Parameters custom xys 1" \
    -command { set_custom_xys_parameters 4 .mb } 
.mb.menu5.m add command -label "Parameters custom xys 2" \
    -command { set_custom_xys_parameters 5  .mb } 
pack .mb.menu5


################################################################################
# Data parameters menu part
################################################################################

menu .mb.menu2.m
# poscoast items
.mb.menu2.m add command -label "Pscoast polygon selection" -command {pscoast_features} -underline 8
.mb.menu2.m add cascade -label " pscoast coloring" \
    -menu .mb.menu2.m.pscoastcol
.mb.menu2.m add cascade -label " pscoast linewidth" -menu .mb.menu2.m.lwpscoast
# raster data related settings
.mb.menu2.m add separator
.mb.menu2.m add cascade -label "Legend raster data" \
    -menu .mb.menu2.m.legend 
.mb.menu2.m add command -label "Raster resolution" \
    -command {change_raster_resolution \
		  raster_resolution raster_bounds $raster_dataset .mb } -underline 1
.mb.menu2.m add command -label "Change colormap"   \
    -command {change_filename colormap "Change the raster colormap to..." .mb }
if { $gmt_version < $gmt_version_boundary } {
    .mb.menu2.m add command -label "Create colormap"   \
	-command [ list create_colormap   0 .mb ] 
} else {
    .mb.menu2.m add cascade -label "Create colormap" \
	-menu .mb.menu2.m.colormaptype
}
.mb.menu2.m add cascade -label "Shade raster data" \
    -menu .mb.menu2.m.shade

.mb.menu2.m add cascade -label "Contour lines" \
    -menu .mb.menu2.m.cont
.mb.menu2.m add command -label " color of contour lines" \
	-command {change_color contour_para 3 "Color of contour lines" .mb } 
.mb.menu2.m add cascade -label " width of contour lines" \
	-menu .mb.menu2.m.contlw
.mb.menu2.m add cascade -label " density of contour lines" \
	-menu .mb.menu2.m.contdens
.mb.menu2.m add cascade -label " annotation text size" \
	-menu .mb.menu2.m.contasize


# polygon data related
.mb.menu2.m add separator
.mb.menu2.m add cascade -label "Symbols polygon data" \
    -menu .mb.menu2.m.symbols
.mb.menu2.m add cascade -label "Sizes polygon data" \
    -menu .mb.menu2.m.sizes
.mb.menu2.m add cascade -label "Color polygon data" \
    -menu .mb.menu2.m.cpolygon
.mb.menu2.m add cascade -label "Linewidth polygon data" \
    -menu .mb.menu2.m.lwpolygon
.mb.menu2.m add cascade -label "Name tags" \
    -menu .mb.menu2.m.nametags
.mb.menu2.m add command -label "GPS velocity vector parameters" \
    -command { enter_vellook .mb } -underline 5
.mb.menu2.m add command -label "Vector field parameters" \
    -command { enter_velfield .mb } 
.mb.menu2.m add command -label "WSM parameters" \
    -command { enter_wsmspecs .mb } 
.mb.menu2.m add cascade -label "City type" \
    -menu .mb.menu2.m.citytype
pack .mb.menu2

# submenues of the data parameter menu part

menu .mb.menu2.m.lwpscoast
.mb.menu2.m.lwpscoast add cascade \
    -label "Coastline"            -menu .mb.menu2.m.lwpscoast.3
.mb.menu2.m.lwpscoast add cascade \
    -label "Rivers"               -menu .mb.menu2.m.lwpscoast.1
.mb.menu2.m.lwpscoast add cascade \
    -label "National boundaries"  -menu .mb.menu2.m.lwpscoast.2

foreach i { 1 2 3 } {
    menu .mb.menu2.m.lwpscoast.$i
    foreach  j { 0.25 0.5 1 2 3 4 5 6 } {
	.mb.menu2.m.lwpscoast.$i  add radiobutton -label "$j" \
	    -variable psc_linewidth($i) -value $j
    }
}
menu .mb.menu2.m.pscoastcol
.mb.menu2.m.pscoastcol add command -label "Sea" \
    -command {change_color pscoast_color 2 "Color of wet areas" .mb } 
.mb.menu2.m.pscoastcol add command -label "River" \
    -command {change_color pscoast_color 3 "Color of rivers" .mb } 


.mb.menu2.m.pscoastcol add command -label "Land" \
    -command {change_color pscoast_color 1 "Color of dry areas" .mb } 
.mb.menu2.m.pscoastcol add command -label "Shorelines" \
    -command {change_color pscoast_color 4 "Color of shorelines" .mb } 



menu .mb.menu2.m.lwpolygon
.mb.menu2.m.lwpolygon add cascade \
    -label "Plate boundaries" -menu .mb.menu2.m.lwpolygon.1
.mb.menu2.m.lwpolygon add cascade \
    -label "Slab contours" -menu .mb.menu2.m.lwpolygon.9
.mb.menu2.m.lwpolygon add cascade \
    -label "GPS velocity vectors" -menu .mb.menu2.m.lwpolygon.10
.mb.menu2.m.lwpolygon add cascade \
    -label "Field vectors" -menu .mb.menu2.m.lwpolygon.19
.mb.menu2.m.lwpolygon add cascade \
    -label "Stress vectors" -menu .mb.menu2.m.lwpolygon.15

for {set i 1} { $i <= $nr_of_polygon_data } {incr i } {
    menu .mb.menu2.m.lwpolygon.$i
    foreach j { 0.25 0.5 1 2 3 4 5 } {
	.mb.menu2.m.lwpolygon.$i add radiobutton -label "$j" \
	    -variable poly_linewidth($i) -value $j
    }
}
# polygon symbol sizes

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
.mb.menu2.m.sizes add command -label "Size of GPS vector locations" \
    -command {set_symbol_size 10 "GPS vector locations..." .mb}
.mb.menu2.m.sizes add command -label "Size of city locations" \
    -command {set_symbol_size 12 "City locations..." .mb}
.mb.menu2.m.sizes add command -label "Length of WSM vectors..." \
    -command {set_symbol_size 15 "WSM vector length..." .mb}
.mb.menu2.m.sizes add command -label "Size of custom polygon data 1" \
    -command {set_symbol_size 4 "Custom polygon data 1..." .mb }
.mb.menu2.m.sizes add command -label "Size of custom polygon data 2" \
    -command {set_symbol_size 5 "Custom polygon data 2..." .mb }

# polygon symbol types

menu .mb.menu2.m.symbols
.mb.menu2.m.symbols add cascade \
    -label "Symbol of hotspot locations"  \
    -menu .mb.menu2.m.symbols.symbol7
.mb.menu2.m.symbols add cascade \
    -label "Symbol of volcano locations"  \
    -menu .mb.menu2.m.symbols.symbol8
.mb.menu2.m.symbols add cascade \
    -label "Symbol of NGDC quakes"        \
    -menu .mb.menu2.m.symbols.symbol2
.mb.menu2.m.symbols add cascade \
    -label "Symbol of USGS/NEIC quakes"   \
    -menu .mb.menu2.m.symbols.symbol3
.mb.menu2.m.symbols add cascade \
    -label "Symbol of GPS vector location"    \
    -menu .mb.menu2.m.symbols.symbol10
.mb.menu2.m.symbols add cascade \
    -label "Symbol of city location"    \
    -menu .mb.menu2.m.symbols.symbol12
.mb.menu2.m.symbols add cascade \
    -label "Symbol of custom xys data 1"  \
    -menu .mb.menu2.m.symbols.symbol4
.mb.menu2.m.symbols add cascade \
    -label "Symbol of custom xys data 2"  \
    -menu .mb.menu2.m.symbols.symbol5

# polygon coloring

menu .mb.menu2.m.cpolygon
.mb.menu2.m.cpolygon add command \
    -label "Color of plate boundaries" \
    -command {change_color poly_color 1 "Color of plate boundaries" .mb } 
.mb.menu2.m.cpolygon add command \
    -label "Color of slab contours" \
    -command {change_color poly_color 9 "Color of slab contours" .mb }
.mb.menu2.m.cpolygon add command \
    -label "Color of hotspot locations" \
    -command {change_color poly_color 7 "Color of hotspot locations" .mb }
.mb.menu2.m.cpolygon add command \
    -label "Color of volcano locations" \
    -command {change_color poly_color 8 "Color of volcano locations" .mb }
.mb.menu2.m.cpolygon add cascade \
    -label "Color of quakes symbols ..." \
    -menu .mb.menu2.m.cpolygon.quakecolors
.mb.menu2.m.cpolygon add cascade \
    -label "Color of GPS velocity vectors ..." \
    -menu .mb.menu2.m.cpolygon.velcolors
.mb.menu2.m.cpolygon add command \
    -label "Color of vector field" \
    -command {change_color poly_color 19 "Color of vector field" .mb }
.mb.menu2.m.cpolygon add cascade \
    -label "Color of WSM vectors ..." \
    -menu .mb.menu2.m.cpolygon.wsmcolor
.mb.menu2.m.cpolygon add command \
    -label "Color of cities" \
    -command {change_color poly_color  12 "Color of cities" .mb } 
.mb.menu2.m.cpolygon add command \
    -label "Color of custom xys data 1" \
    -command {change_color poly_color 4 "Color of custom xys data" .mb } 
.mb.menu2.m.cpolygon add command \
    -label "Color of custom xys data 2" \
    -command {change_color poly_color 5 "Color of custom xys data" .mb }


# sub sub sub menus



menu .mb.menu2.m.cpolygon.quakecolors
.mb.menu2.m.cpolygon.quakecolors  add command -label "Color of CMT beach balls" \
    -command {change_color poly_color  6 "Color of CMT beach balls" .mb } 
.mb.menu2.m.cpolygon.quakecolors  add command -label "Color of NGDS quakes" \
    -command {change_color poly_color 2 "Color of NGDS quakes" .mb } 
.mb.menu2.m.cpolygon.quakecolors  add command -label "Color of USGS/NEIC quakes" \
    -command {change_color poly_color 3 "Color of USGS/NEIC quakes" .mb } 

menu .mb.menu2.m.cpolygon.velcolors
.mb.menu2.m.cpolygon.velcolors add command -label "Color of GPS site locations" \
    -command {change_color poly_color 10 "Color of GPS site locations" .mb } 
.mb.menu2.m.cpolygon.velcolors add command -label "Color of GPS velocity vectors" \
    -command {change_color poly_color 11 "Color of GPS velocity vectors" .mb } 

menu .mb.menu2.m.cpolygon.wsmcolor
.mb.menu2.m.cpolygon.wsmcolor  add command -label "Color of extensional mechanism" \
    -command {change_color poly_color 15 "Color of extensional site" .mb}
.mb.menu2.m.cpolygon.wsmcolor  add command -label "Color of strike-slip mechanism" \
    -command {change_color poly_color 16 "Color of strike-slip site" .mb}
.mb.menu2.m.cpolygon.wsmcolor  add command -label "Color of compressional mechanism" \
    -command {change_color poly_color 17 "Color of compressional site" .mb}
.mb.menu2.m.cpolygon.wsmcolor  add command -label "Color of undetermined mechanism" \
    -command {change_color poly_color 18 "Color of undetermined site" .mb}



# now sub-submenues

menu .mb.menu2.m.nametags
.mb.menu2.m.nametags add cascade -label "Hotspots" \
    -menu .mb.menu2.m.hotspotnametag
.mb.menu2.m.nametags add cascade -label "Volcanoes" \
    -menu .mb.menu2.m.volcanonametag
.mb.menu2.m.nametags add cascade -label "Cities"  \
    -menu .mb.menu2.m.citynametag

menu .mb.menu2.m.hotspotnametag 
.mb.menu2.m.hotspotnametag  add radiobutton -label "On" \
    -variable poly_parameter(7,1) -value 1
.mb.menu2.m.hotspotnametag  add radiobutton -label "Off" \
    -variable poly_parameter(7,1)  -value 0

menu .mb.menu2.m.volcanonametag 
.mb.menu2.m.volcanonametag  add radiobutton -label "On" \
    -variable poly_parameter(8,1) -value 1
.mb.menu2.m.volcanonametag  add radiobutton -label "Off" \
    -variable poly_parameter(8,1)  -value 0

menu .mb.menu2.m.citynametag 
.mb.menu2.m.citynametag   add radiobutton -label "On"\
    -variable poly_parameter(12,2) -value 1
.mb.menu2.m.citynametag   add radiobutton -label "Off"\
    -variable poly_parameter(12,2)  -value 0

menu .mb.menu2.m.citytype
.mb.menu2.m.citytype   add radiobutton -label "Major" \
    -variable poly_parameter(12,1) -value 0
.mb.menu2.m.citytype   add radiobutton -label "All" \
    -variable poly_parameter(12,1)  -value 1

menu .mb.menu2.m.legend
.mb.menu2.m.legend add radiobutton -label "On" \
    -variable legend -value 1
.mb.menu2.m.legend add radiobutton -label "Off" \
    -variable legend -value 0

menu .mb.menu2.m.shade
.mb.menu2.m.shade add radiobutton -label "On" \
    -variable shading -value 1
.mb.menu2.m.shade add radiobutton -label "Off" \
    -variable shading -value 0
#
# contour main switches
menu .mb.menu2.m.cont
.mb.menu2.m.cont add radiobutton -label "Off" \
    -variable contour_para(1) -value 0
.mb.menu2.m.cont add radiobutton -label "Overlay" \
    -variable contour_para(1) -value 1
.mb.menu2.m.cont add radiobutton -label "Solely" \
    -variable contour_para(1) -value 2
# contour linewidth
menu .mb.menu2.m.contlw
foreach j { 0.25 0.5 1 2 3 4 5 } {
    .mb.menu2.m.contlw add radiobutton -label "$j" \
	    -variable contour_para(2) -value $j
}
# contour density
menu .mb.menu2.m.contdens
foreach j { 0.25 0.5 1.0 2.0 5.0 10.0 } {
    .mb.menu2.m.contdens add radiobutton -label "$j" \
	    -variable contour_para(4) -value $j
}
# contour annotation size
menu .mb.menu2.m.contasize
foreach j { - 8 10 12 14 18 24 32 } {
    if { $j == "-" } { 
	.mb.menu2.m.contasize add radiobutton -label "(off)" \
		-variable contour_para(5) -value $j
    } else { 
	.mb.menu2.m.contasize add radiobutton -label "$j" \
		-variable contour_para(5) -value $j
    }
}


if { $gmt_version >= $gmt_version_boundary } {
    menu .mb.menu2.m.colormaptype
    .mb.menu2.m.colormaptype add command -label "cool scheme" \
	-command [ list create_colormap  1  .mb ]
    .mb.menu2.m.colormaptype add command -label "copper scheme" \
	-command [ list create_colormap 2  .mb ]
    .mb.menu2.m.colormaptype add command -label "gebco scheme" \
	-command [ list create_colormap    3  .mb ]
    .mb.menu2.m.colormaptype add command -label "gray  scheme" \
	-command [ list create_colormap    4  .mb ]
    .mb.menu2.m.colormaptype add command -label "haxby scheme" \
	-command [ list create_colormap    5  .mb ]
    .mb.menu2.m.colormaptype add command -label "hot scheme" \
	-command [ list create_colormap    6  .mb ]
    .mb.menu2.m.colormaptype add command -label "jet scheme" \
	-command [ list create_colormap    7  .mb ]
    .mb.menu2.m.colormaptype add command -label "polar scheme" \
	-command [ list create_colormap    8  .mb ]
    .mb.menu2.m.colormaptype add command -label "rainbow scheme" \
	-command [ list create_colormap    9  .mb ]
    .mb.menu2.m.colormaptype add command -label "red2green scheme" \
	-command [ list create_colormap    10  .mb ]
    .mb.menu2.m.colormaptype add command -label "relief scheme" \
	-command [ list create_colormap    11  .mb ]
    .mb.menu2.m.colormaptype add command -label "topo scheme" \
	-command [ list create_colormap    12  .mb ]
    .mb.menu2.m.colormaptype add command -label "sealand scheme" \
	-command [ list create_colormap    13  .mb ]
}

for { set i 1} { $i <= $nr_of_polygon_data } { incr i } {
    menu .mb.menu2.m.symbols.symbol$i 
    .mb.menu2.m.symbols.symbol$i \
	    add radiobutton -label "Star"     -variable poly_symbol($i) -value "-Sa"
    .mb.menu2.m.symbols.symbol$i \
	    add radiobutton -label "Circle"   -variable poly_symbol($i) -value "-Sc"
    .mb.menu2.m.symbols.symbol$i \
	    add radiobutton -label "Cross"    -variable poly_symbol($i) -value "-Sx"
    .mb.menu2.m.symbols.symbol$i \
	    add radiobutton -label "Diamond"  -variable poly_symbol($i) -value "-Sd"
    .mb.menu2.m.symbols.symbol$i \
	    add radiobutton -label "Triangle" -variable poly_symbol($i) -value "-St"
    .mb.menu2.m.symbols.symbol$i \
	    add radiobutton -label "Square"   -variable poly_symbol($i) -value "-Ss"
    .mb.menu2.m.symbols.symbol$i \
	    add radiobutton -label "Line"     -variable poly_symbol($i) -value "-Lo"
    .mb.menu2.m.symbols.symbol$i \
	    add radiobutton -label "Closed polygon"     -variable poly_symbol($i) -value "-Lc"
}

################################################################################
# mapping parameters menu 


menu .mb.menu6.m
# general mapping
.mb.menu6.m add command -label "Region" -command {enter_region} -accelerator "Ctrl+r" -underline 0
.mb.menu6.m add command -label "Projection" -comman {change_projection} -underline 0
#special mapping settings
.mb.menu6.m add separator
.mb.menu6.m add cascade -label "Grid lines" -menu .mb.menu6.m.gridlines
.mb.menu6.m add cascade -label "Frame annotation" -menu .mb.menu6.m.annotation
.mb.menu6.m add cascade -label "Longitudinal tick intervals" -menu .mb.menu6.m.xticks
.mb.menu6.m add cascade -label "Latitudinal tick intervals" -menu .mb.menu6.m.yticks
.mb.menu6.m add cascade -label "Mapscale" -menu .mb.menu6.m.mapscale
# postscript output settings
.mb.menu6.m add separator
.mb.menu6.m add command -label "Plot title" -command { enter_title_line  .mb }  -underline 0
.mb.menu6.m add command -label "Page size" -command { enter_papersize .mb } -underline 5
.mb.menu6.m add cascade -label "PS Page orientation" -menu .mb.menu6.m.orient
.mb.menu6.m add command -label "PS page offsets" -command { enter_offsets .mb } 
pack .mb.menu2

################################################################################
# sub menus of mapping parameter menu part

menu .mb.menu6.m.gridlines
.mb.menu6.m.gridlines add radiobutton -label "On" -variable gridlines -value 1
.mb.menu6.m.gridlines add radiobutton -label "Off" -variable gridlines -value 0

menu .mb.menu6.m.xticks
foreach ticknum { 3 6 9 12 16 18 24 } {
    .mb.menu6.m.xticks add radiobutton -label "$ticknum divisions"  \
	-variable ticks(1) -value $ticknum
}

menu .mb.menu6.m.yticks
foreach ticknum { 3 6 9 12 16 18 24 } {
    .mb.menu6.m.yticks add radiobutton  -label "$ticknum divisions" \
	-variable ticks(2) -value $ticknum
}

menu .mb.menu6.m.mapscale
.mb.menu6.m.mapscale add radiobutton -label "Fancy" -variable mapscale -value 2
.mb.menu6.m.mapscale add radiobutton -label "Plain" -variable mapscale -value 1
.mb.menu6.m.mapscale add radiobutton -label "Off" -variable mapscale -value 0




menu .mb.menu6.m.annotation
.mb.menu6.m.annotation add radiobutton -label "On four sides" -variable annotation -value 1
.mb.menu6.m.annotation add radiobutton -label "On two sides" -variable annotation -value 2
.mb.menu6.m.annotation add radiobutton -label "Off" -variable annotation -value 0


menu .mb.menu6.m.orient
.mb.menu6.m.orient add radiobutton -label "Portrait" -variable portrait -value 1
.mb.menu6.m.orient add radiobutton -label "Landscape" -variable portrait -value 0



################################################################################
# scripting menu part

menu .mb.menu4.m
.mb.menu4.m add command -label "Show GMT script" \
    -command { show_file $batchfile filev .mb } -underline 0

.mb.menu4.m add command -label "Show script errors" \
    -command { show_file $batcherr filev .mb } -underline 12

.mb.menu4.m add command -label "Save sript file as..." \
    -command [ list copy_file "Save the script file as..." $batchfile $env(HOME) .mb ]

.mb.menu4.m add command -label "Add stuff to the pscoast line" \
    -command { enter_pscoast_line .mb } -underline 0

.mb.menu4.m add cascade -label "Set GMT version" \
    -menu .mb.menu4.m.gmtversion

.mb.menu4.m add cascade -label "Add GMT logo" -menu .mb.menu4.m.logo
pack .mb.menu4

menu .mb.menu4.m.gmtversion 
foreach l_gmt_version { 3.4 4.0 } {
    .mb.menu4.m.gmtversion add radiobutton -label "$l_gmt_version" \
	-variable gmt_version -value $l_gmt_version \
	-command [list adjust_settings_to_gmt_version $l_gmt_version ] 
}

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
if { $gmt_version < $gmt_version_boundary } {
    .mb.menu3.m add command -label "psvelomeca" -command {show_man_page psvelomeca .mb}  -underline 0
} else {
    .mb.menu3.m add command -label "psvelo" -command {show_man_page psvelo .mb}  -underline 0
    .mb.menu3.m add command -label "psmeca" -command {show_man_page psmeca .mb}  -underline 0
}
.mb.menu3.m add command -label "grdimage" -command {show_man_page grdimage .mb}  -underline 0
.mb.menu3.m add command -label "grdcontour" -command {show_man_page grdcontour .mb}  -underline 0
.mb.menu3.m add command -label "grd2cpt" -command {show_man_page grd2cpt .mb}  -underline 0

pack .mb.menu3


################################################################################
# bindings of buttons to menu parts

bind . <Control-p> { mk_ps ; conv_ps; refresh_image }
bind . <Control-r> { enter_region }
bind . <Control-q> [ list exit_d  $parameter_filename $env(PWD) ]
bind . <Control-s> [ list save_parameters  .mb ]
bind . <Control-o> [ list load_parameters .mb ]
