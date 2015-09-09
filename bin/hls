##########################################################################
# Title      :	hls - special ls
# Author     :	Heiner Steven <heiner.steven@odn.de>
# Date       :	1994-10-10
# Requires   :	
# Category   :	File Utilities
# SCCS-Id.   :	@(#) hls	1.2 03/12/19
##########################################################################
# Description
#
##########################################################################

LsOpt="-CF"
if [ -t 1 ]
then exec ls $LsOpt "$@"
else exec ls "$@"
fi