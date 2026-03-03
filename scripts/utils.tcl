package require Tk
package require apave
package require uuid

foreach font_name [font names] {
    font configure $font_name -size 9 -family "Input Mono Condensed"
}

set ::fg "#fff"
set ::bg "#6aa0d9" 
set ::afg "#000"
set ::abg "#708dab"

ttk::style configure TLabel -background $::bg
ttk::style configure TLabel -foreground $::fg
ttk::style configure TButton -background $::bg
ttk::style configure TButton -foreground $::fg
ttk::style map TButton -background  [list pressed $::bg active $::abg] -foreground  [list pressed $::fg active $::afg]
ttk::style map TMenuitem -background  [list pressed $::bg active $::abg] -foreground  [list pressed $::fg active $::afg]

set ::menuBackground $bg
set ::menuForeground $fg
set ::wgeo "-25+20"


proc setWindowLabel { label } {

    wm withdraw .
    toplevel $::window_name
    wm geometry $::window_name $::wgeo
    wm overrideredirect $::window_name 1

    pack [ttk::label $::window_name.title -text [format "%50s" [padc $label 50]] -relief flat -padding "1 3 1 3"] -fill x
    bind $::window_name.title <Button-1> {exit}
    update
}

proc runProg { name } {
    if {[string trim $name] != ""} {
        catch {[exec $name] errorMessage}
    }
    exit
}

proc umountDisk { name } {
    if {[string trim $name] != ""} {
        exec udiskie-umount $name
    }
    # tcl/tk messagebox
    #tk_messageBox -message "USB flash" -detail "Тепер пристрій можна витягнути" -icon info
    # unote message
    exec echo "type=text,geometry=$::wgeo,padx=25,pady=25,duration=7,fg=fff,bg=$::bg,text=|Тепер пристрій можна витягнути" | nc localhost 7779 &
    exit
}

proc changeNet { ssid secur active} {
    if {[string trim $ssid] != "" && $active != "*"} {
        if {[file exists /etc/NetworkManager/system-connections/[string trim $ssid].nmconnection]} {
            catch {[exec nmcli connection up [string trim "$ssid"]] errorMessage}
        } else {
            if {[string trim $secur] != ""} {
                apave::APave create pave
                pave csSet -2 .
                set loginFrame .loginFrame
                set content {
                    {fra  - - - - {-st news -padx 5 -pady 5}}
                    {fra.lab2 - - 1 1 {-st es}  {-t "Пароль: "}}
                    {fra.ent2 fra.lab2 L 1 9 {-st wes} {-tvar ::password }}
                    {fra.seh1 fra.lab2 T 1 10 }
                    {fra.butOk fra.seh1 T 1 5 {-st es} {-t "Ok" -com "pave res $loginFrame 1"}}
                    {fra.butCancel fra.butOk L 1 5 {-st wes} {-t "Відміна" -com "pave res $loginFrame 0"}}
                }
                pave makeWindow $loginFrame "Вхід"
                pave paveWindow $loginFrame $content
                focus $loginFrame
                grab $loginFrame
                set res [pave showModal $loginFrame -focus .loginFrame.fra.ent2]
                destroy $loginFrame
                destroy pave

                if {[string trim $res] == 0} {
                    exit
                }
                catch {[exec nmcli con add type wifi con-name $ssid ssid $ssid wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$::password"] errorMessage}
            } else {
                catch {[exec nmcli con add type wifi con-name $ssid ssid $ssid wifi-sec.key-mgmt none] errorMessage}
            }
            catch {[exec nmcli connection up [string trim "$ssid"]] errorMessage}
        }
    }
    exit
}

proc creaDriveWindow { data } {
    foreach line [split $data "\n"] {
        if {[regexp -nocase "media" $line] == 1} {
            set mnt [lindex [split $line] 0]
            set nam [lindex [split $line] 2]
            pack [ttk::button $::window_name.lbl_[::uuid::uuid generate] -text [format "%-50s" $nam] -command [list ::umountDisk "$mnt"]] -fill x
        }
    }
}

proc creaNetWindow { data } {
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
                set w_id [::uuid::uuid generate]
                pack [ttk::button $::window_name.lbl_$w_id -text [format "%-5s %-25s %-8s" $active $SSID $GRAPH] -command [list ::changeNet $SSID $SECUR $active]] -fill x
                if {[string trim $SECUR] != ""} {
                    $::window_name.lbl_$w_id configure -image $imgSecur -compound right
                }
            }
        }
    }
}

proc padc {text length {fill " "} } {
    set tlength [string length $text]
    set countAdd [expr {int (($length - $tlength) / 2)}]
    return [string repeat $fill $countAdd]$text[string repeat $fill $countAdd]
}

proc padl {text length {fill " "} } {
    set tlength [string length $text]
    set countAdd [expr {int ($length - $tlength)}]
    return [string repeat $fill $countAdd]$text
}

proc padr {text length {fill " "} } {
    set tlength [string length $text]
    set countAdd [expr {int ($length - $tlength)}]
    return $text[string repeat $fill $countAdd]
}

proc handleFileEvent { f prog} {
    set status [catch { gets $f line } result]
    if { $status != 0 } {
        close $f
    } elseif { $result >= 0 } {
        $prog $line
    } elseif { [eof $f] } {
        close $f
    }
}