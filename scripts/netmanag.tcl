encoding system utf-8

set ::workingDir [file dirname [file dirname [file normalize [info script]]]]
set ::imgSize 16
set ::password ""
source $::workingDir/scripts/utils.tcl

set ::window_name ".[::md5::md5 [info script]]"

::setWindowLabel "Мережеві підключення"

exec nmcli dev wifi | sed -E "s/(\[\[:space:\]\]+)/>/g" > /tmp/connection.tmp
set fp [open /tmp/connection.tmp]
set data [read $fp]
close $fp
file delete /tmp/connection.tmp
set imgSecur [image create photo img_Secur -file [string trim $::workingDir/images/$::imgSize/kgpg.png]]

foreach line [split $data "\n"] {
    set parts [split $line ">"]
    if {[lindex $parts 0] != "IN-USE"} {
        set active [lindex $parts 0]
        set SSID [lindex $parts 2]
        set GRAPH [lindex $parts 8]
        set PROC [lindex $parts 7]
        set SECUR [lindex $parts 9]
        if {$active == ""} {
            set active " "
        }
        if {[string trim $SSID] != ""} {
            pack [ttk::button $::window_name.lbl_$SSID -text [format "%-5s %-20s %-8s" $active $SSID $GRAPH] -command [list ::changeNet $SSID $SECUR $active]] -fill x
            if {[string trim $SECUR] != ""} {
                $::window_name.lbl_$SSID configure -image $imgSecur -compound right
            }
        }
    }
}

