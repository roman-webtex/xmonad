encoding system utf-8

set ::workingDir [file dirname [file dirname [file normalize [info script]]]]
set ::imgSize 16
source $::workingDir/scripts/utils.tcl

wm withdraw .

set ::mcascade ""
set ::appmenu [menu .appPopup -tearoff 0 -relief flat -background $::menuBackground -foreground $::menuForeground]

set fp [open $::workingDir/appmenu]
set data [read $fp]
close $fp

foreach line [split $data "\n"] {
    if {[string trim $line] == ""} {
        $::appmenu add separator
    } else {
        set sline [split $line ":"]
        set img [::uuid::uuid generate]
        
        if {[string trim [lindex $sline 2]] != "" && [file exists [string trim $::workingDir/images/$::imgSize/[lindex $sline 2]]]} {
            image create photo $img -file [string trim $::workingDir/images/$::imgSize/[lindex $sline 2]]
        } else {
            image create photo $img -file [string trim $::workingDir/images/$::imgSize/applications-system.png]
        }

        if {[string trim [lindex $sline 1]] == ">"} {
            set ::mcascade ".[::uuid::uuid generate]"
            menu $::appmenu$::mcascade -tearoff 0 -relief flat -background $::menuBackground -foreground $::menuForeground
            $::appmenu add cascade -menu $::appmenu$::mcascade -image $img -compound left -activebackground $::abg -label " [padr [lindex $sline 0] 15]"
            continue
        } elseif {[string trim [lindex $sline 1]] == "<"} {
            set ::mcascade ""
            continue
        }
        
        $::appmenu$::mcascade add command -label " [padr [lindex $sline 0] 15]" -command [list ::runProg "[lindex $sline 1]"] -image $img -compound left -activebackground $::abg
    }
}

tk_popup $::appmenu 5 20

