####################################################################################################
# WATCH WINDOW

# Watch Window := .watchTop

###   ###   ###   ###   ###   ###   ###
# Globals

global g_watchBitfield
global g_watchEntryState
global g_watchEntries
global g_watchRange
global g_watchFormat 
global g_lastFormat 
global g_bRecall
set g_lastFormat "Hex"
set g_bRecall 0

set g_watchFormat "Hex"
set g_watchFracbits 0
set g_watchRange 1
set g_watchIndirect "#f"
set g_watchLocal "#t"
set g_watchCache "#t"
set g_watchBitfield ""

global g_arrWatchEntriesName
global g_arrWatchEntriesFracbits
global g_arrWatchEntriesRange
global g_arrWatchEntriesFormat
global g_arrWatchEntriesIndirect
global g_arrWatchEntriesLocal
global g_arrWatchEntriesCache
global g_arrWatchEntriesMPE
global g_bWatchAdded
set g_bWatchAdded 0
###   ###   ###   ###   ###   ###   ###
#	:dialog utilities functions...

proc dialog_create {class {win "auto"}} {
    if {$win == "auto"} {
        set count 0
        set win ".dialog[incr count]"
        while {[winfo exists $win]} {
            set win ".dialog[incr count]"
        }
    }
    toplevel $win -class $class

    wm resizable $win 0 0

    wm title $win $class
    wm group $win .

    after idle [format {
        update idletasks
        wm minsize %s [winfo reqwidth %s] [winfo reqheight %s]
    } $win $win $win]

    return $win
}


proc dialog_info {win} {
    return "$win.info"
}

proc dialog_controls {win} {
    return "$win.controls"
}

proc dialog_wait {win varName {x 0} {y 0}} {
    dialog_safeguard $win


    if {$x != 0 && $y != 0} {

	set sh [winfo screenheight $win]
	set sw [winfo screenwidth $win]
	set w [winfo reqwidth $win]
	set h [winfo reqheight $win]
	if {[expr $x + $w] > $sw } {
		set x [expr $sw - $w]
	}
	if {[expr $y + $h] > [expr $sh - 60] } {
		set y [expr $sh - $h - 60]
	}

	wm geometry $win "+$x+$y"
    } else {
	    set x [expr [winfo rootx .]+50]
	    set y [expr [winfo rooty .]+50]
	    wm geometry $win "+$x+$y"
    }

    wm deiconify $win
    tkwait visibility $win
    
    grab set $win

    vwait $varName

    grab release $win
    wm withdraw $win
}

bind modalDialog <ButtonPress> {
    wm deiconify %W
    raise %W
}
proc dialog_safeguard {win} {
    if {[lsearch [bindtags $win] modalDialog] < 0} {
        bindtags $win [linsert [bindtags $win] 0 modalDialog]
    }
}

proc setWatchFormat { format } {
	global g_watchFormat
	global g_watchFormatStr
	global g_lastFormat

	set g_watchFormatStr $format
	set g_lastFormat $format
	if {$format == "Decimal" } {
		set g_watchFormat "'decimal"
	} elseif {$format == "Hex" } {
		set g_watchFormat "'hex"
	} elseif {$format == "Binary" } {
		set g_watchFormat "'binary"
	} elseif {$format == "ASCII" } {
		set g_watchFormat "'ascii"	
	} elseif {$format == "Real" } {
		set g_watchFormat "'real"	
	}
}

###   ###   ###   ###   ###   ###   ###
#	:addWatchEntry
#	add an entry to the watch window
proc addWatchEntry {base mpe varname x y mode id} {
global g_watchName
global g_confirmStatus
global g_watchFracbits
global g_watchRange
global g_watchFormat
global g_watchFormatStr
global g_watchIndirect
global g_watchLocal
global g_watchCache
global g_lastFormat
global g_watchBitfield
global g_watchIndirect

global g_arrWatchEntriesName
global g_arrWatchEntriesFracbits
global g_arrWatchEntriesRange
global g_arrWatchEntriesFormat
global g_arrWatchEntriesIndirect
global g_arrWatchEntriesLocal
global g_arrWatchEntriesCache
global g_arrWatchEntriesMPE
global g_bWatchAdded

	set g_bWatchAdded 1

    ###################
    # CREATING WIDGETS
    ###################

    set g_watchName $varname

    if {$mode == 0} {
	set Hex 1
#	set g_watchFormat "'hex"
#	set g_watchFormatStr "Hex"
	setWatchFormat $g_lastFormat

	set g_watchFracbits 0
	set g_watchRange 1
	set g_watchIndirect "#f"
	set g_watchLocal "#t"
	set g_watchCache "#t"
	set g_watchBitfield ""
    } else {
		set g_watchFracbits [xlisp gg-watch-fracbits $mpe $id]
		set g_watchRange [xlisp gg-watch-count $mpe $id]
		set frmt [xlisp gg-watch-format $mpe $id]

		if {$frmt == "hex"} {
			set frmt "Hex"
		} elseif {$frmt == "decimal"} {
			set frmt "Decimal"
		} elseif {$frmt == "binary"} {
			set frmt "binary"
		} elseif {$frmt == "ascii"} {
			set frmt "ASCII"
		} elseif {$frmt == "Real"} {
			set frmt "real"
		}
		setWatchFormat $frmt

		if {[xlisp gg-watch-indirect? $mpe $id] == "()"} {
			set g_watchIndirect "#f"
		} else {
			set g_watchIndirect "#t"
		}
		if {[xlisp gg-watch-use-cache? $mpe $id] == "()"} {
			set g_watchCache "#f"
		} else {
			set g_watchCache "#t"
		}
		if {[xlisp gg-watch-local? $mpe $id] == "()"} {
			set g_watchLocal "#f"
		} else {
			set g_watchLocal "#t"
		}

    }
    set top [dialog_create "Add Watch Item"]

	
    bind $top <Return> [list $top.buttons.ok invoke]
    bind $top <Escape> [list $top.buttons.cancel invoke]

    frame $top.fra22 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    label $top.fra22.lab23 \
        -anchor w -borderwidth 1 -justify right -text "Symbol/Address (Hex):" -width 20 
    entry $top.fra22.ent24 \
        -textvariable g_watchName  -width 32
    label $top.fra22.lab25 \
        -anchor w -borderwidth 1 -justify right -text "Range:" -width 20
    entry $top.fra22.ent26  \
        -textvariable g_watchRange -width 32

    label $top.fra22.lab25x \
        -anchor w -borderwidth 1 -justify right -text "Bitfield Name:" -width 20
    entry $top.fra22.ent26x  \
        -textvariable g_watchBitfield -width 32

    label $top.fra22.lab32 \
        -borderwidth 1 -relief raised -text Fracbits: 
    entry $top.fra22.ent33 \
        -textvariable g_watchFracbits -width 0 
    label $top.fra22.lab34 \
        -borderwidth 1 -text scalars 
    checkbutton $top.fra22.pointer -text "Indirect (use symbol as pointer)" -variable g_watchIndirect -onvalue "#t" -offvalue "#f" -width 40 -anchor w
    checkbutton $top.fra22.local -text "Other Bus DMA Remote Bit (Internal MPE address)" -variable g_watchLocal -onvalue "#t" -offvalue "#f" -width 40 -anchor w
    checkbutton $top.fra22.cache -text "Look thru Data Cache" -variable g_watchCache -onvalue "#t" -offvalue "#f" -width 40 -anchor w
    
    set g_watchFormatStr $g_lastFormat
    menubutton $top.fra22.men35 \
        -menu $top.fra22.men35.m -padx 4 -pady 3 -relief raised \
        -textvar g_watchFormatStr -width 30 -justify left -anchor w
    menu $top.fra22.men35.m \
        -tearoff 0 
    $top.fra22.men35.m add command \
        -label Decimal -command { setWatchFormat "Decimal" }
    $top.fra22.men35.m add command \
        -label Hex -command { setWatchFormat "Hex" }
    $top.fra22.men35.m add command \
        -label Binary -command { setWatchFormat "Binary" }
    $top.fra22.men35.m add command \
        -label ASCII -command { setWatchFormat "ASCII" }
    $top.fra22.men35.m add command \
        -label Real -command { setWatchFormat "Real" }
    label $top.fra22.lab36 \
        -borderwidth 1 -relief flat -text "Format:" -width 20 -anchor w -justify left 
#    label $top.lab37 \
#       -anchor w -borderwidth 1 -text {Watch symbol} -width 43 

    frame $top.buttons \
        -borderwidth 0 -height 75 -relief groove -width 125 
    button $top.buttons.ok -text "OK" -command { set g_confirmStatus 1 } -default active -padx 12
    
    button $top.buttons.cancel -text "Cancel" -command { set g_confirmStatus 0 }

    grid $top.fra22 \
        -in $top -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab23 \
        -in $top.fra22 -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent24 \
        -in $top.fra22 -column 1 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab25 \
        -in $top.fra22 -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent26 \
        -in $top.fra22 -column 1 -row 1 -columnspan 1 -rowspan 1 

    grid $top.fra22.lab25x \
        -in $top.fra22 -column 0 -row 2 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent26x \
        -in $top.fra22 -column 1 -row 2 -columnspan 1 -rowspan 1 

    grid $top.fra22.lab32 \
        -in $top.fra22 -column 2 -row 3 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent33 \
        -in $top.fra22 -column 3 -row 3 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab34 \
        -in $top.fra22 -column 2 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.men35 \
        -in $top.fra22 -column 1 -row 3 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab36 \
        -in $top.fra22 -column 0 -row 3 -columnspan 1 -rowspan 1 
    grid $top.fra22.pointer \
        -in $top.fra22 -column 0 -row 4 -columnspan 4 -rowspan 1 
    grid $top.fra22.local \
        -in $top.fra22 -column 0 -row 5 -columnspan 4 -rowspan 1 
    grid $top.fra22.cache \
        -in $top.fra22 -column 0 -row 6 -columnspan 4 -rowspan 1 
#    grid $top.lab37 \
#       -in $top -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $top.buttons \
        -in $top -column 0 -row 2 -columnspan 1 -rowspan 1 
    grid $top.buttons.ok \
        -in $top.buttons -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 32
    grid $top.buttons.cancel \
        -in $top.buttons -column 1 -row 0 -columnspan 1 -rowspan 1 

    focus $top.fra22.ent24
    
    wm protocol $top WM_DELETE_WINDOW "$top.buttons.cancel invoke"

    dialog_wait $top g_confirmStatus $x $y
    destroy $top

    if { $g_confirmStatus == 1 } {
    	if {$g_watchBitfield != ""} {
		setWatchFormat "Hex";
	}
#	set g_arrWatchEntriesName($g_watchName) $g_watchName
#	set g_arrWatchEntriesFracbits($g_watchName) $g_watchFracbits
#	set g_arrWatchEntriesRange($g_watchName) $g_watchRange
#	set g_arrWatchEntriesFormat($g_watchName) $g_watchFormat
#	set g_arrWatchEntriesIndirect($g_watchName) $g_watchIndirect
#	set g_arrWatchEntriesLocal($g_watchName) $g_watchLocal
#	set g_arrWatchEntriesCache($g_watchName) $g_watchCache
#	set g_arrWatchEntriesMPE($g_watchName) $mpe

	watchEntryOK $mpe


    }

    return $g_confirmStatus
}



proc recallWatchEntries {} {
global g_watchName
global g_confirmStatus
global g_watchFracbits
global g_watchRange
global g_watchFormat
global g_watchFormatStr
global g_watchIndirect
global g_watchLocal
global g_watchCache
global g_lastFormat
global g_watchBitfield
global g_watchIndirect

global g_arrWatchEntriesName
global g_arrWatchEntriesFracbits
global g_arrWatchEntriesRange
global g_arrWatchEntriesFormat
global g_arrWatchEntriesIndirect
global g_arrWatchEntriesLocal
global g_arrWatchEntriesCache
global g_arrWatchEntriesMPE
global g_bRecall
	if [info exists g_arrWatchEntriesName] {
		set g_bRecall 1
		foreach {key value} [array get g_arrWatchEntriesName] {
			set g_watchName $g_arrWatchEntriesName($key)
			set g_watchFracbits $g_arrWatchEntriesFracbits($key) 
			set g_watchRange $g_arrWatchEntriesRange($key) 
			set g_watchFormat $g_arrWatchEntriesFormat($key) 
			set g_watchIndirect $g_arrWatchEntriesIndirect($key) 
			set g_watchLocal $g_arrWatchEntriesLocal($key) 
			set g_watchCache $g_arrWatchEntriesCache($key) 
			set mpe $g_arrWatchEntriesMPE($key) 
	

			unset g_arrWatchEntriesName($key)
			unset g_arrWatchEntriesFracbits($key) 
			unset g_arrWatchEntriesRange($key) 
			unset g_arrWatchEntriesFormat($key) 
			unset g_arrWatchEntriesIndirect($key) 
			unset g_arrWatchEntriesLocal($key) 
			unset g_arrWatchEntriesCache($key) 
			unset g_arrWatchEntriesMPE($key) 

			watchEntryOK $mpe
		}
		set g_bRecall 0
	}
}


###   ###   ###   ###   ###   ###   ###
#	:watchEntryOK
#	tell list about the new varuable to watch
proc watchEntryOK {mpe} {
global g_watchName
global g_watchFracbits
global g_watchRange
global g_watchFormat
global g_watchBitfield
global g_watchIndirect
global g_watchLocal
global g_watchCache

	set cpy_name $g_watchName
	set g_watchName "0x$g_watchName"
	if [catch {set g_watchName [expr $g_watchName * 1]} result] { 
		set g_watchName $cpy_name
	} else {
		set first_char [string index $cpy_name 0]
		if [regexp -nocase -- {^[abcdef]} $first_char] {
		    tk_messageBox -message "$cpy_name could be either a symbol or a hexadecimal value.  I am going to treat it as a symbol.  If you want a hex value, please type 0x$cpy_name instead."
			set g_watchName $cpy_name
      } else {
			set g_watchName "0x$cpy_name"
		}
	}

#	if {[string index $g_watchRange 1] == "x"} {
		set g_watchRange [expr $g_watchRange  * 1]
#	}

	set r [xlisp gg-watch $mpe "\"$g_watchName\"" ":format" $g_watchFormat ":popup-format" "\"$g_watchBitfield\"" ":fracbits" $g_watchFracbits \
	":count" $g_watchRange ":indirect?" $g_watchIndirect ":local?" $g_watchLocal ":use-cache?" $g_watchCache]
	destroy .addWatch
	if {$r == "()"} {
		set g_watchName "_$g_watchName"
		set r [xlisp gg-watch $mpe "\"$g_watchName\"" ":format" $g_watchFormat ":popup-format" "\"$g_watchBitfield\"" ":fracbits" $g_watchFracbits \
		":count" $g_watchRange ":indirect?" $g_watchIndirect ":local?" $g_watchLocal ":use-cache?" $g_watchCache]
		if {$r == "()"} {
			tk_messageBox -message "Symbol is unknown."
		}
	}
}
proc watchEntryCancel {} {

	destroy .addWatch
}

###   ###   ###   ###   ###   ###   ###
#	:toggleEntryState
#	select/deselect a watch entry
proc toggleWatchEntryState {base mpe id} {
global g_watchEntryState

	if {$g_watchEntryState($mpe.$id) == 1} {
		set g_watchEntryState($mpe.$id) 0
		$base configure -background #c0e0d0
	} else {
		set g_watchEntryState($mpe.$id) 1
		$base configure -background #c0d0f0
	}
}

###   ###   ###   ###   ###   ###   ###
#	:rmWatchEntry
#	remove an entry from the watch window
proc rmWatchEntry {} {
global g_watchEntryState
global g_watchEntries
global g_watchEntryCount
global g_arrWatchEntriesName
global g_arrWatchEntriesFracbits
global g_arrWatchEntriesRange
global g_arrWatchEntriesFormat
global g_arrWatchEntriesIndirect
global g_arrWatchEntriesLocal
global g_arrWatchEntriesCache
global g_arrWatchEntriesMPE

	set wFrm .watchTop.baseFrame.watchCanvas.watchFrame

	foreach {key value} [array get g_watchEntryState] {
		if {$value == 1} {
			regexp {([0-9]*).([0-9]*)} $key match mpe id
			
			set g_watchEntryState($key) 0
			
			xlisp gg-unwatch $mpe $id

			destroy $wFrm.entryFrame$mpe$id

			unset g_arrWatchEntriesName($id) 
			unset g_arrWatchEntriesFracbits($id) 
			unset g_arrWatchEntriesRange($id) 
			unset g_arrWatchEntriesFormat($id)
			unset g_arrWatchEntriesIndirect($id) 
			unset g_arrWatchEntriesLocal($id) 
			unset g_arrWatchEntriesCache($id) 
			unset g_arrWatchEntriesMPE($id) 

			set res 0
			while { $res == 0} {
				catch {unset g_watchEntries($mpe.$id.$i)} res
			}
		}
	}
}

proc rmOneWatchEntry { w mpe id } {
global g_watchEntryState
global g_watchEntries
global g_watchEntryCount

global g_arrWatchEntriesName
global g_arrWatchEntriesFracbits
global g_arrWatchEntriesRange
global g_arrWatchEntriesFormat
global g_arrWatchEntriesIndirect
global g_arrWatchEntriesLocal
global g_arrWatchEntriesCache
global g_arrWatchEntriesMPE

	set wFrm .watchTop.baseFrame.watchCanvas.watchFrame
			
	set g_watchEntryState($mpe.$id) 0


	unset g_arrWatchEntriesName($id) 
	unset g_arrWatchEntriesFracbits($id) 
	unset g_arrWatchEntriesRange($id) 
	unset g_arrWatchEntriesFormat($id)
	unset g_arrWatchEntriesIndirect($id) 
	unset g_arrWatchEntriesLocal($id) 
	unset g_arrWatchEntriesCache($id) 
	unset g_arrWatchEntriesMPE($id) 

	xlisp gg-unwatch $mpe $id
	destroy $w
			
	set res 0
	while { $res == 0} {
		catch {unset g_watchEntries($mpe.$id.$i)} res
	}
}




proc ChangeWatchEntry { name w mpe id } {
global g_watchEntryState
global g_watchEntries
global g_watchEntryCount

	set wFrm .watchTop.baseFrame.watchCanvas.watchFrame
			

	if {[addWatchEntry 0 $mpe $name 0 0 1 $id] == 1} {
		set g_watchEntryState($mpe.$id) 0
			
		xlisp gg-unwatch $mpe $id
		destroy $w
			
		set res 0
		while { $res == 0} {
			catch {unset g_watchEntries($mpe.$id.$i)} res
		}
	}
}

proc rmAllWatchEntries {mode} {
global g_watchEntryState
global g_watchEntries
global g_watchEntryCount
global g_arrWatchEntriesName
global g_arrWatchEntriesFracbits
global g_arrWatchEntriesRange
global g_arrWatchEntriesFormat
global g_arrWatchEntriesIndirect
global g_arrWatchEntriesLocal
global g_arrWatchEntriesCache
global g_arrWatchEntriesMPE
global g_bWatchAdded

	if {$mode == 0 && $g_bWatchAdded == 1} {
		set choice [tk_messageBox -message "Do you want to remove all watch entries?" -type yesno -default yes -icon question]
		if {$choice == "no"} {
			return
		}
	}

	set wFrm .watchTop.baseFrame.watchCanvas.watchFrame

	set g_bWatchAdded 0
	foreach {key value} [array get g_watchEntryState] {
		regexp {([0-9]*).([0-9]*)} $key match mpe id
			
		set g_watchEntryState($key) 0
			
		xlisp gg-unwatch $mpe $id
		destroy $wFrm.entryFrame$mpe$id

		if {$mode == 0} {			
			unset g_arrWatchEntriesName($id) 
			unset g_arrWatchEntriesFracbits($id) 
			unset g_arrWatchEntriesRange($id) 
			unset g_arrWatchEntriesFormat($id)
			unset g_arrWatchEntriesIndirect($id) 
			unset g_arrWatchEntriesLocal($id) 
			unset g_arrWatchEntriesCache($id) 
			unset g_arrWatchEntriesMPE($id) 
		}


		set res 0
		while { $res == 0} {
			catch {unset g_watchEntries($mpe.$id.$i)} res
		}
	}
}




proc rmMPEWatchEntries {mpeDst} {
global g_watchEntryState
global g_watchEntries
global g_watchEntryCount

	set wFrm .watchTop.baseFrame.watchCanvas.watchFrame

	foreach {key value} [array get g_watchEntryState] {
		regexp {([0-9]*).([0-9]*)} $key match mpe id
			
		if {$mpeDst == $mpe} {
			set g_watchEntryState($key) 0
				
			xlisp gg-unwatch $mpe $id
			destroy $wFrm.entryFrame$mpe$id
			
			set res 0
			while { $res == 0} {
				catch {unset g_watchEntries($mpe.$id.$i)} res
			}
		}
	}
}


###   ###   ###   ###   ###   ###   ###
#	SetWatchValue
#	Changes a value of a watch entry
proc SetWatchValue {mpe id count} {
global g_watchEntryValue

	set value $g_watchEntryValue($mpe.$id.$count)
#	puts "set $mpe.$id.$count $value"
	xlisp gg-set-watch-value! $mpe $id $count "\"$value\""
}


proc EnterWatch {mpe base name id count x y} {
global g_watchEntryValue
	registerHelpEvent $base [CreateBitfieldPopup $name "0x$g_watchEntryValue($mpe.$id.$count)"] $x $y
}

proc LeaveWatch {base} {
	registerHelpCancel
}


###   ###   ###   ###   ###   ###   ###
#	:CreateWatchEntry
#	creates a new entry in the watch window
proc CreateWatchEntry {base mpe id name type value} {
global g_watchEntries
global g_watchEntryState
global g_watchEntryValue
global g_watchEntryWidth
global registerFont
global g_backgroundColor
global g_foregroundColor
global g_changedColor
global g_greyColor
global tcl_platform


global g_watchName
global g_confirmStatus
global g_watchFracbits
global g_watchRange
global g_watchFormat
global g_watchFormatStr
global g_watchIndirect
global g_watchLocal
global g_watchCache
global g_lastFormat
global g_watchBitfield
global g_watchIndirect

global g_arrWatchEntriesName
global g_arrWatchEntriesFracbits
global g_arrWatchEntriesRange
global g_arrWatchEntriesFormat
global g_arrWatchEntriesIndirect
global g_arrWatchEntriesLocal
global g_arrWatchEntriesCache
global g_arrWatchEntriesMPE
global g_bRecall

	activateWatch

	set wFrm $base.baseFrame.watchCanvas.watchFrame

#	if {$g_bRecall != 1} 
		set g_watchName $name
		set g_watchFracbits [xlisp gg-watch-fracbits $mpe $id]
		set g_watchRange [xlisp gg-watch-count $mpe $id]
		set frmt [xlisp gg-watch-format $mpe $id]

		if {$frmt == "hex"} {
			set frmt "Hex"
		} elseif {$frmt == "decimal"} {
			set frmt "Decimal"
		} elseif {$frmt == "binary"} {
			set frmt "binary"
		} elseif {$frmt == "ascii"} {
			set frmt "ASCII"
		} elseif {$frmt == "Real"} {
			set frmt "real"
		}
		setWatchFormat $frmt


		if {[xlisp gg-watch-indirect? $mpe $id] == "()"} {
			set g_watchIndirect "#f"
		} else {
			set g_watchIndirect "#t"
		}
		if {[xlisp gg-watch-use-cache? $mpe $id] == "()"} {
			set g_watchCache "#f"
		} else {
			set g_watchCache "#t"
		}
		if {[xlisp gg-watch-local? $mpe $id] == "()"} {
			set g_watchLocal "#f"
		} else {
			set g_watchLocal "#t"
		}

		set g_arrWatchEntriesName($id) $g_watchName
		set g_arrWatchEntriesFracbits($id) $g_watchFracbits
		set g_arrWatchEntriesRange($id) $g_watchRange
		set g_arrWatchEntriesFormat($id) $g_watchFormat
		set g_arrWatchEntriesIndirect($id) $g_watchIndirect
		set g_arrWatchEntriesLocal($id) $g_watchLocal
		set g_arrWatchEntriesCache($id) $g_watchCache
		set g_arrWatchEntriesMPE($id) $mpe

	if {[info exists g_watchEntries($mpe.$id.0)]} {
		if {$value != $g_watchEntryValue($mpe.$id.0)} {
			$wFrm.entryFrame$mpe$id.vframe.value0 configure -fg $g_changedColor
		} else {
			$wFrm.entryFrame$mpe$id.vframe.value0 configure -fg $g_foregroundColor		
		}
		set g_watchEntryValue($mpe.$id.0) $value
		return
	} 

	set g_watchEntryValue($mpe.$id.0) $value

	set len [string length $value]
	set g_watchEntryWidth($mpe.$id) 43
	if {$len <= 20} {
		set g_watchEntryWidth($mpe.$id) 21
	}
	if {$len <= 10} {
		set g_watchEntryWidth($mpe.$id) 10	
	}

	set g_watchEntries($mpe.$id.0) $name
	set g_watchEntryState($mpe.$id) 0


	if {[string index $name 0] == "*"} {
		set addr [string trimleft $name "*"]

	} else {
		set cmdstr "\"$name\""
		set addr [xlisp gg-symbol $mpe $cmdstr]
		if {$addr == "()"} {
			set addr $name
		} else {
			set addr [format "0x%x" $addr]
		}
	}
	frame $wFrm.entryFrame$mpe$id -background #c0e0d0 -borderwidth 1 -relief sunken
	label $wFrm.entryFrame$mpe$id.name -text $name -justify left -background #c0e0d0 -borderwidth 0 -width 24 -anchor nw
	bind $wFrm.entryFrame$mpe$id.name <Button-1> [list toggleWatchEntryState $wFrm.entryFrame$mpe$id.name $mpe $id]

	set m [menu $wFrm.entryFrame$mpe$id.name.menu -tearoff 0]
	$m add command -label "Change (Del/Add)" -command [list ChangeWatchEntry $name $wFrm.entryFrame$mpe$id $mpe $id]
	$m add command -label Delete -command [list rmOneWatchEntry $wFrm.entryFrame$mpe$id $mpe $id]
	bind $wFrm.entryFrame$mpe$id.name <Button-3> [list tk_popup $m %X %Y]
	
	label $wFrm.entryFrame$mpe$id.type -text $type -justify left -background #c0e0d0 -borderwidth 0 -width 16 -anchor nw
	frame  $wFrm.entryFrame$mpe$id.aframe -background #d0e0d0
switch $tcl_platform(platform) {
	unix {
		label $wFrm.entryFrame$mpe$id.aframe.addr0 -text $addr -justify left -font $registerFont -background #c0e0d0 -borderwidth 1 -width 16 -anchor nw
	}
	windows {
		label $wFrm.entryFrame$mpe$id.aframe.addr0 -text $addr -justify left -font $registerFont -background #c0e0d0 -borderwidth 0 -width 16 -anchor nw
	}
}
	frame  $wFrm.entryFrame$mpe$id.vframe -background #d0e0d0
	entry $wFrm.entryFrame$mpe$id.vframe.value0 -textvariable g_watchEntryValue($mpe.$id.0) -width $g_watchEntryWidth($mpe.$id) \
	-borderwidth 0 -font $registerFont -fg $g_foregroundColor -bg $g_backgroundColor
	bind $wFrm.entryFrame$mpe$id.vframe.value0 <Return> [list SetWatchValue $mpe $id 0]
	set bitfield [xlisp gg-watch-popup-format $mpe $id]
        if {$bitfield == "" || $bitfield != "()"} {
	 bind $wFrm.entryFrame$mpe$id.vframe.value0 <Enter> [list EnterWatch $mpe $wFrm.entryFrame$mpe$id.name $bitfield $id 0 %X %Y]
	 bind $wFrm.entryFrame$mpe$id.vframe.value0 <Leave> [list LeaveWatch $wFrm.entryFrame$mpe$id.name]
	}

	pack $wFrm.entryFrame$mpe$id -expand true -fill x
	pack $wFrm.entryFrame$mpe$id.name -anchor nw -side left -fill none 
	pack $wFrm.entryFrame$mpe$id.type -anchor nw -side left -fill none
	pack $wFrm.entryFrame$mpe$id.aframe -anchor nw -side left -fill none
	grid $wFrm.entryFrame$mpe$id.aframe.addr0 \
        -in $wFrm.entryFrame$mpe$id.aframe -column 0 -row 0 -columnspan 1 -rowspan 1 
	pack $wFrm.entryFrame$mpe$id.vframe -anchor nw -side left -fill none
	grid $wFrm.entryFrame$mpe$id.vframe.value0 \
        -in $wFrm.entryFrame$mpe$id.vframe -column 0 -row 0 -columnspan 1 -rowspan 1 
	
	update idletasks
#	after 100
	watchResize $base 0

##	unset g_watchName
}

###   ###   ###   ###   ###   ###   ###
#	:AddWatchValue
#	add a new scalar field to a watch entry
proc AddWatchValue {base mpe id name value count} {
global g_watchEntries
global g_watchEntryState
global g_watchEntryValue
global registerFont
global g_watchEntryWidth
global g_backgroundColor
global g_foregroundColor
global g_changedColor
global g_greyColor
global tcl_platform
		
	set wFrm $base.baseFrame.watchCanvas.watchFrame


	if {[info exists g_watchEntries($mpe.$id.$count)]} {
		if {$value != $g_watchEntryValue($mpe.$id.$count)} {
			$wFrm.entryFrame$mpe$id.vframe.value$count configure -fg $g_changedColor
		} else {
			$wFrm.entryFrame$mpe$id.vframe.value$count configure -fg $g_foregroundColor		
		}
		set g_watchEntryValue($mpe.$id.$count) $value
		return
	} 

	set g_watchEntryValue($mpe.$id.$count) $value
	set g_watchEntries($mpe.$id.$count) $name

	
	if {[string index $name 0] == "*"} {
		set addr [string trimleft $name "*"]

	} else {	
		set cmdstr "\"$name\""
		set addr [xlisp gg-symbol $mpe $cmdstr]
		if {$addr == "()"} {
			set addr $name
		} else {
			catch {set addr [format "0x%x" $addr]} result
		}
	}
	if {$g_watchEntryWidth($mpe.$id) == 43} {
		if [catch { set addr [expr $addr + 4 * $count]} result] {
			set addr " "
		}
	}
	if {$g_watchEntryWidth($mpe.$id) == 21} {
		if [catch { set addr [expr $addr + 4 * ($count / 2 * 2)]} result] {
			set addr " "
		}
		
	}  else {
		if [catch { set addr [expr $addr + 4 * ($count / 4 * 4)]} result] {
			set addr " "
		}
	}

	catch { set addr [format "0x%x" $addr]} result
switch $tcl_platform(platform) {
	unix {
		label $wFrm.entryFrame$mpe$id.aframe.addr$count -text $addr -font $registerFont -justify left -background #c0e0d0 -borderwidth 1 -width 16 -anchor nw
	}
	windows {
		label $wFrm.entryFrame$mpe$id.aframe.addr$count -text $addr -font $registerFont -justify left -background #c0e0d0 -borderwidth 0 -width 16 -anchor nw
	}
}
	entry $wFrm.entryFrame$mpe$id.vframe.value$count -textvariable g_watchEntryValue($mpe.$id.$count) \
	-width $g_watchEntryWidth($mpe.$id) -borderwidth 0 -font $registerFont -bg $g_backgroundColor
	bind $wFrm.entryFrame$mpe$id.vframe.value$count <Return> [list SetWatchValue $mpe $id $count]
	set bitfield [xlisp gg-watch-popup-format $mpe $id]
        if {$bitfield == "" || $bitfield != "()"} {
	 bind $wFrm.entryFrame$mpe$id.vframe.value$count <Enter> [list EnterWatch $mpe $wFrm.entryFrame$mpe$id.name $bitfield $id $count %X %Y]
	 bind $wFrm.entryFrame$mpe$id.vframe.value$count <Leave> [list LeaveWatch $wFrm.entryFrame$mpe$id.name]
	}

	if {$g_watchEntryWidth($mpe.$id) == 10} {
		set row [expr int($count/4)]
		set col [expr $count-($row*4)]
	}
	if {$g_watchEntryWidth($mpe.$id) == 21} {
		set row [expr int($count/2)]
		set col [expr $count-($row*2)]
	}
	if {$g_watchEntryWidth($mpe.$id) == 43} {
		set row $count
		set col 0
	}
	
	grid $wFrm.entryFrame$mpe$id.vframe.value$count \
        -in $wFrm.entryFrame$mpe$id.vframe -column $col -row $row -columnspan 1 -rowspan 1 

	grid $wFrm.entryFrame$mpe$id.aframe.addr$count \
        -in $wFrm.entryFrame$mpe$id.aframe -column 0 -row $row -columnspan 1 -rowspan 1 
	
	
	update idletasks
#	after 100
	watchResize $base 0
}



###   ###   ###   ###   ###   ###   ###
#	:watchUpdate
#	callback telling us a variable has changed
proc watchUpdate {mpe id name type form value} {
global g_lastUpdateName
global g_watchCount
global g_watchEntryCount
global g_watchRange


	if {$name != "" && $name != "()"} {
		set g_watchEntryCount($mpe.$id) $g_watchRange
		set g_lastUpdateName $name
		set g_watchCount 0
		CreateWatchEntry .watchTop $mpe $id $name "$type MPE $mpe" $value
	} else {
		incr g_watchCount
		AddWatchValue .watchTop $mpe $id $g_lastUpdateName $value $g_watchCount
	}

}

###   ###   ###   ###   ###   ###   ###
#	:watchResize
#	the watch window has resized, adjust its childs
proc watchResize {base only} {
global g_lastHeight

	set wFrm $base.baseFrame.watchCanvas.watchFrame
	set h [winfo height $wFrm]
	set w [winfo width $wFrm]
	incr w 20

	if {$h < 50} {
		set h 50
	}
	if {$w < 600} {
		set w 600
	}
	$base.baseFrame.watchCanvas configure  -scrollregion [list 0 0 800 $h]
	set h2 [winfo height $base.baseFrame.titleFrame]
	set h [expr $h + $h2]
	append str $w "x" $h
	
	if {$h != $g_lastHeight && $only==0 && $h<600} {
		wm geometry $base $str
	}
	set g_lastHeight $h
	return $h
}

###   ###   ###   ###   ###   ###   ###
#	:CreateWatchWidget
#	creates a new watch window widget
proc CreateWatchWidget {base} {    
global g_lastHeight

	set g_lastHeight 0
	
	frame $base.baseFrame -height 100
	frame $base.baseFrame.titleFrame -height 20 -width 200
	label $base.baseFrame.titleFrame.name -text "Name" -width 24 -background #c0d0e0 -borderwidth 1 -relief sunken
	label $base.baseFrame.titleFrame.type -text "Type" -width 16 -background #c0d0e0 -borderwidth 1 -relief sunke
	label $base.baseFrame.titleFrame.addr -text "Address" -width 16 -background #c0d0e0 -borderwidth 1 -relief sunke
	label $base.baseFrame.titleFrame.value -text "Value" -background #c0d0e0 -borderwidth 1 -relief sunke
	canvas $base.baseFrame.watchCanvas -scrollregion {0 0 600 1000} -yscrollcommand [list $base.baseFrame.watchScrollbar set]
	scrollbar $base.baseFrame.watchScrollbar -orient vertical -command [list $base.baseFrame.watchCanvas yview]
	frame $base.baseFrame.watchCanvas.watchFrame 

	pack $base.baseFrame -side top -fill both -expand true

	pack $base.baseFrame.titleFrame -side top -fill x 
#	place $base.baseFrame.titleFrame.name   -x 2   -y 0
#	place $base.baseFrame.titleFrame.type   -x 150  -y 0
#	place $base.baseFrame.titleFrame.value  -x 250 -y 0
	pack $base.baseFrame.titleFrame.name   -anchor nw -side left -fill none
	pack $base.baseFrame.titleFrame.type   -anchor nw -side left -fill none
	pack $base.baseFrame.titleFrame.addr   -anchor nw -side left -fill none
	pack $base.baseFrame.titleFrame.value  -anchor nw -side left -fill x -expand true

	pack $base.baseFrame.watchScrollbar -side right -fill y
	pack $base.baseFrame.watchCanvas -side left -fill both -expand true
	
	$base.baseFrame.watchCanvas create window 0 0 -anchor nw -window $base.baseFrame.watchCanvas.watchFrame
	bind $base.baseFrame.watchCanvas <Configure> [list watchResize $base 1]
	bind $base <Delete> [list rmWatchEntry]

}
