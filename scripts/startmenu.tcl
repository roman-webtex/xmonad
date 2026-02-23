encoding system utf-8
package require Tk
package require uuid

set ::workingDir [file dirname [file dirname [file normalize [info script]]]]
set ::imgSize 16

proc runProg { name } {
    if {[string trim $name] != ""} {
        catch {[exec $name] errorMessage}
    }
    exit
}

foreach font_name [font names] {
    font configure $font_name -size 8
}

wm withdraw .
set ::appmenu [menu .appPopup -tearoff 0 -relief flat]

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
        $::appmenu add command -label [lindex [split $line ":"] 0] -command [list ::runProg "[lindex [split $line ":"] 1]"] -image $img -compound left
    }
}

tk_popup $::appmenu 5 20
