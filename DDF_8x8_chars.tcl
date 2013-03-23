# DDF_8x8_chars.tcl
#
# Desc: This file contains proceedures for displaying characters
#
# Exam: *** Connection to DDF_Module must already be established ***
#       Call procedures in this file to update display arrays to show an image
#       Call DDF_Display to update display
#
# Note:

# Global Variables

# 8x8 Font size
set char_a												""

# Procedures

# Serial_Connect <Serial_Port> - Returns fid to the Serial Port

# Serial_Connect <Serial_Port> - Returns fid to the Serial Port
# 
# Desc: Establishes a serial port connection to a designated COM port


{{0 255 0 0 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
 {0 255 0 0 0 0 0 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
 {0 255 0 0 255 0 0 0 0 0 0 255 0 0 255 0 0 0 0 0 0 0 0 0} 
 {0 255 0 0 0 0 0 255 0 0 0 255 0 0 0 0 0 0 0 0 0 0 0 0} 
 {0 255 0 0 255 0 0 0 0 0 0 255 0 0 255 0 0 0 0 0 0 0 0 0} 
 {0 0 0 0 0 0 0 0 0 0 0 255 0 0 0 0 255 0 0 255 0 0 255 0} 
 {0 0 0 0 0 0 0 0 0 0 0 255 0 0 255 0 255 0 0 0 0 0 255 0} 
 {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 0 0 0 0 0 255 0}}