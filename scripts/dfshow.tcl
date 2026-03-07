encoding system utf-8

set ::workingDir [file dirname [file dirname [file normalize [info script]]]]
source $::workingDir/scripts/utils.tcl

set ::window_name ".[::uuid::uuid generate]"

::setEditWindowLabel "Використання дисків"

set fp [open "| df -h"]
fileevent $fp readable [list ::handleFileEvent $fp "::creaDFWindow"]
