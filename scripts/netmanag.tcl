encoding system utf-8
package require Tk
package require apave
set ::password ""

proc changeNet { ssid secur} {
    if {[string trim $ssid] != ""} {
        if {[file exists /etc/NetworkManager/system-connections/[string trim $ssid].nmconnection]} {
            catch {[exec nmcli connection up [string trim "$ssid"]] errorMessage}
        } elseif {[string trim $secur] != ""} {
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
            catch {[exec nmcli dev wifi connect [string trim "$ssid"] password "$::password"] errorMessage}
        } else {
            catch {[exec nmcli connection up [string trim "$ssid"]] errorMessage}
        }
    }
    exit
}

foreach font_name [font names] {
    font configure $font_name -size 8
}

wm withdraw .
set ::nmmenu [menu .nmPopup -tearoff 0]

$::nmmenu add command -label "Мережеві підключення" 
tk_popup $::nmmenu 500 100
update

exec nmcli dev wifi | sed -E "s/(\[\[:space:\]\]+)/>/g" > /tmp/connection.tmp
set fp [open /tmp/connection.tmp]
set data [read $fp]
close $fp
file delete /tmp/connection.tmp

foreach line [split $data "\n"] {
    set parts [split $line ">"]
    if {[lindex $parts 0] != "IN-USE"} {
        set active [lindex $parts 0]
        set SSID [lindex $parts 2]
        set GRAPH [lindex $parts 8]
        set PROC [lindex $parts 7]
        set SECUR "[lindex $parts 9] [lindex $parts 10]"
        if {[string trim $SSID] != ""} {
            if {$active == "*"} {
                $::nmmenu add command -label [format "%-5s %-15s %-8s %-12s" $active $SSID $GRAPH $SECUR] 
            } else {
                $::nmmenu add command -label [format "%-5s %-15s %-8s %-12s" $active $SSID $GRAPH $SECUR] -command [list ::changeNet $SSID $SECUR]
            }
        }
    }
}

