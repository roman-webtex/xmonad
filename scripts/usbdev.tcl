encoding system utf-8

package require Tk

proc umountDisk { name } {
    if {[string trim $name] != ""} {
        exec udiskie-umount $name
    }
    
    tk_messageBox -message "USB flash" -detail "Пристрій можна забрати." -icon info
    exit
}

foreach font_name [font names] {
    font configure $font_name -size 8
}

wm withdraw .
set ::dskmenu [menu .dskPopup -tearoff 0]
$::dskmenu add command -label "Mounted devices" 

exec mount -l | awk "{ print \$3 }" > /tmp/mount.tmp
set fp [open /tmp/mount.tmp]
set data [read $fp]
close $fp
file delete /tmp/mount.tmp

foreach line [split $data "\n"] {
    if {[regexp -nocase "media" $line] == 1} {
        $::dskmenu add command -label $line -command [list ::umountDisk "$line"]
    }
}

tk_popup $::dskmenu 500 100





