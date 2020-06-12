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
# igmt_configure.tcl -- global variables and default settings
# change path names and other things here, not anywhere else
# 
# global variables were chosen for simplicity, so if you introduce new ones
# check here
#
# part of the iGMT package
#
################################################################################



################################################################################
# path issues and filenames 
################################################################################

# find the iGMT distribution here

set igmt_root $env(igmt_root)


# let user be the user's name for temporary files

if { [ catch { set user $env(USER) } ] } {
    if { [ catch { exec id -un } user ]} {
	puts "iGMT: Couldn't determine the user's name, neither"
	puts "iGMT: \$USER was set or \"id -un\" worked."
	puts "iGMT: Since the user name is used for tmp files,"
	puts "iGMT: Exit here."
	exit
    }
}

# set gmtbins to the path of the gmt commands if they are not in
# the shell search path, else use ""

set gmtbins ""


# the shell we use for scripting should be the korn shell
# otherwise you have to modify some commands in the helper apps

set shell_to_use "\#!/bin/ksh"

# change this for the default location to put the script file iGMT creates

set igmt_files_are_in "$env(PWD)"

# default startup image

set def_gif_filename "$igmt_root/igmt_def.gif"

# default file to save plotting parameters in

set parameter_filename "$igmt_files_are_in/igmt_parameters.dat"

# temporary file names, we need some user specific name else 
# problems with permissions would arise
# if you change the default location from /tmp/igmt_*
# you might have to take care to remove the temporary files yourself
#

set ps_filename [ format /tmp/igmt_%s_tmp.ps $user ]

# change this line for instance to 
# set gif_filename [ format /tmp/igmt_%s_tmp.ppm $user ]
# if you want iGMT and convert to work with ppm files instead
set gif_filename [ format /tmp/igmt_%s_tmp.gif $user ]

set grid_filename [ format /tmp/igmt_%s_grd $user ]
set shade_filename [ format /tmp/igmt_%s_shade $user ]

# file to save the GMT script commands in

set batchfile "$igmt_files_are_in/igmt_commands.gmt"

# file to store the GMT errors

set batcherr [ format /tmp/igmt_%s_gmt_err.txt $user ]


################################################################################
# tool commands for postscript viewing and converting
################################################################################

# postscript viewer

#set psviewer "showps"

# command line for viewing a postscript file in portrait orientation

#set psviewer_command_portrait "$psviewer -or portrait"

# what command line parameter switches to a rotated view ?

#set psviewer_command_landscape "$psviewer -or landscape"

# for using ghostview add the following lines (without the comment sign "#") in
#  your igmt_siteconfig.tcl file

 set psviewer "ghostview"

# for ghostviewv you would furthermore add

 set psviewer_command_portrait "$psviewer -portrait"
 set psviewer_command_landscape "$psviewer -landscape"

# or the gs equivalent

# set psviewer_command_portrait "$psviewer -q"
# set psviewer_command_landscape "$psviewer -q"


# PS to GIF converter

set ps_to_gif_converter "convert"
set converter_rotate_command "-rotate"

set ps_to_gif_command_portrait "$ps_to_gif_converter $converter_rotate_command   0 $ps_filename $gif_filename"
set ps_to_gif_command_landscape "$ps_to_gif_converter $converter_rotate_command  90 $ps_filename $gif_filename"

# for using gs instead of convert put the next four lines (or something like them)
#  in your igmt_siteconfig.tcl file (this assumes that you have the gif conversion included in
#  your compilation of ghostscript, if not (for copyright reasons) use "ppmraw" instead of "gif8")
# set ps_to_gif_converter "gs"
# set ps_to_gif_command "$ps_to_gif_converter -q -sDEVICE=gif8 -sOutputFile=$gif_filename - < $ps_filename 2> /dev/null"
# set ps_to_gif_command_portrait $ps_to_gif_command
# set ps_to_gif_command_landscape $ps_to_gif_command 


################################################################################
# generic GMT scripting defaults 
################################################################################

# set this to "-V" for verbose GMT messages

set verbose "-V"

# where do I find the colormaps 

set colorpath "$igmt_root/colormaps"

# set this to 1 to use pstext for plot titles instead of the -B option 

    
set use_pstext_for_title 0


# title for the plot

set plot_title ""
set title_font_size 24

# GMT font numbers

set title_font 1 

# see the pstext -L command:
#         Font #  Font Name
#         ------------------------------------
#           0     Helvetica
#           1     Helvetica-Bold
#           2     Helvetica-Oblique
#           3     Helvetica-BoldOblique
#           4     Times-Roman
#           5     Times-Bold
#           6     Times-Italic
#           7     Times-BoldItalic
#           8     Courier
#           9     Courier-Bold
#          10     Courier-Oblique
#          11     Courier-BoldOblique
#          12     Symbol
#          13     AvantGarde-Book
#          14     AvantGarde-BookOblique
#          15     AvantGarde-Demi
#          16     AvantGarde-DemiOblique
#          17     Bookman-Demi
#          18     Bookman-DemiItalic
#          19     Bookman-Light
#          20     Bookman-LightItalic
#          21     Helvetica-Narrow
#          22     Helvetica-Narrow-Bold
#          23     Helvetica-Narrow-Oblique
#          24     Helvetica-Narrow-BoldOblique
#          25     NewCenturySchlbk-Roman
#          26     NewCenturySchlbk-Italic
#          27     NewCenturySchlbk-Bold
#          28     NewCenturySchlbk-BoldItalic
#          29     Palatino-Roman
#          30     Palatino-Italic
#          31     Palatino-Bold
#          32     Palatino-BoldItalic
#          33     ZapfChancery-MediumItalic


################################################################################
# RASTER DATASETS SETTINGS
################################################################################

# in general, 1 means switch is on, 0 means off

# raster data set number  to start with
# described below

set raster_dataset 1

# set principal data path if any

#set rasterpath "/wrk/arthur/becker/global_data"
set rasterpath "/data3/stdrel/maps"

# resolution in arc minutes for the raster data sets

set raster_resolution 60

# legend beneath the raster plots

set legend 1

# shading using grdgradient

set shading 1


################################################################################
# R1: dataset one means pscoast

# R1: colors for pscoast

set land_color(1) 0 ; set land_color(2) 200 ;  set land_color(3) 0
set sea_color(1) 0 ; set sea_color(2) 0 ; set sea_color(3) 200
set river_color(1) 0 ; set river_color(2) 0 ; set river_color(3) 255 ;

# R1: pscoast options to start with

# R1: resolution of boundaries etc.

set resolution "c"

# R1: show shoreline

set shoreline 0

# R1: show different rivers

set river(1) 0 ; set river(2) 0 ; set river(3) 0 ; set river(4) 0

# R1: river linewidth

set psc_linewidth(1) 1

# R1: pscoast boundary toggles
set boundary(1) 0 ; set boundary(2) 0

# R1: boundary linewidth
set psc_linewidth(2) 3


# R1: additions to the pscoast line

set pscoast_add ""


# R2: ETOPO5 is plotted by using grdraster, so options here for data set two

# R2+3: colormap for the topography datasets
set topocolor "$colorpath/topo.cpt"

################################################################################
# R3: GTOPO 30, data set three


# R3: where find the Smith&Sandwell/GTOPO30 data set?
set gtopodata "$rasterpath/gtopo30/topo_6.2.img"

################################################################################
# R4: sea floor age, data set four

# R4: colormap for seafloor age
set agecolor "$colorpath/seafloor_age.cpt"
# R4: which seafloor age dataset should be used ?
set agedata "$rasterpath/seafloor_age/globalage_1.3.grd"

################################################################################
# R5: gravity, data set five

# R5: colormap for gravity
set gravitycolor "$colorpath/gravity.cpt"

# R5: which gravity dataset for the free air gravity over sea?

set freeair_grav_data "$rasterpath/gravity/world_grav.img.7.2"



################################################################################
# R6: Geoid data grd file

set geoid_data "$rasterpath/geoid/osu91a1f.grd"
set geoidcolor "$colorpath/geoid.cpt"



################################################################################
# R7: custom data set, can be changed from the default by user

set custom_raster_data $agedata



################################################################################
# POLYGON DATA STUFF
################################################################################

# set this to the maximum number of polygon data sets used (needed for symbol,
# symbol_size and pol_linewidth

set nr_of_polygon_data 10

# initialize the common variables, some are redefined later, otherwise they 
# remain dummies

for { set i 0} { $i <= $nr_of_polygon_data } { incr i } {
    # symbol type
    set symbol($i) "a"
    # size of symbol in fractions of map width
    set symbol_size($i) 0.0
    # linewidth of feature
    set pol_linewidth($i) 0
    # data set is on/off, at start all are off
    set polygon_dataset($i) 0
}

    

################################################################################
# P1: data set one, plate boundaries

# P1: default setting for plotting is off, change to 1 when the data set should 
# P1: be shown from scratch


# P1: location of the polygon data

set plate_boundary_data "$igmt_root/nuvel.yx"

# P1: colorsettings

set plate_color(1) 255 ; set plate_color(2) 255 ; set plate_color(3) 255

# P1: linewidth for the plate boundaries
set pol_linewidth(1) 3


################################################################################
# P2: data set two, significant eathquakes as provided by NDGC


# P2: same as for polygon data set 1 


# P2: earthquakes
set symbol_size(2) 0.0005
set xysize_data(1) "$rasterpath/quakes/significant_ngdc.dat"
set quake1_color(1) 0 ; set quake1_color(2) 0 ; set quake1_color(3) 0
# P2: default symbol
set symbol(2) "a" 


################################################################################
# P3: data set three, hypocenter data from USGS/NEIC


# P3: same settings as for data set 2
set symbol_size(3) 0.0005
set xysize_data(2) "$rasterpath/quakes/usgs_neic.dat"
set quake2_color(1) 0 ; set quake2_color(2) 0 ; set quake2_color(3) 0
set symbol(3) "c"




################################################################################
# P4: custom data set one starts here

# P4: same as above for 3
set custom1_color(1) 0 ; set custom1_color(2) 0 ; set custom1_color(3) 0
set symbol(4) "c"
set symbol_size(4) 0.05

# P4: the following parameters can be set in the Datasets/Parameters custom xys menu
# P4: plotting parameters for awk
set custom1(1) 1 ; set custom1(2) 2 ; set custom1(3) 3; set custom1(4) 0.05
# P4: filename for the custom xys data file one
set custom1(5) ""


################################################################################
# P5: custom data set two starts here, same as for custom one
set symbol_size(5) 0.05
set custom2_color(1) 0 ; set custom2_color(2) 0 ; set custom2_color(3) 0
set symbol(5) "c"
# P5: plotting parameters for awk
set custom2(1) 1 ; set custom2(2) 2 ; set custom2(3) 3; set custom2(4) 0.05
# P5: filename for the custom xys data file one
set custom2(5) ""





################################################################################
# P6: CMT solutions
set cmtdata "$igmt_root/01_02-98.cmt"
set quake3_color(1) 0 ; set quake3_color(2) 0 ; set quake3_color(3) 0
set symbol_size(6) 0.02





################################################################################
# P7: Hot spots of Steinberger
set hotspotdata "$igmt_root/hotspots.dat"
set quake4_color(1) 255 ; set quake4_color(2) 0 ; set quake4_color(3) 0
set hotspot_nametag 1
set symbol(7) "a"
set symbol_size(7) 0.005


################################################################################
# P8: volcanoes from the Smithsonian institution
set volcanodata "$igmt_root/volcanoes.dat"
set quake5_color(1) 255 ; set quake5_color(2) 0 ; set quake5_color(3) 0
set volcano_nametag 0
set symbol(8) "a"
set symbol_size(8) 0.005


################################################################################
# P9: seismicity contours used to define the upper edge of subducting plates
set slab_contour_data "$igmt_root/allslabs_rum.gmt"
set slab_contour_color(1) 0; set slab_contour_color(2) 0; set slab_contour_color(3) 0; 
set pol_linewidth(9) 1


################################################################################
# P10: Velocity solutions
set veldata "$igmt_root/gps.vel"
set velscale(1) 1.0; set uncscale(1) 1.0; set confint(1) 0.95; set sitefont(1) 7
set maxsigma(1) 3.0; set vecscale(1) 20; set pol_linewidth(10) 2
set vector1_color(1) 0 ; set vector1_color(2) 0 ; set vector1_color(3) 0
set symbol(10) "t"; set symbol_size(10) 0.050
set site1_color(1) 0 ; set site1_color(2) 0 ; set site1_color(3) 0


################################################################################
# startup values for mapping stuff
################################################################################

# starting boundaries for the geographic region

set north 10.0
set south -10.0
set east 10.0
set west -10.0

# map center for whole earth plots

set lat0 0
set lon0 0

# startup projection

set proj(1) "M"

# latitudinal limits for the Mercator projection

set mercatorlimit(1) 75
set mercatorlimit(2) -75

# default custom projection

set custom_projection "-JX10"

#map tick intervals x and y axis

set ticks(1) 6 ; set ticks(2) 6

#lines criss-crossing the map
set gridlines 0

#boundary annotation

set annotation 1


set mapscale 0

# papersize x y in inches, use 8.5 and 11 for letter
#  or 8 and 10 for A4

set papersize(1) 8.5 ; set papersize(2) 11

# page orientation, 0 means landscape

set portrait 1


# x offset for postscript plot

set ps_offset(1) 1.0

# y offset

set ps_offset(2) 1.0

# GMT logo is off by default since it would interfere with the colorbars

set show_gmt_logo 0



################################################################################
# misc. global variables not to be changed by the user
# in the first place
################################################################################


# this is set to zero when parameters are changed

set saved 1

# this is the starting header line

set headermessage "iGMT"

# this will be the batch jobs process id, now its iGMT's

set batch_pid [ pid ]


# colormap to begin with, can be changed by user and
# is adjusted when the raster data set is changed.

set colormap  $topocolor
