 #
 # pure-tcl .bmp file read/write package.
 #
 # v0.1  (2007-05-15)  this code reads and writes 2-color, 16-color,
 # 256-color, and 16.7-million-color non-compressed .bmp files.
 #
 # v0.2  (2007-07-01)  fixed a typo and bug
 #
 # v0.3  (2008-02-21)  added 32bpp support
 #
 # v0.4  (2008-09-12)  updated to use features of 8.5, which ought to improve performance
 #
 # written by S. Havelka (on tclchat:  hat0)
 #

# Procedures

# ::bmp::readfile <fname> - Returns width, height, bits per pixel, a list of rgb quads (zero for true-color images), and a list of lists representing the pixel data
# ::bmp::writefile <rgb_quads> <bmp_data> <fname>
# ::bmp::DDF_bmp <ddf_module> <fname> - Modifies Display_Array for a given ddf_module with bitmap, (expecting 8x8 pixel bmp)

 namespace eval ::bmp {
   namespace export readfile writefile DDF_bmp

   set header_def { bfType 2 bfSize 4 bfReserved1 2 bfReserved 2 bfOffBits 4 }
   set info_def { biSize 4 biWidth 4 biHeight 4 biPlanes 2 biBitCount 2 biCompression 4 biSizeImage 4 biXPelsPerMeter 4 biYPelsPerMeter 4 biClrUsed 4 biClrImportant 4 }

 }

 # 
 # the data returned from this routine is:
 # width, height, bits per pixel, a list of rgb quads (zero for true-color images),
 # and a list of lists representing the pixel data
 #
 proc ::bmp::readfile { fname } {

   variable header_def
   variable info_def

   #
   # open the file
   #
   if { [catch {set fh [open $fname r] } err] } {
     return -code error "couldn't open $fname for reading"
   } else {

     fconfigure $fh -translation binary

     #
     # first, read in the header
     #
     foreach {name len} $header_def {
      	set in [read $fh $len]
      	binary scan $in [expr {$len == 2 ? "s" : "i"}]u bmp($name)
     }

     # is it a .bmp ?
     if { $bmp(bfType) != 19778 } {
       return -code error "$fname is not a valid bmp"
     }

     #
     # second, read the bitmap info data
     #
     foreach {name len} $info_def {
       set in [read $fh $len]
       binary scan $in [expr {$len == 2 ? "s" : "i"}]u bmp($name)
     }

     # right now we only take the 'v3' format bmp
     if { $bmp(biSize) != 40 } {
       return -code error "we can only read v3 bmps at present"
     }

     #
     # if this is a color-mapped image, read the rgbquad array.
     # first, determine the # of rgb quads to read!
     #
     if { $bmp(biClrUsed) } {
       set rgb_quads_to_read $bmp(biClrUsed)
     } else {

       switch $bmp(biBitCount) {
         1 { set rgb_quads_to_read 2 }
         4 { set rgb_quads_to_read 16 }
         8 { set rgb_quads_to_read 256 }
         24 { set rgb_quads_to_read 0 }
         32 { set rgb_quads_to_read 0 }
       }

     }

     # and read in the rgb quads
     set rgb_quads {}
     for { set i 0 } { $i < $rgb_quads_to_read } { incr i } {
       set in [read $fh 4]
       binary scan $in cucucucu b g r x
       lappend rgb_quads [list [expr {$r & 0xff}] [expr {$g & 0xff}] [expr {$b & 0xff}]]
     }

     #
     # and now, read in the bitmap data, dword-aligned and in reverse order.
     # first, calculate the line width in bytes and pad to dword
     #
     switch $bmp(biBitCount) {
       1 { set line_width [expr {$bmp(biWidth)/8}] }
       4 { set line_width [expr {$bmp(biWidth)/2}] }
       8 { set line_width $bmp(biWidth) }
       24 { set line_width [expr {$bmp(biWidth)*3}] }
       32 { set line_width [expr {$bmp(biWidth)*4}] }
     }
     set padded_line_width [expr {($line_width+3) & ~3}]

     # and read in the lines, unpacking if the bitplane is 1 or 4 bpp
     set in_data [read $fh [file size $fname]]

     set bmp_data {}
     for { set i 0 } { $i < $bmp(biHeight) } { incr i } {

       set in [string range $in_data [expr {$i*$padded_line_width}] [expr {($i+1)*$padded_line_width-1}]]
       if { $bmp(biBitCount) == 1 } {

         binary scan $in b$bmp(biWidth) line
         lappend bmp_data [split $line ""]

       } elseif { $bmp(biBitCount) == 4 } {

         binary scan $in H$bmp(biWidth) line
         lappend bmp_data [string map { a 10 A 10 b 11 B 11 c 12 C 12 d 13 D 13 e 14 E 14 f 15 F 15 } [split $line ""]]

       } elseif { $bmp(biBitCount) == 8 } {

         binary scan $in cu$line_width line
         lappend bmp_data $line

       } elseif { $bmp(biBitCount) == 24 } {

         binary scan $in cu$line_width line

         # note that bmp data is stored as bgr, not rgb
         set fixed_line {}
         foreach {b g r} $line {
           lappend fixed_line $r $g $b
         }
         lappend bmp_data $fixed_line

       } elseif { $bmp(biBitCount) == 32 } {

         binary scan $in cu$line_width line

         # note that bmp data is stored as bgr, not rgb
         set fixed_line {}
         foreach {b g r x} $line {
           lappend fixed_line $r $g $b
         }
         lappend bmp_data $fixed_line

       }

     }

     close $fh
     return [list $bmp(biWidth) $bmp(biHeight) $bmp(biBitCount) $rgb_quads [lreverse $bmp_data]]

   }

 }

 #
 # this routine needs:
 # a list of rgb_quads, bitmap data, and a filename
 # - rgb quads:  0-256.  if 1-256, then bitmap data is indexed.
 #               if 0, then bitmap data is taken as rgb
 # - bitmap data:  a list of lists, each sublist one line of
 #                 pixel data.  either indexed or rgb.
 #

 proc ::bmp::writefile { rgb_quads bmp_data fname } {

   variable header_def
   variable info_def

   #
   # determine the bit depth
   #
   set qc [llength $rgb_quads]
   if { !$qc } {
     set bpp 24
   } elseif { $qc == 2 } {
     set bpp 1
   } elseif { 2 < $qc && $qc <= 16 } {
     set bpp 4
   } elseif { 16 < $qc && $qc <= 256 } {
     set bpp 8
   } else {
     return -code error "too many rgb quads!"
   }

   #
   # verify that rgb data is all properly formed
   #
   foreach rgb $rgb_quads {
     if { [llength $rgb] != 3 } {
       return -code error "bad rgb data"
     }
   }

   #
   # and verify the bmp data
   #
   set height [llength $bmp_data]
   if { !$height } {
     return -code error "no bmp data provided"
   }

   set width [llength [lindex $bmp_data 0]]
   if { $bpp == 24 && $width % 3 } {
     return -code error "given bmp data seems to be 24bpp, but is not divisible by 3"
   }

   for { set i 1 } { $i < $height } { incr i } {
     if { [llength [lindex $bmp_data $i]] != $width } {
       return -code error "all rows in bmp data must be the same width"
     }
   }

   #
   # calculate padded data size
   #
   switch $bpp {
     1 { set byte_width [expr { (($width+7) & ~7) / 8}] }
     4 { set byte_width [expr { (($width+1) & ~1) / 2}] }
     8 { set byte_width $width }
     24 {
       set byte_width $width
       set width [expr {$width / 3}]
     }
   }
   set pad_width [expr {($byte_width+3) & ~3}]
   set bmp_len [expr {$pad_width * $height}]

   #
   # ok!  let's try to get a file handle
   #
   if { [catch { set fh [open $fname w] } err] } {
     return -code error "couldn't open $fname for writing"
   } else {

     fconfigure $fh -translation binary

     #
     # ok!  write out the header!  first, the identifying bytes
     #
     puts -nonewline $fh [binary format s 19778]

     #
     # calculate and output the total bmp size
     #
     set header_len 0
     foreach {junk len} $header_def {
       set header_len [expr {$header_len + $len}]
     }

     set info_len 0
     foreach {junk len} $info_def {
       set info_len [expr {$info_len + $len}]
     }

     set rgb_len [expr {[llength $rgb_quads] * 4}]

     puts -nonewline $fh [binary format i [expr {$header_len + $info_len + $rgb_len + $bmp_len}]]

     #
     # reserved bytes ..
     #
     puts -nonewline $fh [binary format s 0]
     puts -nonewline $fh [binary format s 0]

     #
     # offset to bmp data
     #
     puts -nonewline $fh [binary format i [expr {$header_len + $info_len + $rgb_len}]]

     #
     # now output the info block (v3-style .bmp)
     #
     puts -nonewline $fh [binary format i 40]
     puts -nonewline $fh [binary format i $width]
     puts -nonewline $fh [binary format i $height]

     puts -nonewline $fh [binary format s 0]
     puts -nonewline $fh [binary format s $bpp]

     puts -nonewline $fh [binary format i 0]
     puts -nonewline $fh [binary format i 0]

     puts -nonewline $fh [binary format i 0]
     puts -nonewline $fh [binary format i 0]

     puts -nonewline $fh [binary format i [llength $rgb_quads]]
     puts -nonewline $fh [binary format i [llength $rgb_quads]]

     #
     # and now, the rgb quads
     #
     foreach my $rgb_quads {
       foreach {r g b} $my break
       puts -nonewline $fh [binary format cccc $b $g $r 0]
     }

     #
     # at last, the bitmap data.  note that each bitmap format has enough padding
     # added to the line to ensure proper dword-alignment, no matter how much
     # pixel data is provided.
     #
     for { incr height -1 } { $height != -1 } { incr height -1 } {

       if { $bpp == 1 } {
         puts -nonewline $fh [binary format B[expr {$pad_width*8}] [join [lindex $bmp_data $height] ""][string repeat 0 31]]
       } elseif { $bpp == 4 } {
         puts -nonewline $fh [binary format H[expr {$pad_width*2}] [join [string map { 10 A 11 B 12 C 13 D 14 E 15 F } [lindex $bmp_data $height]] ""][string repeat 0 7]]
       } elseif { $bpp == 8 } {
         puts -nonewline $fh [binary format c$pad_width "[lindex $bmp_data $height] 0 0 0"]
       } elseif { $bpp == 24 } {

         # note that, for some reason, rgb data is stored as bgr ...
         set fixed_data {}
         foreach {r g b} [lindex $bmp_data $height] {
           lappend fixed_data $b $g $r
         }

         puts -nonewline $fh [binary format c$pad_width "$fixed_data 0 0 0"]

       }

     }

     #
     # behold, we're done!
     #
     close $fh

   }

 }

proc ::bmp::DDF_bmp { ddf_module fname } {
	global Display_Array_0 Display_Array_1 Display_Array_2 Display_Array_3
	set bmpdata [::bmp::readfile $fname]
	# Check that bitmap is 8 x 8
	if {[lindex $bmpdata 0] != 8} {
		error [format "Error: DDF_bmp, Invalid Bitmap Dimensions %i x %i" [lindex $bmpdata 0] [lindex $bmpdata 1]]
	}
	if {[lindex $bmpdata 1] != 8} {
		error [format "Error: DDF_bmp, Invalid Bitmap Dimensions %i x %i" [lindex $bmpdata 0] [lindex $bmpdata 1]]
	}
	# Copy the RGB list
	set bmpdata [lindex $bmpdata 4]
	puts $bmpdata
	# Parse RGB list, Converting 0-255 values to F-0 values
	for {set col 0} {$col < 8} {incr col} {
		for {set row 0} {$row < 8} {incr row} {
			set red   [expr abs(([lindex [lindex $bmpdata $col] [expr $row * 3]] / 16) - 15)]
			set green [expr abs(([lindex [lindex $bmpdata $col] [expr ($row * 3) + 1]] / 16) - 15)]
			set blue  [expr abs(([lindex [lindex $bmpdata $col] [expr ($row * 3) + 2]] / 16) - 15)]
			#puts [format "Row: %i Col: %i R: %i B: %i G: %i" $row $col $red $blue $green]
			Modify_Display_Array $ddf_module $row $col [format "%X" $red] [format "%X" $green] [format "%X" $blue]
		}
	}
}

