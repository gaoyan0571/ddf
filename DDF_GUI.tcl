#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"
# Above code used for compatibility purposes

source DDF_HW_interface.tcl
source DDF_bmp_functions.tcl
source DDF_test.tcl

# Setup Window Manager (opens a window)
package require Tk	8.5

# Window Settings
wm aspect . 3 2 3 2
wm title . "DDF Control Panel";          # Gives window a title
#wm attributes . -topmost 1;             # Places window ALWAYS on top! (does not give focus)
set width 640; set height 480; set posX 0; set posY 0; # Set Size and Position
wm geometry . [format "%ix%i+%i+%i" $width $height $posX $posY]
#focus .;                                # Give focus to this window

# Create frames
frame .masterControls;									 # Holds General Controls in the upper portion of the window
frame .layerControl;										 # Holds Layer Controls in the lower-left portion of the window
frame .playlistControl;									 # Holds Playlist Controls in the lower-right portion of the window
frame .masterControls.connectivity;      # Holds Connect button and connection status labels
frame .masterControls.moduleOrientation; # Holds Controls for DDF module orientation

# Configure borders on frames
.masterControls                   configure -borderwidth 3 -relief groove;
.masterControls.connectivity      configure -borderwidth 0 -relief flat;
.masterControls.moduleOrientation configure -borderwidth 0 -relief flat;
.layerControl                     configure -borderwidth 3 -relief groove;
.playlistControl                  configure -borderwidth 3 -relief groove;


# Create Buttons
button .masterControls.connectivity.buttConnect -text "Connect" -command "Update_Connected_DDF_Module_Status"
button .playlistControl.buttClear   -text "Clear"   -command "Clear_Display"
button .playlistControl.buttBouncyrand   -text "Bouncyrand"   -command "bouncyrand_setup"
button .playlistControl.buttRun   -text "Run"   -command "run"
button .playlistControl.buttStop   -text "Stop"   -command {after cancel $process}
button .playlistControl.buttBMP   -text "BMP"   -command "Display_BMP"

# Buttons for Module Orientation
for {set moColIndex 0} {$moColIndex < 4} {incr moColIndex} {
	for {set moRowIndex 0} {$moRowIndex < 4} {incr moRowIndex} {
		button [format ".masterControls.moduleOrientation.orientationButton%i_%i" $moRowIndex $moColIndex] -command "set moduleOrientButtonR $moRowIndex; set moduleOrientButtonC $moColIndex; Module_Orientation" -height 1 -width 2;
		grid [format ".masterControls.moduleOrientation.orientationButton%i_%i" $moRowIndex $moColIndex] -row $moRowIndex -column $moColIndex
	}
}



#button .buttAdd   -text "+"     -command "calcAdd"
#button .buttSub   -text "-"     -command "calcSub"

# Create Labels
label .masterControls.connectivity.labelDDF0_Status -text "0" -bg red;
label .masterControls.connectivity.labelDDF1_Status -text "1" -bg red;
label .masterControls.connectivity.labelDDF2_Status -text "2" -bg red;
label .masterControls.connectivity.labelDDF3_Status -text "3" -bg red;



#. config -borderwidth 10 -bg cyan -relief groove
#
## Create ScreenLayer List Box, 
#listbox .screenLayer -width 75 -height 20 -selectmode browse -listvariable screenLayerList
#.screenLayer configure
#
## Create PlayList List Box, 
#listbox .playList -width 75 -height 20 -selectmode browse -listvariable playListList
#.playList configure 
#
#
#
#
## Organize Key-Presses
#bind . <Key> {processKeyPress %K}
#
#
#
## Organize and add buttons to window
#grid .buttConnect .buttClear .buttBouncyrand .buttRun .buttStop .buttBMP
#
## Organize and add labels to window
#grid .labelDDF0_Status .labelDDF1_Status .labelDDF2_Status .labelDDF3_Status .screenLayer .playList

proc processKeyPress {keyPressed} {
    
    
    puts $keyPressed
}

# Update_Connected_DDF_Module_Status
#
# Desc: Disconnects then reconnects to all available DDF modules and updates connection status
proc Update_Connected_DDF_Module_Status {} {
	DDF_Auto_Disconnect; # Disconnect from all modules first
	set status [DDF_Auto_Connect]
	if {[lindex $status 0] == 0} {
		.masterControls.connectivity.labelDDF0_Status configure -bg green
	} else {
		.masterControls.connectivity.labelDDF0_Status configure -bg red
	}
	if {[lindex $status 1] == 0} {
		.masterControls.connectivity.labelDDF1_Status configure -bg green
	} else {
		.masterControls.connectivity.labelDDF1_Status configure -bg red
	}
	if {[lindex $status 2] == 0} {
		.masterControls.connectivity.labelDDF2_Status configure -bg green
	} else {
		.masterControls.connectivity.labelDDF2_Status configure -bg red
	}
	if {[lindex $status 3] == 0} {
		.masterControls.connectivity.labelDDF3_Status configure -bg green
	} else {
		.masterControls.connectivity.labelDDF3_Status configure -bg red
	}
}

# Clear_Display
#
# Desc: Blanks all modules and updates display
proc Clear_Display {} {
	for {set i 0} {$i < 4} {incr i} {
		Blank_Display_Array $i
		catch {DDF_Display $i}
	}
}

proc Display_BMP {} {
	set types {
    {{BMP Images}       {.bmp}        }
	}
	catch {::bmp::DDF_bmp 0 [tk_getOpenFile -filetypes $types]}
	DDF_Display 0
}

proc Module_Orientation {} {
	global orientation moduleSelection moduleOrientationAction
	global Display_Rotation_0 Display_Rotation_1 Display_Rotation_2 Display_Rotation_3
	global Display_Array_0 Display_Array_1 Display_Array_2 Display_Array_3
	global idZero idOne idTwo idThree
	global moduleOrientButtonR moduleOrientButtonC
	
	
	# Save a copy of the Display Arrays
	set copyDisplayArray0 $Display_Array_0
	set copyDisplayArray1 $Display_Array_1
	set copyDisplayArray2 $Display_Array_2
	set copyDisplayArray3 $Display_Array_3
	# Load Numbered Display Arrays for setting orientation
	set Display_Array_0 $idZero
	set Display_Array_1 $idOne
	set Display_Array_2 $idTwo
	set Display_Array_3 $idThree
	# Update Displays (if possible)
	catch {DDF_Display 0}
	catch {DDF_Display 1}
	catch {DDF_Display 2}
	catch {DDF_Display 3}
	# This allows the user to see the orientation of all modules with a rotation of 0
	
	# Copy the Display Arrays Back
	set Display_Array_0 $copyDisplayArray0
	set Display_Array_1 $copyDisplayArray1
	set Display_Array_2 $copyDisplayArray2
	set Display_Array_3 $copyDisplayArray3
	
	# Build Dialog
  tk::toplevel .modOrientDialog
  wm title .modOrientDialog "Select"
  frame .modOrientDialog.orientFrame;       # Frame to hold the orientation radio buttons
  frame .modOrientDialog.moduleSelectFrame; # Frame to hold the module selection radio buttons
  frame .modOrientDialog.acceptCancelFrame; # Frame to hold the accept and cancel buttons
  
  label .modOrientDialog.moduleSelectFrame.labelModule -text "Module";
  label .modOrientDialog.orientFrame.labelOrientation  -text "Orientation";
  
  button .modOrientDialog.acceptCancelFrame.acceptButton -text "Accept" -command "set moduleOrientationAction 1"
  button .modOrientDialog.acceptCancelFrame.cancelButton -text "Cancel" -command "set moduleOrientationAction 0"

  set moduleSelection 0; # Variable used for Module Radiobuttons
  set orientation 0;     # Variable used for Orientation Radiobuttons
  ttk::radiobutton .modOrientDialog.orientFrame.north -text "0°"   -variable orientation -value 0
  ttk::radiobutton .modOrientDialog.orientFrame.south -text "180°" -variable orientation -value 2
  ttk::radiobutton .modOrientDialog.orientFrame.east  -text "90°"  -variable orientation -value 1
  ttk::radiobutton .modOrientDialog.orientFrame.west  -text "270°" -variable orientation -value 3
  
  ttk::radiobutton .modOrientDialog.moduleSelectFrame.zero  -text "0" -variable moduleSelection -value 0
  ttk::radiobutton .modOrientDialog.moduleSelectFrame.one   -text "1" -variable moduleSelection -value 1
  ttk::radiobutton .modOrientDialog.moduleSelectFrame.two   -text "2" -variable moduleSelection -value 2
  ttk::radiobutton .modOrientDialog.moduleSelectFrame.three -text "3" -variable moduleSelection -value 3
  
  pack .modOrientDialog.orientFrame.labelOrientation -side top
  pack .modOrientDialog.orientFrame.north -side top
  pack .modOrientDialog.orientFrame.south -side bottom
  pack .modOrientDialog.orientFrame.east  -side right
  pack .modOrientDialog.orientFrame.west  -side left
  
  pack .modOrientDialog.moduleSelectFrame.labelModule -side top
  pack .modOrientDialog.moduleSelectFrame.zero  -side top
  pack .modOrientDialog.moduleSelectFrame.one   -side top
  pack .modOrientDialog.moduleSelectFrame.two   -side top
  pack .modOrientDialog.moduleSelectFrame.three -side top
  
  pack .modOrientDialog.acceptCancelFrame.acceptButton -side left
  pack .modOrientDialog.acceptCancelFrame.cancelButton -side left
  
  pack .modOrientDialog.moduleSelectFrame -side left
  pack .modOrientDialog.orientFrame       -side top
  pack .modOrientDialog.acceptCancelFrame -side bottom

	focus .modOrientDialog; # Give the window focus
  grab set -global .modOrientDialog; # Lock user to this dialog window
  
  # Wait till user enters info or cancels
  vwait moduleOrientationAction
  puts $moduleOrientationAction
  puts $moduleSelection
  puts $orientation
  # Change settings if Accept clicked
  if {$moduleOrientationAction == 1} {
  	# Rotation
  	# Update Module Display for rotation
  	set tempDisplayArray0 $Display_Array_0
  	set tempDisplayArray1 $Display_Array_1
  	set tempDisplayRotation0 $Display_Rotation_0
  	set tempDisplayRotation1 $Display_Rotation_1
  	if {$moduleSelection == 0} {
  		set useDispArray 1
  	} else {
  		set useDispArray 0
  	}
  	set [format "Display_Rotation_%i" $useDispArray] $orientation
  	for {set i 0} {$i < 8} {incr i} {
  		for {set j 0} {$j < 8} {incr j} {
  			set color [Modify_Display_Array $moduleSelection $i $j]
  			Modify_Display_Array $useDispArray $i $j [lindex $color 0] [lindex $color 1] [lindex $color 2]
  		}
  	}
  	# Restore Displays 0 and 1 as necessary
  	if { $useDispArray == 0} {
  		# Copy updated Display Array to correct display array
  		set [format "Display_Array_%i" $moduleSelection] $Display_Array_0
  		set Display_Array_0 $tempDisplayArray0
  		set Display_Rotation_0 $tempDisplayRotation0
  	} else {
  		# Copy updated Display Array to correct display array
  		set [format "Display_Array_%i" $moduleSelection] $Display_Array_1
  		set Display_Array_1 $tempDisplayArray1
  		set Display_Rotation_1 $tempDisplayRotation1
  	}
  	set [format "Display_Rotation_%i" $moduleSelection] $orientation
  	
  	# Update Button and position info
  	# moduleOrientButton - row col
  	
  	#To Do:
  	# Rotate number in button to match selected rotation (rotating 90degrees should turn the text left 90 degrees)
  	# update the color so you know which modules are connected
  	# remove redundancies when setting a button
  	# Store position information with the rotation information
  	# Investigate bug, where I right click taskbar to move window and can close dialog box
  	
  	[format ".masterControls.moduleOrientation.orientationButton%i_%i" $moduleOrientButtonR $moduleOrientButtonC] config -text [format "%i" $moduleSelection]
  }
  # Update Displays (if possible) to remove numbers
	catch {DDF_Display 0}
	catch {DDF_Display 1}
	catch {DDF_Display 2}
	catch {DDF_Display 3}
  
  grab release .modOrientDialog
  destroy .modOrientDialog
  

}


# Pack Buttons
pack .masterControls.connectivity.buttConnect
pack .playlistControl.buttClear
pack .playlistControl.buttBouncyrand
pack .playlistControl.buttRun
pack .playlistControl.buttStop
pack .playlistControl.buttBMP


# Pack Labels
pack .masterControls.connectivity.labelDDF0_Status -side left
pack .masterControls.connectivity.labelDDF1_Status -side left
pack .masterControls.connectivity.labelDDF2_Status -side left
pack .masterControls.connectivity.labelDDF3_Status -side left

# Pack Frames
pack .masterControls                   -side top -fill x
pack .masterControls.connectivity      -side left
pack .masterControls.moduleOrientation -side left
pack .layerControl                     -side left -fill y
pack .playlistControl                  -side right -fill y

. config -borderwidth 0 -relief flat
