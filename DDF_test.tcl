# Example Animation Method 1
proc go {} {
	global Display_Array_0 DDF_SS_0 DDF_SS_1 DDF_SS_2 DDF_SS_3 DDF_FH_0
	#Blank_Display_Array 0
	::bmp::DDF_bmp 0 "Ben.bmp"
	set Ben [format "000010%s" [Remove_Spaces $Display_Array_0]]
	::bmp::DDF_bmp 0 "Mooninite.bmp"
	set Mooninite [format "000010%s" [Remove_Spaces $Display_Array_0]]
	for {set i 0} {$i < 100} {incr i} {
		set tmp $Ben
		Serial_Tx $DDF_FH_0 $Ben
		set tmp $Mooninite
		Serial_Tx $DDF_FH_0 $tmp
	}
}
# Example Animation Method 2 (prefered) faster than go3
proc go2 {} {
	global Display_Array_0 DDF_SS_0 DDF_SS_1 DDF_SS_2 DDF_SS_3 DDF_FH_0
	#Blank_Display_Array 0
	::bmp::DDF_bmp 0 "Ben.bmp"
	set Ben $Display_Array_0
	::bmp::DDF_bmp 0 "Mooninite.bmp"
	set Mooninite $Display_Array_0
	Color_Display_Array 0 F 0 F
	set green $Display_Array_0
	Blank_Display_Array 0
	set blank $Display_Array_0
	Color_Display_Array 0 0 F F
	set red $Display_Array_0
	for {set i 0} {$i < 50} {incr i} {
		set Display_Array_0 $Ben
		#::bmp::DDF_bmp 0 "Ben.bmp"
		#Serial_Tx $DDF_FH_0 $tmp
		#after 10
		DDF_Display 0
		set Display_Array_0 $Mooninite
		#::bmp::DDF_bmp 0 "Mooninite.bmp"
		#Serial_Tx $DDF_FH_0 $tmp
		#after 10
		DDF_Display 0
	}
}
# Try loading Display Array each time instead of copy
proc go3 {} {
	global Display_Array_0 DDF_SS_0 DDF_SS_1 DDF_SS_2 DDF_SS_3 DDF_FH_0
	#Blank_Display_Array 0
	::bmp::DDF_bmp 0 "Ben.bmp"
	set Ben $Display_Array_0
	::bmp::DDF_bmp 0 "Mooninite.bmp"
	set Mooninite $Display_Array_0
	Color_Display_Array 0 F 0 F
	set green $Display_Array_0
	Blank_Display_Array 0
	set blank $Display_Array_0
	Color_Display_Array 0 0 F F
	set red $Display_Array_0
	for {set i 0} {$i < 50} {incr i} {
		#set Display_Array_0 $Ben
		::bmp::DDF_bmp 0 "Ben.bmp"
		#Serial_Tx $DDF_FH_0 $tmp
		#after 10
		DDF_Display 0
		#set Display_Array_0 $Mooninite
		::bmp::DDF_bmp 0 "Mooninite.bmp"
		#Serial_Tx $DDF_FH_0 $tmp
		#after 10
		DDF_Display 0
	}
}

proc frames {delay} {
	global Display_Array_0
	cd ./animation
	::bmp::DDF_bmp 0 "000.bmp"
	set ani0 $Display_Array_0
	::bmp::DDF_bmp 0 "001.bmp"
	set ani1 $Display_Array_0
	::bmp::DDF_bmp 0 "002.bmp"
	set ani2 $Display_Array_0
	::bmp::DDF_bmp 0 "003.bmp"
	set ani3 $Display_Array_0
	::bmp::DDF_bmp 0 "004.bmp"
	set ani4 $Display_Array_0
	::bmp::DDF_bmp 0 "005.bmp"
	set ani5 $Display_Array_0

	for {set i 0} {$i < 50} {incr i} {
		set Display_Array_0 $ani0
		after $delay
		DDF_Display 0
		set Display_Array_0 $ani1
		after $delay
		DDF_Display 0
		set Display_Array_0 $ani2
		after $delay
		DDF_Display 0
		set Display_Array_0 $ani3
		after $delay
		DDF_Display 0
		set Display_Array_0 $ani4
		after $delay
		DDF_Display 0
		set Display_Array_0 $ani5
		after $delay
		DDF_Display 0
	}
	cd ..
}
# Generates a bouncy dot that bounces predictably and changes color when it hits a boundary
proc bouncy {ddf_module runtime speed} {
	set xGridSize 8
	set yGridSize 8
	set xPos 0
	set yPos 3
	set xAccel 1
	set yAccel 1
	set color {F 0 F}
	
	for {set i 0} {$i < $runtime} {incr i} {
		after $speed
		set xPos [expr $xPos + $xAccel]
		set yPos [expr $yPos + $yAccel]
		# Boundary Check
		if {[expr ($xPos == $xGridSize) || ($xPos < 0)]} {
			set xAccel [expr $xAccel * (-1)]
			set xPos [expr $xPos + $xAccel]
			# Change Color
			set color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		if {[expr ($yPos == $yGridSize) || ($yPos < 0)]} {
			set yAccel [expr $yAccel * (-1)]
			set yPos [expr $yPos + $yAccel]
			# Change Color
			set color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		Blank_Display_Array $ddf_module
		Modify_Display_Array $ddf_module $xPos $yPos [lindex $color 0] [lindex $color 1] [lindex $color 2]
		DDF_Display $ddf_module
	}
}

# Generates a bouncy dot that moves in a random manor and changes color when it hits a boundary
proc randomy {ddf_module runtime speed} {
	set xGridSize 8
	set yGridSize 8
	set xPos 0
	set yPos 3
	set xAccel 1
	set yAccel 1
	set color {F 0 F}
	
	for {set i 0} {$i < $runtime} {incr i} {
		after $speed
		if {[expr (0.5 - rand()) > 0]} {
			set xPos [expr $xPos + 1]
		} else {
			set xPos [expr $xPos - 1]
		}
		if {[expr (0.5 - rand()) > 0]} {
			set yPos [expr $yPos + 1]
		} else {
			set yPos [expr $yPos - 1]
		}
		# Boundary Check
		if {[expr ($xPos == $xGridSize)]} {
			set xPos [expr $xPos - 1]
			# Change Color
			set color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		if {[expr ($xPos < 0)]} {
			set xPos [expr $xPos + 1]
			# Change Color
			set color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		if {[expr ($yPos == $yGridSize)]} {
			set yPos [expr $yPos - 1]
			# Change Color
			set color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		if {[expr ($yPos < 0)]} {
			set yPos [expr $yPos + 1]
			# Change Color
			set color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		Blank_Display_Array $ddf_module
		Modify_Display_Array $ddf_module $xPos $yPos [lindex $color 0] [lindex $color 1] [lindex $color 2]
		DDF_Display $ddf_module
	}
}

# Generates a bouncy dot that bounces unpredictably and changes color when it hits a boundary
proc bouncyrand {ddf_module runtime speed} {
	set xGridSize 8
	set yGridSize 8
	set xPos 0
	set yPos 3
	set xAccel 1
	set yAccel 1
	set color {F 0 F}
	
	for {set i 0} {$i < $runtime} {incr i} {
		after $speed
		set xPos [expr $xPos + $xAccel]
		set yPos [expr $yPos + $yAccel]
		# Boundary Check
		set hit 0
		if {[expr ($xPos == $xGridSize) || ($xPos < 0)]} {
			if {[expr (0.5 - rand()) > 0]} {
				set yAccel [expr $yAccel * (-1)]
				set hit 1; # Set to notify sec. condition that yAccel flipped here, (fixes error condition where in upper left corner (0,0))
			}
			set xAccel [expr $xAccel * (-1)]
			set xPos [expr $xPos + $xAccel]
			# Change Color
			set color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		if {[expr ($yPos == $yGridSize) || ($yPos < 0)]} {
			if {[expr (0.5 - rand()) > 0]} {
				set xAccel [expr $xAccel * (-1)]
			}
			if {$hit != 1} {
				set yAccel [expr $yAccel * (-1)]
			}
			set yPos [expr $yPos + $yAccel]
			# Change Color
			set color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		Blank_Display_Array $ddf_module
		#puts [format "X:%iY:%iR:%sG:%sB:%s" $xPos $yPos [lindex $color 0] [lindex $color 1] [lindex $color 2]]
		Modify_Display_Array $ddf_module $xPos $yPos [lindex $color 0] [lindex $color 1] [lindex $color 2]
		DDF_Display $ddf_module
	}
}


proc bouncyrand_setup {} {
	global br_xPos br_yPos br_color br_xAccel br_yAccel
	set br_xPos 0
	set br_yPos 3
	set br_xAccel 1
	set br_yAccel 1
	set br_color {F 0 F}
}

# Generates a bouncy dot that bounces unpredictably and changes color when it hits a boundary
proc bouncyrand2 {ddf_module runtime speed} {
	global br_xPos br_yPos br_color br_xAccel br_yAccel
	set xGridSize 8
	set yGridSize 8

	
	for {set i 0} {$i < $runtime} {incr i} {
		after $speed
		set br_xPos [expr $br_xPos + $br_xAccel]
		set br_yPos [expr $br_yPos + $br_yAccel]
		# Boundary Check
		set hit 0
		if {[expr ($br_xPos == $xGridSize) || ($br_xPos < 0)]} {
			if {[expr (0.5 - rand()) > 0]} {
				set br_yAccel [expr $br_yAccel * (-1)]
				set hit 1; # Set to notify sec. condition that yAccel flipped here, (fixes error condition where in upper left corner (0,0))
			}
			set br_xAccel [expr $br_xAccel * (-1)]
			set br_xPos [expr $br_xPos + $br_xAccel]
			# Change Color
			set br_color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		if {[expr ($br_yPos == $yGridSize) || ($br_yPos < 0)]} {
			if {[expr (0.5 - rand()) > 0]} {
				set br_xAccel [expr $br_xAccel * (-1)]
			}
			if {$hit != 1} {
				set br_yAccel [expr $br_yAccel * (-1)]
			}
			set br_yPos [expr $br_yPos + $br_yAccel]
			# Change Color
			set br_color [split [format "%X %X %X" [expr int(rand() * 15)] [expr int(rand() * 15)] [expr int(rand() * 15)]]]
		}
		Blank_Display_Array $ddf_module
		#puts [format "X:%iY:%iR:%sG:%sB:%s" $xPos $yPos [lindex $color 0] [lindex $color 1] [lindex $color 2]]
		Modify_Display_Array $ddf_module $br_xPos $br_yPos [lindex $br_color 0] [lindex $br_color 1] [lindex $br_color 2]
		DDF_Display $ddf_module
	}
}

proc run {} {
	global process
	bouncyrand2 0 1 50
	set process [after 1 run]
}