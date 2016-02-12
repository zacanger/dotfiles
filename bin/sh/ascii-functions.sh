#!/bin/bash

#For some reason a bunch of ascii control characters are valid
#characters for function declarations in bash
#man 7 ascii on *nix systems
#DEC Col/Row Oct Hex Name and Description

#2  00/02   02  02  STX  (Ctrl-B)  START OF TEXT
(){
	echo "Start of text"
}



#3  00/03   03  03  ETX  (Ctrl-C)  END OF TEXT
(){
	echo "End of text"
}



#4  00/04   04  04  EOT  (Ctrl-D)  END OF TRANSMISSION
(){
	echo "End of transmission"
}



#5  00/05   05  05  ENQ  (Ctrl-E)  ENQUIRY
(){
	echo "Enquiry"
}



#6  00/06   06  06  ACK  (Ctrl-F)  ACKNOWLEDGE
(){
	echo "Acknowledge"
}



#7  00/07   07  07  BEL  (Ctrl-G)  BELL
(){
	echo "Beep beep motherfucker"
}



#8  00/08   10  08  BS   (Ctrl-H)  BACKSPACE
(){
	echo "Backspace"
}



#11  00/11   13  0B  VT   (Ctrl-K)  VERTICAL TAB
(){
	echo "Vertical tab"
}



#12  00/12   14  0C  FF   (Ctrl-L)  FORM FEED
(){
	echo "Form feed"
}



#13  00/13   15  0D  CR   (Ctrl-M)  CARRIAGE RETURN

(){
	echo "Carriage Return"
}



#14  00/14   16  0E  SO   (Ctrl-N)  SHIFT OUT
(){
	echo "Shift out"
}



#15  00/15   17  0F  SI   (Ctrl-O)  SHIFT IN
(){
	echo "Shift in"
}



#16  01/00   20  10  DLE  (Ctrl-P)  DATA LINK ESCAPE
(){
	echo "Data link escape"
}



#17  01/01   21  11  DC1  (Ctrl-Q)  DEVICE CONTROL 1 (XON)
(){
	echo "Device control 1 (xon)"
}



#18  01/02   22  12  DC2  (Ctrl-R)  DEVICE CONTROL 2
(){
	echo "Device control 2"
}



#19  01/03   23  13  DC3  (Ctrl-S)  DEVICE CONTROL 3 (XOFF)
(){
	echo "Device control 3 (xoff)"
}



#20  01/04   24  14  DC4  (Ctrl-T)  DEVICE CONTROL 4
(){
	echo "Device control 4"
}



#21  01/05   25  15  NAK  (Ctrl-U)  NEGATIVE ACKNOWLEDGE
(){
	echo "Negative Acknowledge"
}



#22  01/06   26  16  SYN  (Ctrl-V)  SYNCHRONOUS IDLE
(){
	echo "Synchronous idle"
}



#23  01/07   27  17  ETB  (Ctrl-W)  END OF TRANSMISSION BLOCK
(){
	echo "End of transmission block"
}



#24  01/08   30  18  CAN  (Ctrl-X)  CANCEL
(){
	echo "Cancel"
}



#25  01/09   31  19  EM   (Ctrl-Y)  END OF MEDIUM
(){
	echo "End of medium"
}



#26  01/10   32  1A  SUB  (Ctrl-Z)  SUBSTITUTE
(){
	echo "Substitute"
}



#27  01/11   33  1B  ESC  (Ctrl-[)  ESCAPE
(){
	echo "Escape"
}



#28  01/12   34  1C  FS   (Ctrl-\)  FILE SEPARATOR
(){
	echo "File separator"
}



#29  01/13   35  1D  GS   (Ctrl-])  GROUP SEPARATOR
(){
	echo "Group separator"
}



#30  01/14   36  1E  RS   (Ctrl-^)  RECORD SEPARATOR
(){
	echo "Record Separator"
}



#31  01/15   37  1F  US   (Ctrl-_)  UNIT SEPARATOR
(){
	echo "Unit separator"
}



