
################################################################################
# igmt_init.tcl -- startup procedures
#
# part of the iGMT package
#
# $Id: igmt_init.tcl,v 1.4 2001/02/09 19:11:17 becker Exp becker $
#
################################################################################

# create some of the files as empty, make the future  script executable
# and check for write permissions

if { [catch "[ list exec touch $batcherr]" var ] } {
    puts "iGMT: Can't create $batcherr."
    puts "iGMT: Please make sure that you have write permission, e.g."
    puts "iGMT: change to your home directory."
    exit -1 
}
if { [catch "[ list exec touch $batchfile]" var ] } {
    puts "iGMT: Can't create $batchfile."
    puts "iGMT: Please make sure that you have write permission, e.g."
    puts "iGMT: change to your home directory."
    exit -1 
}

exec chmod u+x $batchfile





