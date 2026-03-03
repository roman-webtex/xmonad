encoding system utf-8

set ::workingDir [file dirname [file dirname [file normalize [info script]]]]
source $::workingDir/scripts/utils.tcl

set ::window_name ".[::uuid::uuid generate]"

::setWindowLabel "Підключені пристрої"

set fp [open "| mount -l "]
fileevent $fp readable [list ::handleFileEvent $fp "::creaDriveWindow"]
