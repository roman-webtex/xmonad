encoding system utf-8

set ::workingDir [file dirname [file dirname [file normalize [info script]]]]
set ::imgSize 16
set ::password ""
source $::workingDir/scripts/utils.tcl

set ::window_name ".[::uuid::uuid generate]"

::setWindowLabel "Мережеві підключення"
if {[file exists /tmp/connection.tmp]} {
    ::creaNetWindow
}

exec nmcli dev wifi | sed -E "s/(\[\[:space:\]\]+)/>/g" > /tmp/connection.tmp
::creaNetWindow
