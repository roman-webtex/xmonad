encoding system utf-8

set ::workingDir [file dirname [file dirname [file normalize [info script]]]]
source $::workingDir/scripts/utils.tcl

set ::window_name ".[::md5::md5 [info script]]"

::setWindowLabel "Підключені пристрої"

exec mount -l | awk "{ print \$3 }" > /tmp/mount.tmp
set fp [open /tmp/mount.tmp]
set data [read $fp]
close $fp
file delete /tmp/mount.tmp

foreach line [split $data "\n"] {
    if {[regexp -nocase "media" $line] == 1} {
        pack [ttk::button $::window_name.lbl_$line -text [format "%-50s" $line] -command [list ::umountDisk "$line"]] -fill x
    }
}





