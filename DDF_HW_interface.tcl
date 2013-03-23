# DDF_HW_interface.tcl
#
# Desc: This file contains procedures for connecting/disconnecting to DDF Modules and Updating the display
#
# Exam: Use DDF_Connect to connect to a DDF_Module
#       Then Modify the Display using Modify_Display_Array
#       Update the display with DDF_Display
#       Use DDF_Disconnect to disconnect from DDF_Module
#
# Note: DDF_Module information is stored in global variables, like COM port
#       Display_Rotation allows individual DDF_Modules to<p align="justify"></p> be rotated for convenience

# Global Variables

# COM Ports
set DDF_Module_0_COM						COM1
set DDF_Module_1_COM						--
set DDF_Module_2_COM						--
set DDF_Module_3_COM						--

# DDF File Handle - file handle to open COM ports
set DDF_FH_0                    --
set DDF_FH_1                    --
set DDF_FH_2                    --
set DDF_FH_3                    --

# Serial Port Options
set baudRate    								56000;
set parity      								"n";    # n=none, o=odd, e=even, m=mark, s=space
set numDataBits 								8;
set numStopBits 								1;

# Serial Stream
set DDF_SS_0										--
set DDF_SS_1										--
set DDF_SS_2										--
set DDF_SS_3										--

# Display Array - Initialized with all LEDs off (In List Format)
set Display_Array_0							--
set Display_Array_1							--
set Display_Array_2							--
set Display_Array_3							--

# Display Rotations - Clock-wise rotation 0 = 0 degrees, 1 = 90 degrees, 2 = 180 degrees, 3 = 270 degrees
set Display_Rotation_0						1
set Display_Rotation_1						0
set Display_Rotation_2						0
set Display_Rotation_3						0

# Number Graphics Used To Identify DDF_Modules and their rotation (Rotation = 0)
set idZero  "F F F F F F F F F F 0 F F 0 F F F F F F F F F F F F 0 F F 0 F F F F F F F F F F F F 0 F F 0 F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F F 0 0 F F F F F 0 F F 0 F F F F F 0 0 F F F F F 0 F F 0 F F F F F 0 0 F F F F F 0 F F 0 F F"
set idOne   "F F F F F F F F F F 0 F F F F F F F F F F F F F F F 0 F F F F F F F F F F F F F F F 0 F F F F F F F 0 F F 0 F F F F 0 F F F F F F F 0 F F 0 F F F F 0 F F F F F F F 0 F F 0 F F F F 0 F F F F F F F 0 F F F F F F F F F F 0 F F F F 0 F F F F F F F F F F 0 F F F F 0 F F F F F F F F F F 0 F F F F 0 F F F F F F F 0 F 0 0 F F F F 0 F F F F F F F 0 F 0 0 F F F F 0 F F F F F F F 0 F 0 0 F F"
set idTwo   "F F F F F F F F F F 0 F F 0 F F F F F F F F F F F F 0 F F 0 F F F F F F F F F F F F 0 F F 0 F F F F F 0 0 F F F F F F 0 F F F F F F F 0 0 F F F F F F 0 F F F F F F F 0 0 F F F F F F 0 F F F F F F 0 F F F F F F F 0 F F F F F F F 0 F F F F F F F 0 F F F F F F F 0 F F F F F F F 0 F F F F F F F F F 0 F F F F F 0 0 0 0 F F F F F F 0 F F F F F 0 0 0 0 F F F F F F 0 F F F F F 0 0 0 0 F F"
set idThree "F F F F F F F F F F 0 F F 0 F F F F F F F F F F F F 0 F F 0 F F F F F F F F F F F F 0 F F 0 F F F F F 0 0 F F F F F F 0 F F F F F F F 0 0 F F F F F F 0 F F F F F F F 0 0 F F F F F F 0 F F F F F F 0 F F F F F F F F F 0 F F F F F 0 F F F F F F F F F 0 F F F F F 0 F F F F F F F F F 0 F F F F F F 0 0 F F F F F 0 F F 0 F F F F F 0 0 F F F F F 0 F F 0 F F F F F 0 0 F F F F F 0 F F 0 F F"
# Procedures

# Serial_Connect <Serial_Port> - Returns fid to the Serial Port
# Serial_Tx <Serial_Port> <data>
# DDF_Connect <DDF_Module_Number>
# DDF_Disconnect <DDF_Module_Number>
# DDF_Display <DDF_Module_Number>
# Modify_Display_Array <DDF_Module_Number> <x> <y> <red> <green> <blue> - Writes Color to array entry
# Modify_Display_Array <DDF_Module_Number> <x> <y> - Reads color from array entry
# Color_Display_Array <DDF_Module_Number> <red> <green> <blue>
# Blank_Display_Array <DDF_Module_Number>
# Remove_Spaces <thelist>
# DDF_Auto_Connect
# DDF_Auto_Disconnect


# Serial_Connect <Serial_Port> - Returns fid to the Serial Port
# 
# Desc: Establishes a serial port connection to a designated COM port
proc Serial_Connect {args} {
	global baudRate parity numDataBits numStopBits
	# Check number of arguments
	if {[llength $args] != 1} {
		error "Error: Serial_Connect, Wrong number of arguments."
	}
	# Open the Serial Port
	if {[catch {open [lindex $args 0] WRONLY} serialPort]} {
		error [format "Error: Serial_Connect, Could not open %s" [lindex $args 0]]
	}
	# Configure Serial Port
	fconfigure $serialPort -mode $baudRate,$parity,$numDataBits,$numStopBits
	fconfigure $serialPort -blocking 1
	fconfigure $serialPort -buffering full
	fconfigure $serialPort -buffersize 16384
	fconfigure $serialPort -translation binary
	fconfigure $serialPort -translation {binary binary}
	fconfigure $serialPort -handshake none
	fconfigure $serialPort -sysbuffer {4096 16384}
	
	# Return the file ID to the serial port
	return $serialPort
}

# Serial_Tx <Serial_Port> <data>
#
# Desc: Transmits to the specified Serial Port fid 
#       (No error checking)
proc Serial_Tx {args} {
	chan puts -nonewline [lindex $args 0] [binary format H* [lindex $args 1]]
	flush [lindex $args 0]
}

# DDF_Connect <DDF_Module_Number>
# Desc: Establishes a connection to a designated DDF module
proc DDF_Connect {args} {
	global DDF_FH_0 DDF_FH_1 DDF_FH_2 DDF_FH_3 DDF_Module_0_COM DDF_Module_1_COM DDF_Module_2_COM DDF_Module_3_COM
	# Check number of arguments
	if {[llength $args] != 1} {
		puts [format "Usage: DDF_Connect DDF_Module_Number"]
		error "Error: DDF_Connect, Wrong number of arguments."
	}
	# Check if already connected, if not connect
	if {[lindex $args 0] == 0} {
		if {$DDF_FH_0 == "--"} {
			set DDF_FH_0 [Serial_Connect $DDF_Module_0_COM];
		} else {
			error [format "Error: DDF_Connect, DDF Module %i already connected." [lindex $args 0]]
		}
	} elseif {[lindex $args 0] == 1} {
		if {$DDF_FH_1 == "--"} {
			set DDF_FH_1 [Serial_Connect $DDF_Module_1_COM];
		} else {
			error [format "Error: DDF_Connect, DDF Module %i already connected." [lindex $args 0]]
		}
	} elseif {[lindex $args 0] == 2} {
		if {$DDF_FH_2 == "--"} {
			set DDF_FH_2 [Serial_Connect $DDF_Module_2_COM];
		} else {
			error [format "Error: DDF_Connect, DDF Module %i already connected." [lindex $args 0]]
		}
	} elseif {[lindex $args 0] == 3} {
		if {$DDF_FH_3 == "--"} {
			set DDF_FH_3 [Serial_Connect $DDF_Module_3_COM];
		} else {
			error [format "Error: DDF_Connect, DDF Module %i already connected." [lindex $args 0]]
		}
	} else {
		error [format "Error: DDF_Connect, Could not open connection to %i." [lindex $args 0]]
	}
}

# DDF_Disconnect <DDF_Module_Number>
# Desc: Establishes a connection to a designated DDF module
proc DDF_Disconnect {args} {
	global DDF_FH_0 DDF_FH_1 DDF_FH_2 DDF_FH_3
	# Check number of arguments
	if {[llength $args] != 1} {
		puts [format "Usage: DDF_Disconnect <DDF_Module_Number>"]
		error "Error: DDF_Disconnect, Wrong number of arguments."
	}
	# Close Connection
	if {[lindex $args 0] == 0} {
		if {$DDF_FH_0 != "--"} {
			close $DDF_FH_0;
			set DDF_FH_0 --
		} else {
			error [format "Error: DDF_Disconnect, DDF Module %i is not connected." [lindex $args 0]]
		}
	} elseif {[lindex $args 0] == 1} {
		if {$DDF_FH_1 != "--"} {
			close $DDF_FH_1;
			set DDF_FH_1 --
		} else {
			error [format "Error: DDF_Disconnect, DDF Module %i is not connected." [lindex $args 0]]
		}
	} elseif {[lindex $args 0] == 2} {
		if {$DDF_FH_2 != "--"} {
			close $DDF_FH_2;
			set DDF_FH_2 --
		} else {
			error [format "Error: DDF_Disconnect, DDF Module %i is not connected." [lindex $args 0]]
		}
	} elseif {[lindex $args 0] == 3} {
		if {$DDF_FH_3 != "--"} {
			close $DDF_FH_3;
			set DDF_FH_3 --
		} else {
			error [format "Error: DDF_Disconnect, DDF Module %i is not connected." [lindex $args 0]]
		}
	} else {
		error "Error: DDF_Disconnect, Could not close connection."
	}
}

# DDF_Display <DDF_Module_Number>
# Desc: Updates the display of a DDF_Module
#
# The Display Array consists of 96 bytes. Each byte is divided into two nybbles,
# where the lower nybble defines the 4-bit color information for one color LED in a given square and the 
# upper nybble defines the next square. [binary format H* 00]
#  Sqr     10    32    54    76    98  1110  1312  1514
#  Red   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#  Green 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#  Blue  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#
#  Sqr   1716  1918  2120  2322  2524  2726  2928  3130
#  Red   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#  Green 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#  Blue  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#
#  Sqr   3332  3534  3736  3938  4140  4342  4544  4746
#  Red   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#  Green 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#  Blue  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#
#  Sqr   4948  5150  5352  5554  5756  5958  6160  6362
#  Red   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#  Green 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
#  Blue  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
proc DDF_Display {args} {
	global DDF_FH_0 DDF_FH_1 DDF_FH_2 DDF_FH_3 Display_Array_0 Display_Array_1 Display_Array_2 Display_Array_3 DDF_SS_0
	# Check number of arguments
	if {[llength $args] != 1} {
		puts [format "Usage: DDF_Display <DDF_Module_Number>"]
		error "Error: DDF_Display, Wrong number of arguments."
	}
	# Update Display	
	if {[lindex $args 0] == 0} {
		Serial_Tx $DDF_FH_0 [format "000010%s" [Remove_Spaces $Display_Array_0]]
	} elseif {[lindex $args 0] == 1} {
		Serial_Tx $DDF_FH_1 [format "000010%s" [Remove_Spaces $Display_Array_1]]
	} elseif {[lindex $args 0] == 2} {
		Serial_Tx $DDF_FH_2 [format "000010%s" [Remove_Spaces $Display_Array_2]]
	} elseif {[lindex $args 0] == 3} {
		Serial_Tx $DDF_FH_3 [format "000010%s" [Remove_Spaces $Display_Array_3]]
	} else {
		error [format "Error: DDF_Display, Could not update display for DDF Module %i." [lindex $args 0]]
	}
}



# Modify_Display_Array <DDF_Module_Number> <x> <y> <red> <green> <blue> - Writes Color to array entry
# Modify_Display_Array <DDF_Module_Number> <x> <y> - Reads color from array entry
#
# Desc: Allows Display array to be easily indexed
# Exam: Modify_Display_Array 0 0 0 F F F
#                     x
#       0   1   2   3   4   5   6   7 
#     ---------------------------------
#   0 |RGB|RGB|RGB|RGB|RGB|RGB|RGB|RGB|
#     ---------------------------------
#   1 |RGB|RGB|RGB|RGB|RGB|RGB|RGB|RGB|
#     ---------------------------------
#   2 |RGB|RGB|RGB|RGB|RGB|RGB|RGB|RGB|
#     ---------------------------------
#   3 |RGB|RGB|RGB|RGB|RGB|RGB|RGB|RGB|
# y   ---------------------------------
#   4 |RGB|RGB|RGB|RGB|RGB|RGB|RGB|RGB|
#     ---------------------------------
#   5 |RGB|RGB|RGB|RGB|RGB|RGB|RGB|RGB|
#     ---------------------------------
#   6 |RGB|RGB|RGB|RGB|RGB|RGB|RGB|RGB|
#     ---------------------------------
#   7 |RGB|RGB|RGB|RGB|RGB|RGB|RGB|RGB|
#     ---------------------------------
proc Modify_Display_Array {args} {
	global Display_Array_0 Display_Array_1 Display_Array_2 Display_Array_3 Display_Rotation_0 Display_Rotation_1 Display_Rotation_2 Display_Rotation_3
	# Check Arguments
	if {[llength $args] != 3} {
		if {[llength $args] != 6} {
			puts "Usage 1: Modify_Display_Array <DDF_Module_Number> <x> <y> <red> <green> <blue> - Writes Color to array entry"
			puts "Usage 2: Modify_Display_Array <DDF_Module_Number> <x> <y> - Reads color from array entry"
			error [format "Error: Modify_Display_Array, Wrong number of arguments"]
		} else {
			set red     [lindex $args 3]
			set green   [lindex $args 4]
			set blue    [lindex $args 5]
		}
	}
	# Local Variables
	set DDF_Num [lindex $args 0]
	set x       [lindex $args 1]
	set y       [lindex $args 2]

	# Rotate Index if needed
	if {$DDF_Num == 0} {
		for {set i 0} {$i < $Display_Rotation_0} {incr i} {
			set tempY $y
			set y $x
			set x [lindex {7 6 5 4 3 2 1 0} $tempY]
		}
	} elseif {$DDF_Num == 1} {
		for {set i 0} {$i < $Display_Rotation_1} {incr i} {
			set tempY $y
			set y $x
			set x [lindex {7 6 5 4 3 2 1 0} $tempY]
		}
	} elseif {$DDF_Num == 2} {
		for {set i 0} {$i < $Display_Rotation_2} {incr i} {
			set tempY $y
			set y $x
			set x [lindex {7 6 5 4 3 2 1 0} $tempY]
		}
	} elseif {$DDF_Num == 3} {
		for {set i 0} {$i < $Display_Rotation_3} {incr i} {
			set tempY $y
			set y $x
			set x [lindex {7 6 5 4 3 2 1 0} $tempY]
		}
	} else {
		error [format "Error: Modify_Display_Array, Invalid DDF_Module number %i." $DDF_Num]
	}
	# Check that X is valid
	if {$x > 7} {
		error [format "Error: Modify_Display_Array, (%i,%i) Invalid Index" $x $y]
	} elseif {$x < 0} {
		error [format "Error: Modify_Display_Array, (%i,%i) Invalid Index" $x $y]
	}
	# Check that Y is valid
	if {$y > 7} {
		error [format "Error: Modify_Display_Array, (%i,%i) Invalid Index" $x $y]
	} elseif {$y < 0} {
		error [format "Error: Modify_Display_Array, (%i,%i) Invalid Index" $x $y]
	}
	# Check if X is even or odd
	if {[expr $x & 0x1] == 1} {
		# Odd
		set x [expr $x - 1]
	} else {
		# Even
		set x [expr $x + 1]
	}
	# Check if Y is even or odd
	if {[expr $y & 0x1] == 1} {
		# Odd
		if {$y < 4} {set xFactor [expr (7 - $x)]} else {set xFactor $x}
		set yFactor [expr (($y - 1) * 16)]
	} else {
		# Even
		if {$y < 4} {set xFactor $x} else {set xFactor [expr (7 - $x)]}
		set yFactor [expr ($y * 16)]
	}
	# Find color indicies
	set redIndex   [expr ($y * 8) + $xFactor + $yFactor]
	set greenIndex [expr ($y * 8) + $xFactor + $yFactor + 16]
	set blueIndex  [expr ($y * 8) + $xFactor + $yFactor + 32]
	if {[llength $args] == 6} {
		# Edit red, green, and blue entries
		if {$DDF_Num == 0} {
			set Display_Array_0 [lreplace $Display_Array_0 $redIndex   $redIndex   $red]
			set Display_Array_0 [lreplace $Display_Array_0 $greenIndex $greenIndex $green]
			set Display_Array_0 [lreplace $Display_Array_0 $blueIndex  $blueIndex  $blue]
		} elseif {$DDF_Num == 1} {
			set Display_Array_1 [lreplace $Display_Array_1 $redIndex   $redIndex   $red]
			set Display_Array_1 [lreplace $Display_Array_1 $greenIndex $greenIndex $green]
			set Display_Array_1 [lreplace $Display_Array_1 $blueIndex  $blueIndex  $blue]
		} elseif {$DDF_Num == 2} {
			set Display_Array_2 [lreplace $Display_Array_2 $redIndex   $redIndex   $red]
			set Display_Array_2 [lreplace $Display_Array_2 $greenIndex $greenIndex $green]
			set Display_Array_2 [lreplace $Display_Array_2 $blueIndex  $blueIndex  $blue]
		} elseif {$DDF_Num == 3} {
			set Display_Array_3 [lreplace $Display_Array_3 $redIndex   $redIndex   $red]
			set Display_Array_3 [lreplace $Display_Array_3 $greenIndex $greenIndex $green]
			set Display_Array_3 [lreplace $Display_Array_3 $blueIndex  $blueIndex  $blue]
		} else {
			error [format "Error: Modify_Display_Array, Invalid DDF_Module number %i." $DDF_Num]
		}
	} else {
		# Read entries
		if {$DDF_Num == 0} {
			return [format "%s %s %s" [lindex $Display_Array_0 $redIndex] [lindex $Display_Array_0 $greenIndex] [lindex $Display_Array_0 $blueIndex]]
		} elseif {$DDF_Num == 1} {
			return [format "%s %s %s" [lindex $Display_Array_1 $redIndex] [lindex $Display_Array_1 $greenIndex] [lindex $Display_Array_1 $blueIndex]]
		} elseif {$DDF_Num == 2} {
			return [format "%s %s %s" [lindex $Display_Array_2 $redIndex] [lindex $Display_Array_2 $greenIndex] [lindex $Display_Array_2 $blueIndex]]
		} elseif {$DDF_Num == 3} {
			return [format "%s %s %s" [lindex $Display_Array_3 $redIndex] [lindex $Display_Array_3 $greenIndex] [lindex $Display_Array_3 $blueIndex]]
		} else {
			error [format "Error: Modify_Display_Array, Invalid DDF_Module number %i." $DDF_Num]
		}
	}
}

# Blank_Display_Array <DDF_Module_Number>
#
# Desc: Blanks the display array for a given module, but does not update display
proc Blank_Display_Array {args} {
	global Display_Array_0 Display_Array_1 Display_Array_2 Display_Array_3
	# Check number of arguments
	if {[llength $args] != 1} {
		puts [format "Usage: Blank_Display_Array <DDF_Module_Number>"]
		error "Error: Blank_Display_Array, Wrong number of arguments."
	}
	# Blank Correct Array
	if {[lindex $args 0] == 0} {
		set Display_Array_0 "F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F"
	} elseif {[lindex $args 0] == 1} {
		set Display_Array_1 "F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F"
	} elseif {[lindex $args 0] == 2} {
		set Display_Array_2 "F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F"
	} elseif {[lindex $args 0] == 3} {
		set Display_Array_3 "F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F"
	} else {
		error [format "Error: Blank_Display_Array, Could not update display for DDF Module %i." [lindex $args 0]]
	}
}

# Color_Display_Array <DDF_Module_Number> <red> <green> <blue>
#
# Desc: Sets the entire display array to a single color
proc Color_Display_Array {args} {
	global Display_Array_0 Display_Array_1 Display_Array_2 Display_Array_3
	# Check number of arguments
	if {[llength $args] != 4} {
		puts [format "Usage: Color_Display_Array <DDF_Module_Number> <red> <green> <blue>"]
		error "Error: Color_Display_Array, Wrong number of arguments."
	}
	set red   [lindex $args 1]
	set green [lindex $args 2]
	set blue  [lindex $args 3]
	# Color Correct Array
	if {[lindex $args 0] == 0} {
		set Display_Array_0 [format "%s %s %s %s %s %s %s %s %s %s %s %s" [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue]]
	} elseif {[lindex $args 0] == 1} {
		set Display_Array_1 [format "%s %s %s %s %s %s %s %s %s %s %s %s" [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue]]
	} elseif {[lindex $args 0] == 2} {
		set Display_Array_2 [format "%s %s %s %s %s %s %s %s %s %s %s %s" [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue]]
	} elseif {[lindex $args 0] == 3} {
		set Display_Array_3 [format "%s %s %s %s %s %s %s %s %s %s %s %s" [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue] [lrepeat 16 $red] [lrepeat 16 $green] [lrepeat 16 $blue]]
	} else {
		error [format "Error: Color_Display_Array, Could not update display for DDF Module %i." [lindex $args 0]]
	}
}

# Remove_Spaces <thelist>
#
# Desc: Removes the spaces in a list for sending over serial port
proc Remove_Spaces {thelist} {	
	set no_spaces $thelist
	set more_spaces [string first " " $no_spaces ]	
	while {$more_spaces != -1} {
		set no_spaces [string replace $no_spaces $more_spaces $more_spaces]
		set more_spaces [string first " " $no_spaces ]
	}
	return $no_spaces
}

# DDF_Auto_Connect
#
# Desc: Automatically try to connect to all DDF Modules
# Returns: list where 0 = connected, 1 = unable to connect
proc DDF_Auto_Connect {} {
	set DDF0 [catch {DDF_Connect 0}]
	set DDF1 [catch {DDF_Connect 1}]
	set DDF2 [catch {DDF_Connect 2}]
	set DDF3 [catch {DDF_Connect 3}]
	return [list $DDF0 $DDF1 $DDF2 $DDF3]
}

# DDF_Auto_Disconnect
#
# Desc: Automatically disconnect all DDF Modules
# Returns: list where 0 = disconnected, 1 = unable to disconnect
proc DDF_Auto_Disconnect {} {
	set DDF0 [catch {DDF_Disconnect 0}]
	set DDF1 [catch {DDF_Disconnect 1}]
	set DDF2 [catch {DDF_Disconnect 2}]
	set DDF3 [catch {DDF_Disconnect 3}]
	return [list $DDF0 $DDF1 $DDF2 $DDF3]
}


# Initialize Display Arrays
Blank_Display_Array 0
Blank_Display_Array 1
Blank_Display_Array 2
Blank_Display_Array 3
