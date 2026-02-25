encoding system utf-8

set ::workingDir [file dirname [file dirname [file normalize [info script]]]]
set ::imgSize 16
source $::workingDir/scripts/utils.tcl

wm withdraw .
set ::appmenu [menu .appPopup -tearoff 0 -relief flat -background $::menuBackground -foreground $::menuForeground]

set fp [open $::workingDir/appmenu]
set data [read $fp]
close $fp

foreach line [split $data "\n"] {
    if {[string trim $line] == ""} {
        $::appmenu add separator
    } else {
        set img [::uuid::uuid generate]
        if {[string trim [lindex [split $line ":"] 2]] != "" && [file exists [string trim $::workingDir/images/$::imgSize/[lindex [split $line ":"] 2]]]} {
            image create photo $img -file [string trim $::workingDir/images/$::imgSize/[lindex [split $line ":"] 2]]
        } else {
            image create photo $img -file [string trim $::workingDir/images/$::imgSize/applications-system.png]
        }
        $::appmenu add command -label [lindex [split $line ":"] 0] -command [list ::runProg "[lindex [split $line ":"] 1]"] -image $img -compound left -activebackground $::abg
    }
}

tk_popup $::appmenu 5 20
