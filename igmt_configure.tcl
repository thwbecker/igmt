
################################################################################
# igmt_configure.tcl -- global variables and default settings
# change path names and other things here, not anywhere else
# better still: use a igmt_siteconfig.tcl file to reset the variables
# of your choice. this file gets read in (if it exists) so that you can
# override our defaults.
#
# global variables were chosen for simplicity, so if you introduce new ones
# check here
#
#
# most common changes:
#
# - gmt binary location: lower_version_gmtbins and higher_version_gmtbins
#	change these to point to the location of the 
#	GMT binaries
# 
# - rasterpath variable (line ~220), to point to the main directory that holds 
#   the raster data
#
# you can put both these changes into the igmt_siteconfig.tcl file
#
#
# part of the iGMT package
#
# $Id: igmt_configure.tcl,v 1.19 2004/09/03 01:58:13 becker Exp becker $
################################################################################



################################################################################
# path issues and filenames 
################################################################################

# find the iGMT distribution here

set igmt_root $env(igmt_root)


# let $user be the user's name for temporary files

if { ( [ catch { set user $env(USER) } ] ) || ( $user == "" ) } {
    if { ( [ catch { set user $env(LOGNAME) } ] ) || ( $user == "" )  } {
	    puts "iGMT: Couldn't determine the user's name, neither"
	    puts "iGMT: \$USER or \$LOGNAME was set to nonzero length."
	    puts "iGMT: Since the user name is needed for tmp files,"
	    puts "iGMT: exit here."
	    exit
	}
}

#
# set this variable to 3.4 or 4.0 for different versions
#
# also changes the different pathnames that might be selected
# during runtime
# also make sure that the $GMTHOME variable is set 
#
#set gmt_version 3.4
#set gmt_version 4.5.18
set gmt_version 6

# this is the boundary between older and newer versions of GMT
# if you have set gmt_version to anything larger or equal that 
# boundary, iGMT will
# - search for GMT binaries in the higher version directory (see below)
#
set gmt_version_boundary 4.0

# for swith to 6
set gmt_upper_version_boundary 5

# set gmtbins to the path of the gmt commands if they are not in
# the shell search path, else use ""
#
# INCLUDE THE FINAL "/"
#
set lower_version_gmtbins "/usr/local/src/GMT3.4.5/bin/"

# if you want, supply different binary location as a function of the
# version number, changes when version is higher than $gmt_version_boundary

#set higher_version_gmtbins "/home/walter/twb/progs/src/gmt-4.5.18//bin//"
set higher_version_gmtbins "/home/twb/progs/src/gmt/build_laptop/bin/"
#set higher_version_gmtbins "/usr/bin/"

# in igmt.tcl, gmtbins will be set to either path depending on the chosen
# GMT version

# if you do not have the man pages in the usual place
# set this variable to you appropriate path with an "-M" up front such as
# set gmtmanpath "-M /home/me/myman/gmt/man"

set gmtmanpath ""


# the shell we use for scripting should be the bash shell
# otherwise you have to modify some commands in the helper apps
# start the filename after the exclamation mark
# please note that this variable has changed in 1.1, it used to 
# include the \#! part which has now moved to the scripts

set shell_to_use "/bin/bash"


# default awk-type program, if gawk not available, use nawk
# for better math performance

set our_awk gawk

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
# grid related
set temp_grid_filename [ format /tmp/igmt_%s_tmp.grd $user ]
set temp_shade_filename [ format /tmp/igmt_%s_tmp.shade $user ]
# contour interval file
set temp_cont_int_filename [ format igmt_%s.cint $user ]


# file to save the GMT script commands in

set batchfile "$igmt_files_are_in/igmt_commands.gmt"

# file to store the GMT errors

set batcherr [ format /tmp/igmt_%s_gmt_err.txt $user ]


# parameter file version, default is iGMT version 1.2 format

set parameter_file_format 1.2



################################################################################
# tool commands for postscript viewing and converting
################################################################################

# postscript viewer

set psviewer "ghostview"


# command line for viewing a postscript file in portrait orientation

set psviewer_command_portrait "$psviewer -orientation=portrait"

# what command line parameter switches to a rotated view ?

set psviewer_command_landscape "$psviewer -orientation=portrait"

# for using ghostview add the following lines (without the comment sign "#") in
#  your igmt_siteconfig.tcl file

# set psviewer "ghostview"
# set psviewer_command_portrait "$psviewer -portrait"
# set psviewer_command_landscape "$psviewer -landscape"

# or the gs equivalent

# set psviewer_command_portrait "$psviewer -q"
# set psviewer_command_landscape "$psviewer -q"

# for using showps

# set psviewer "showps"
# set psviewer_command_portrait "$psviewer -or portrait"
# set psviewer_command_landscape "$psviewer -or landscape"


# PS to GIF converter
#
#
set ps_to_gif_converter "/usr/bin/convert"

# if silly error messages give you a hard time, set this to unity
# if you want error message checking, leave it at zero 

set no_convert_complaints 0

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
# filename concerning all data sets and plotting
################################################################################
# where to find the colormaps (.cpt) files for GMT
set colorpath "$igmt_root/colormaps"
#
# principal base directory for raster data 
#
set rasterpath "/home/walter/twb/data"


################################################################################
# generic GMT scripting defaults 
################################################################################

# set this to "-V" for verbose GMT messages

set verbose "-V"
# what is the default name of the colormap that grd2cpt
# creates from a grd-file?
set new_colormap "new.cpt"
    
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


# should we check for the availability of raster datasets?

set check_for_raster_availability 1

set nr_of_raster_data 20
# initialize variables with default values
for { set i 1 } { $i <= $nr_of_raster_data } { incr i } {
    set raster_colormap($i) "$colorpath/topo.cpt"
    set raster_data($i) -1
    # default raster data settings
    # geographical bounds
    set raster_bounds($i,1) -180 
    set raster_bounds($i,2) 180 
    set raster_bounds($i,3) -90 
    set raster_bounds($i,4) 90 
    # by default, allow non-integer boundaries
    set raster_bounds($i,5) 0
    # resolution limit in minutes
    set raster_bounds($i,6) 5
    # allow resampling 
    set raster_bounds($i,7) 1
}


# raster data set number to start with as described below
# described below
# raster datasets are mutually exclusive, that is you can
# only select one at a time. 

# by default, just use pscoast land/sea coverage, that is use 
# raster dataset 1
set raster_dataset 1

# resolution in arc minutes for the raster data sets
set raster_resolution 60

# legend beneath the raster plots
set legend 1

# shading using grdgradient, by default off
set shading 0
#
# Contouring of grd files
#
# contours off/overlay/solely (0/1/2)
set contour_para(1) 0
# width of non-annotated contour lines, annotated will be twice that
set contour_para(2) 2
# color of contour lines
set contour_para(3,1) 0; set contour_para(3,2) 0; set contour_para(3,3) 0
# contour density, normalized to 1
set contour_para(4) 1.0
# contour annotation width
set contour_para(5) 14

################################################################################
# R1: dataset one means pscoast

# R1: colors for pscoast

# land
set pscoast_color(1,1) 200 ; set pscoast_color(1,2) 180 ;  set pscoast_color(1,3) 150
# sea
set pscoast_color(2,1) 190 ; set pscoast_color(2,2) 200 ; set pscoast_color(2,3) 230
# river
set pscoast_color(3,1) 0 ; set pscoast_color(3,2) 0 ; set pscoast_color(3,3) 255 ;
# coastline
set pscoast_color(4,1) 0 ; set pscoast_color(4,2) 0 ; set pscoast_color(4,3) 0 ; 
# R1: pscoast options to start with

# R1: map resolution of shorelines, l means 'low', see pscoast

set resolution "l"


# R1: show shoreline
set shoreline 0


# R1: show different rivers
set river(1) 0 ; set river(2) 0 ; set river(3) 0 ; set river(4) 0

# this is for wet areas in general 
set river(5) 0;

# R1: river linewidth
set psc_linewidth(1) 1


# R1: pscoast boundary toggles
set boundary(1) 0 ; set boundary(2) 0

# R1: boundary linewidth
set psc_linewidth(2) 3

# pscoast coastline linewdith
set psc_linewidth(3) 1

# R1: additions to the pscoast line
set pscoast_add ""
set raster_colormap(1) "$colorpath/topo.cpt"

# R2: ETOPO5 is plotted by using grdraster, so options here for data set two
# minimum resolution
set raster_bounds(2,6) 5
# only integer bounds
set  raster_bounds(2,5) 1

# R2+3: colormap for the topography datasets
set raster_colormap(2) "$colorpath/topo.cpt"

################################################################################
# R3: GTOPO 30, data set three
set raster_data(3) "\$rasterpath/gtopo30/topo_8.2.img"
set raster_colormap(3) "$colorpath/topo.cpt"
# geographical bounds of dataset
set raster_bounds(3,1) -180; set raster_bounds(3,2) 180; 
set raster_bounds(3,3) -72; set raster_bounds(3,4) 72; 
# integer boundaries only?
set  raster_bounds(3,5) 1
# resolution limit in minutes
set  raster_bounds(3,6) 0.5

################################################################################
# R4: sea floor age, data set four
set raster_data(4) "\$rasterpath/seafloor_age/age.3.6.grd"
set raster_colormap(4) "$colorpath/seafloor_age.cpt"
# geographical bounds of dataset
set raster_bounds(4,1) -180; set raster_bounds(4,2) 180; 
set raster_bounds(4,3) -70; set raster_bounds(4,4) 90; 
# no resampling
set  raster_bounds(4,7) 0

################################################################################
# R5: gravity, data set five
# R5: which gravity dataset for the free air gravity over sea?
#
set raster_data(5) "\$rasterpath/gravity/grav.img.15.2"
#
set raster_colormap(5) "$colorpath/gravity.cpt"
# geographical bounds of dataset
set raster_bounds(5,1) -180; set raster_bounds(5,2) 180; 
set raster_bounds(5,3) -72; set raster_bounds(5,4) 72; 
# integer boundaries only?
set  raster_bounds(5,5) 1
# resolution limit in minutes
set  raster_bounds(5,6) 0.5

################################################################################
# R6: Geoid data grd file
set raster_data(6) "\$rasterpath/geoid/egm360.h.0.5.grd"
set raster_colormap(6) "$colorpath/geoid.cpt"
# resolution limit in minutes
set  raster_bounds(6,6) 30


################################################################################
# R7: custom data set, can be changed from the default by user
set raster_data(7) $raster_data(4)
set raster_colormap(7) $raster_colormap(2)
# set any of the possible restrictions here (see above), or use the defaults:
# -180/180/-90/90 range, allowing floating point boundaries,
# allowing resampling, min resolution 5 minutes
#


################################################################################
# R8: sediment thickness of Laske and Masters (1997)
set raster_data(8) "\$rasterpath/crust/laske_master_sediment/sedmap_interpolated.grd"
set raster_colormap(8) "$colorpath/sediment.cpt"
# resolution limit in minutes
set  raster_bounds(8,6) 60


# R9: which gravity dataset for the global free air gravity model?
set raster_data(9) "\$rasterpath/geoid/egm360.e.grav.grd"
set raster_colormap(9) "$colorpath/gravity.cpt"
# resolution limit in minutes
set  raster_bounds(9,6) 30


################################################################################
# R10/11: seismic hazard map plotting

set raster_data(10) "\$rasterpath/hazard/gshap_globe.0.1.grd"
set raster_colormap(10) "$colorpath/gshap.cpt"
set raster_colormap(11) "$colorpath/blue.cpt"
# resolution limit in minutes
set  raster_bounds(10,6) 6
# only integer bounds because of ETOPO5
set  raster_bounds(10,5) 1


################################################################################
# R12: ETOPO1 topography data as grid file
set raster_data(12) "\$rasterpath/etopo1/ETOPO1_Bed_g_gmt4.grd"
set raster_colormap(12) $raster_colormap(2)
# resolution limit in minutes
set  raster_bounds(12,6) 1



################################################################################
# add new raster data starting from 13 here, we made reservations until 20



# raster handling matters

# if you are using img data sets from Sandwell & Smith and img2latlongrd
# is not available, set this to 1 so that the GMT batch file
# img2grd  is used instead
#
set use_img2latlon_batch 1



################################################################################




################################################################################
# POLYGON DATA STUFF
################################################################################

# set this to the maximum number of polygon data sets used 
# it will allocate the variables that are used to pass polygon plotting
# parameters as listed in the following routine
# if you add a polygon dataset, increment this number, if needed

set nr_of_polygon_data 25
# max nr of additional polygon parameters
set nr_of_polygon_parameters 10
# initialize the common variables, some are redefined later, otherwise they 
# remain dummies

for { set i 1 } { $i <= $nr_of_polygon_data } { incr i } {
    # symbol type
    set poly_symbol($i) "-Sa"
    # size of symbol in fractions of map width
    set poly_symbol_size($i) 0.02
    # linewidth of feature
    set poly_linewidth($i) 0
    # data set is on/off, at start all are off
    set polygon_dataset($i) 0
    # colors in RGB scheme
    foreach j { 1 2 3 } { set poly_color($i,$j) 0 }
    # other parameters, right now we allow for ten in total
    for { set j 0} { $j <= $nr_of_polygon_parameters } { incr j } {
	set poly_parameter($i,$j) 0
    }
}

    

################################################################################
# P1: data set one, plate boundaries

# P1: default setting for plotting is off, change to 1 when the data set should 
# P1: be shown from teh start
# P1: location of the polygon data

set poly_data(1) "$igmt_root/nuvel.yx"

# P1: colorsettings
set poly_color(1,1) 255 
set poly_color(1,2) 255  
set poly_color(1,3) 255
# P1: linewidth for the plate boundaries
set poly_linewidth(1) 2


################################################################################
# P2: data set two, significant eathquakes as provided by NDGC ca 2000

# P2: same as for polygon data set 1 

# P2: earthquakes
set poly_symbol_size(2) 0.02
set poly_data(2) "\$rasterpath/quakes/significant_ngdc.2000.dat"
set poly_color(2,1) 254 
set poly_color(2,2) 0
set poly_color(2,3) 0
# P2: default symbol
set poly_symbol(2) "-Sd" 


################################################################################
# P3: data set three, hypocenter data from USGS/NEIC from ca. 2000

# P3: same settings as for data set 2
set poly_symbol_size(3) 0.02
set poly_data(3) "\$rasterpath/quakes/usgs_neic.dat"
set poly_color(3,1) 0 
set poly_color(3,2) 0 
set poly_color(3,3) 254
set poly_symbol(3) "-Sc"


################################################################################
# P4 and P5  custom data sets one and two 
foreach i { 4 5 } {
    set poly_color($i,1) 0 
    set poly_color($i,2) 0 
    set poly_color($i,3) 0
    set poly_symbol($i) "-Sc"
    set poly_symbol_size($i) 0.02

    # the following parameters can be set in the Datasets/Parameters custom xys menu
    # plotting parameters for awk
    # column numbers for x, y  and size (if size blank, fixed size)
    set poly_parameter($i,1) 1
    set poly_parameter($i,2) 2
    set poly_parameter($i,3) ""
    # size multiplier
    set poly_parameter($i,4) 0.05
    # P$i: filename for the custom xys data file one
    set poly_parameter($i,5) ""
}



################################################################################
# P6: CMT solutions
set poly_data(6) "$igmt_root/01_02-98.cmt"
set poly_color(6,1) 0 
set poly_color(6,2) 0 
set poly_color(6,3) 0
set poly_symbol_size(6) 0.02


################################################################################
# P7: Hot spots of Steinberger
set poly_data(7) "$igmt_root/hotspots.dat"
set poly_color(7,1) 255 
set poly_color(7,2) 0 
set poly_color(7,3) 255
# hotspot nametag on/off
set poly_parameter(7,1) 1
set poly_symbol(7) "-Sc"
set poly_symbol_size(7) 0.2


################################################################################
# P8: volcanoes from the Smithsonian institution
set poly_data(8) "$igmt_root/volcanoes.dat"
set poly_color(8,1) 255  
set poly_color(8,2) 0  
set poly_color(8,3) 0
# volcano nametag on/off
set poly_parameter(8,1) 0
set poly_symbol(8) "-Sd"
set poly_symbol_size(8) 0.2


################################################################################
# P9: seismicity contours used to define the upper edge of subducting plates
set poly_data(9) "$igmt_root/allslabs_rum.gmt"
set poly_color(9,1) 0 
set poly_color(9,2) 0 
set poly_color(9,3) 0; 
set poly_linewidth(9) 1


################################################################################
# P10/11: Velocity solutions using psvelomeca
# contribution of Simon McClusky
set poly_data(10) "$igmt_root/gps.vel"
# velocity scale
set poly_parameter(10,1) 1.0
# uncertainty scale
set poly_parameter(10,2) 1.0
# confidence interval
set poly_parameter(10,3) 0.95
# font for site description
set poly_parameter(10,4) 10
# maxsigma error bars for selection of data
set poly_parameter(10,5) 3.0
#  vecscale, 20 mm/yr for reference vector
set poly_parameter(10,6) 20

set poly_linewidth(10) 2
# site locations, colors and symbols
set poly_color(10,1) 0  
set poly_color(10,2) 0  
set poly_color(10,3) 0
set poly_symbol(10) "-St"
set poly_symbol_size(10) 0.01
# vectors colors
set poly_color(11,1) 0  
set poly_color(11,2) 0  
set poly_color(11,3) 0



################################################################################
# P12/13: Major city locations and names

set poly_data(12) "$igmt_root/wcity_major.dat"
set poly_data(13) "$igmt_root/wcity.dat"
set poly_color(12,1) 0  
set poly_color(12,2) 0  
set poly_color(12,3) 128
# city type 
set poly_parameter(12,1) 1
# city nametag 
set poly_parameter(12,2) 1
set poly_symbol(12) "-Sa"; 
set poly_symbol_size(12) 0.15

################################################################################
# P14: shorelines
# for programming convenience, shorelines have been assigned number 14


################################################################################
# P15/16/17/18: stress field orientations as in the 
# WSM by Zoback et al.

set poly_data(15) "\$rasterpath/wsm/wsm2005.csv"

# vector length
set poly_symbol_size(15) 0.05
# colors of data site vectors derived from extensional, strike-slip, 
# compressional, and undetermined earthquake mechanism
# extensional 
set poly_color(15,1) 0 ; set poly_color(15,2) 0 ; set poly_color(15,3) 255 ; 
# strike slip
set poly_color(16,1) 0 ; set poly_color(16,2) 255 ; set poly_color(16,3) 0 ; 
# compressive
set poly_color(17,1) 255 ; set poly_color(17,2) 0 ; set poly_color(17,3) 0 ; 
# undetermiened
set poly_color(18,1) 0 ; set poly_color(18,2) 0 ; set poly_color(18,3) 0 ; 

# set wsm_type(i) to 1 if you want to include 
# i=1 data points derived from CMT solutions
# i=2 borehole breakouts
# i=3 hydro frac
# i=4 overcoring
# i=5 geological
#  wsm types (1/0 means on and off for the different types of data) 
set poly_parameter(15,1) 1
foreach i { 2 3 4 5 } { set poly_parameter(15,$i) 0; }
# linewidth for vectors
set poly_linewidth(15) 0.5
# plot all stress indicators with quality better than i, whereas 
# i==1 means A, i==2 means B, ... and i==4 means D
# wsm quality 
set poly_parameter(15,6) 2
# 1: different style (arrow heads) for extension and compression
# 2: only show the compressional axis
# wsm plotstyle 
set poly_parameter(15,7) 1

################################################################################
# P19/20: velocity vectors as given by two grid files with x/y components
set poly_data(19) "\$rasterpath/plates/hs2_nuvel.vx.2.-1.grd"
set poly_data(20) "\$rasterpath/plates/hs2_nuvel.vy.2.-1.grd"
# color of velocity vectors
set poly_color(19,1) 0 ; set poly_color(19,2) 0 ; set poly_color(19,3) 0 ; 
# linewidth for vectors
set poly_linewidth(19) 1
# scaling
set poly_parameter(19,1) 1.0
# reference vector length in data units
set poly_parameter(19,2) 1
# units of data for reference scale
set poly_parameter(19,3) "cm/yr"
# spacing of vectors in degrees
set poly_parameter(19,4) "5"
# show reference vector?
set poly_parameter(19,5) 1
# color of reference vectors
set poly_color(20,1) 0 ; set poly_color(20,2) 0 ; set poly_color(20,3) 254 ; 
# linewidth for reference vector
set poly_linewidth(20) 4



################################################################################
# add new polygon files here from 21, we made reservations until P25







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

set colormap  $raster_colormap(2)


