global listenerFont

switch $tcl_platform(platform) {
	unix {
		set listenerFont "Courier 12"
	}

	windows - macintosh {
		set listenerFont "Courier 10"
	}
}

###   ###   ###   ###   ###   ###   ###
#	:main

proc {main} {argc argv} {
}

#####################################################################################################
# :source_env

proc source_env { name } {
global xlispPath

    if {[file exists $name] == 1} {
	source $name
    } else {
	foreach entry $xlispPath {
	    if {[file exists "$entry$name"] == 1} {
		source "$entry$name"
		return
	    }
	}
	tk_messageBox -message "Cannot find $name" -icon error
    }
}

###   ###   ###   ###   ###   ###   ###
#	:vTclWindow.xlispWindow
#
# 	LISTENER CODE

proc vTclWindow.xlispWindow {base title x y} {
global listenerFont

    if {$base == ""} {
        set base .xlisp
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm title $base $title

	frame $base.lframe
	text $base.lframe.listener -relief sunken -bd 2 -yscrollcommand [list $base.lframe.scroll set] -setgrid 1 -height 30\
	  -wrap char -font $listenerFont -foreground red
	scrollbar $base.lframe.scroll -command [list $base.lframe.listener yview]
	pack $base.lframe.scroll -side right -fill y
	pack $base.lframe.listener -expand yes -fill both
	pack $base.lframe -fill both -expand yes

	.xLispTk.lframe.listener tag configure Output -foreground black

	bind .xLispTk.lframe.listener <Control-Return> {
	    .xLispTk.lframe.listener insert insert \n {}
	    .xLispTk.lframe.listener see insert
	    break
	}

	bind .xLispTk.lframe.listener <Return> {
	    .xLispTk.lframe.listener mark set insert {insert lineend}
	    set l_start [.xLispTk.lframe.listener tag prevrange Output insert]
	    if [llength $l_start] {
		set l_start [lindex $l_start 1]
	    } else {
		set l_start {1.0}
	    }
	    set l_end [.xLispTk.lframe.listener tag nextrange Output insert]
	    if [llength $l_end] {
		set l_end [lindex $l_end 0]
	    } else {
		set l_end insert
	    }
	    set l_cmd [.xLispTk.lframe.listener get $l_start $l_end]
	    xlisp_top $l_cmd
            #xlisp tcl-eval-print $l_cmd
	    break
	}
}

bind Text <KeyPress> { %W insert insert %A {} }

vTclWindow.xlispWindow .xLispTk "Console" 10 10

main $argc $argv
