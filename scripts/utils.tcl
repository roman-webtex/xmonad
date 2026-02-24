package require Tk
package require md5
package require apave
package require uuid


foreach font_name [font names] {
    font configure $font_name -size 8
}

set fg "#fff"
set bg "#5285cc"
set afg "#000"
set abg "#5260ee"

ttk::style configure TLabel -background $bg
ttk::style configure TLabel -foreground $fg
ttk::style configure TButton -background $bg
ttk::style configure TButton -foreground $fg
ttk::style map TButton -background  [list pressed $bg active $abg] -foreground  [list pressed $fg active $afg]
ttk::style map TMenuitem -background  [list pressed $bg active $abg] -foreground  [list pressed $fg active $afg]

set ::menuBackground $bg
set ::menuForeground $fg


proc setWindowLabel { label } {
    if {[winfo exists $::window_name]} {
        destroy $::window_name
        exit
    }

    wm withdraw .
    toplevel $::window_name
    wm geometry $::window_name -10+20
    wm overrideredirect $::window_name 1
    bind $::window_name <Escape> {exit}

    pack [ttk::label $::window_name.title -text [format "%50s" [padAll $label 50]] -relief flat] -fill x
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
    #tk_messageBox -message "USB flash" -detail "Пристрій можна забрати." -icon info
    # unote message
    exec echo "type=text,geometry=-5+20,padx=25,pady=25,duration=10,fg=fff,bg=5285ee,bd=000,text=|Пристрій можна витягнути" | nc localhost 7779 &
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

proc padAll {text length {fill " "} } {
    set tlength [string length $text]
    set countAdd [expr {int (($length - $tlength) / 2)}]
    return [string repeat $fill $countAdd]$text[string repeat $fill $countAdd]
}
