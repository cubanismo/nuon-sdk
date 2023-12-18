



#######################################################################

option add *Hierlist.activeColor gray widgetDefault
option add *Hierlist.indent 15 widgetDefault
option add *Hierlist.hbox.background white widgetDefault
option add *Hierlist.hbox.width 80 widgetDefault
option add *Hierlist.hbox.height 10 widgetDefault
option add *Hierlist.hbox.cursor center_ptr widgetDefault
option add *Hierlist.hbox.font "Courier 10" widgetDefault
#    -*-courier-medium-r-normal-sans-*-120-* widgetDefault
#    -*-lucida-medium-r-normal-sans-*-120-* widgetDefault
option add *Entry.background white startupFile

global hierInfo
global hierInfo(sideArrow)
global hierInfo(downArrow)

global varAddrs
global varValues
global varNumValues
global varFormat
global varValuesStatus
global nodeState
global arrayRanges
global structFlags
global arrayFlags
global nodeChildren
global nodeLabels



set sidearrow {R0lGODdhCgAKAIAAAAAAAP///ywAAAAACgAKAAACEYyPB5C6HdZLcjpJcWbNwlQAADs=}
set downarrow {R0lGODdhCgAKAIAAAAAAAP///ywAAAAACgAKAAACD4yPqXvg7wyEbSaqItuqAAA7}

set hierInfo(sideArrow) [image create photo -data $sidearrow]

set hierInfo(downArrow) [image create photo  -data $downarrow]

proc ldelete { list value } {
	set ix [lsearch -exact $list $value]
	if {$ix >= 0} {
		return [lreplace $list $ix $ix]
	} else {
		return $list
	}
}

proc hierlist_create {mpe win {name "root"}} {
    global nodeChildren

    frame $win -class Hierlist
    scrollbar $win.sbar -command "$win.hbox yview"
    pack $win.sbar -side right -fill y
    text $win.hbox -wrap none -takefocus 0 \
        -yscrollcommand "$win.sbar set" -font "Courier 10"
    pack $win.hbox -side left -expand yes -fill both

    set tabsize [option get $win indent Indent]
    set tabs "15"
    for {set i 1} {$i < 20} {incr i} {
        lappend tabs [expr $i*$tabsize+15]
    }
    $win.hbox configure -tabs $tabs


  

    set btags [bindtags $win.hbox]
    set i [lsearch $btags Text]
    if {$i >= 0} {
        set btags [lreplace $btags $i $i]
    }
    bindtags $win.hbox $btags

    $win.hbox delete 1.0 end
    $win.hbox mark set "$name:start" 1.0
    $win.hbox mark gravity "$name:start" left
    set nodeChildren($win:$name) {}

    return $win
}


proc hierlist_delete_children {mpe win parent} {
    global nodeChildren

    if {![info exists nodeChildren($win:$parent)]} {
	return
    }
    foreach child $nodeChildren($win:$parent) {
#   tk_messageBox -message "delete children - parent=$parent"
    	hierlist_delete_node $win $child    
    	if {![info exists nodeChildren($win:$parent)]} {
		return
    	}
    }

}

proc hierlist_delete_node {win node} {
	global varAddrs
    global varValues
    global varNumValues
    global nodeState
    global varValuesStatus
    global nodeChildren
    global nodeLabels
    global arrayRanges
    global structFlags
    global arrayFlags
    global g_globalBrowserVars0
    global g_globalBrowserVars3
    global g_globalBrowserId


	set nl [split $node -]
	set nl [lreplace $nl end end]
	set parent [join $nl -]	

	hierlist_erase $win $node $parent

	if {![info exists nodeChildren($win:$node)]} {
		return
	}
        if {$parent == $g_globalBrowserId(0)} {
		unset g_globalBrowserVars0($node)
        } elseif {$parent == $g_globalBrowserId(3)} { 
		unset g_globalBrowserVars3($node)
	}
#	tk_messageBox -message "delete node - node=$node"
	
	unset nodeChildren($win:$node)
	unset nodeLabels($win:$node)
	unset varAddrs($win:$node)
	unset varValues($win:$node)
	unset varNumValues($win:$node)
	unset nodeState($win:$node)
	unset arrayRanges($win:$node)
	unset structFlags($win:$node)
	unset arrayFlags($win:$node)
	set varValuesStatus($win:$node) 0

	if {[info exists nodeChildren($win:$parent)]} {
		set nodeChildren($win:$parent) [ldelete $nodeChildren($win:$parent) $node]
	}
}


proc hierlist_update_node {mpe win node value} {
	global varValues
	global varNumValues
	global varFormat

	set varNumValues($win:$node) $value
  	if {$varFormat($win:$node) == "Dec"} {
		set value [expr $value * 1]
        } elseif {$varFormat($win:$node) == "ASCII"} {
		set value [expr $value * 1]
		if {[expr abs($value) >= 16777216]} {
			set value1 [expr $value >> 24]
			set value2 [expr ($value >> 16) & 255]
			set value3 [expr ($value >> 8) & 255]
			set value4 [expr $value & 255]
		  	set value [format "%c%c%c%c" $value1 $value2 $value3 $value4]	
		} elseif {$value >= 65536} {
			set value1 [expr $value >> 16]
			set value2 [expr ($value >> 8) & 255]
			set value3 [expr $value & 255]
	  		set value [format "%c%c%c" $value1 $value2 $value3]	
		} elseif {$value >= 256} {
			set value1 [expr $value >> 8]
			set value2 [expr $value & 255]
		  	set value [format "%c%c" $value1 $value2]	
		} else {
	  		set value [format "%c" $value]
		}	
	} 

	set varValues($win:$node) $value
}


proc hierlist_add_child {mpe win parent node name addr value struct {size 0} {from 0} {to 0}} {
	global varAddrs
    global varValues
    global varValuesStatus
    global varNumValues
    global nodeState
    global arrayRanges
    global structFlags
    global arrayFlags
    global nodeChildren
    global nodeLabels

#	if {![info exists nodeChildren($win:$node)]} {
#		return
#	}
	set nodeChildren($win:$parent) [linsert $nodeChildren($win:$parent) 0 $node]

	set nodeLabels($win:$node) $name
	set varAddrs($win:$node) $addr
	set varValues($win:$node) $value
	set varNumValues($win:$node) $value
	set nodeState($win:$node) 0
	set nodeChildren($win:$node) {}

	set varValuesStatus($win:$node) 1
	set arrayRanges($win:$node) "$from..$to"
	set structFlags($win:$node) $struct
	set arrayFlags($win:$node) $size
# 	tk_messageBox -message "size=$size"


	hierlist_insert_node $mpe $win $parent $node $struct $size

}


proc hierlist_node_query {mpe win node} {
	global varValues
	global varValuesStatus
#
#
#

	if {[info exists varValues($win:$node)]} {	
		if { $varValuesStatus($win:$node) == 1} {
			return 1
		} else {
			return 0
		}
	} else {
		return 0
	}
}


proc hierlist_insert {mpe win node} {
    global hierInfo
    global varValues
    global varNumValues
    global g_browserFont
    global structFlags
    global arrayFlags
    global nodeChildren
    global nodeLabels

	set room "\t\t\t\t\t\t\t\t\t\t\t\t\t"

#    option add *Label*font $g_browserFont
    option add *Entry*font $g_browserFont
	
    set indent "\t"

    foreach digit [split $node "-"] {
        append indent "\t"
    }

    set activebg [option get $win activeColor Color]
    $win.hbox mark set pos "$node:start"

    foreach subnode $nodeChildren($win:$node) {
        if {$structFlags($win:$subnode) != 0} {
            set arrow "$win.hbox.arrow-$subnode"
            label $arrow -image $hierInfo(sideArrow) \
                -borderwidth 0 
            bind $arrow <ButtonPress-1> \
                "hierlist_expand $mpe $win $subnode"
            $win.hbox window create pos -window $arrow
        }

        $win.hbox insert pos \
            "$indent$nodeLabels($win:$subnode)" {$subnode $subnode-name}

        if {$arrayFlags($win:$subnode) != 0} {
            $win.hbox insert pos "\[" $subnode
            set array_en "$win.hbox.aentry-$subnode"
            entry $array_en -textvariable arrayRanges($win:$subnode) -width 5 -borderwidth 0
	    bind $array_en <Return> [list hierlist_range_CB $mpe $win $subnode]
            $win.hbox window create pos -window $array_en
            $win.hbox insert pos "\]" $subnode
        }

        $win.hbox insert pos "$room" $subnode


        set en "$win.hbox.entry-$subnode"

        entry $en -textvariable varValues($win:$subnode) -width 45 -borderwidth 0
	bind $en <ButtonRelease> [list dummyTextEvent 0]

#	set m [menu $en.menu -tearoff 0]
#	$m add command -label "Change (Del/Add)" 
#	$m add command -label Delete 
#	bind $en <Button-3> [list tk_popup $m %X %Y]


        $win.hbox window create pos -window $en
		
        $win.hbox insert pos \
            "\n" $subnode


        $win.hbox tag bind $subnode <Enter> \
            [list $win.hbox tag configure $subnode -background $activebg]

        $win.hbox tag bind $subnode <Leave> \
            [list $win.hbox tag configure $subnode -background {}]

        $win.hbox mark set "$subnode:start" pos
        $win.hbox mark gravity "$subnode:start" left

 
    }
    $win.hbox mark set "$node:end" pos
}

proc hierlist_change_format {en win subnode} {
   global varValues
   global varNumValues
   global varFormat
  

   set value $varNumValues($win:$subnode)

  if {$varFormat($win:$subnode) == "Dec"} {
	set value [expr $value * 1]
  } elseif {$varFormat($win:$subnode) == "ASCII"} {
	set value [expr $value * 1]
	if {[expr abs($value) >= 16777216]} {
		set value1 [expr $value >> 24]
		set value2 [expr ($value >> 16) & 255]
		set value3 [expr ($value >> 8) & 255]
		set value4 [expr $value & 255]
	  	set value [format "%c%c%c%c" $value1 $value2 $value3 $value4]	
	} elseif {$value >= 65536} {
		set value1 [expr $value >> 16]
		set value2 [expr ($value >> 8) & 255]
		set value3 [expr $value & 255]
	  	set value [format "%c%c%c" $value1 $value2 $value3]	
	} elseif {$value >= 256} {
		set value1 [expr $value >> 8]
		set value2 [expr $value & 255]
	  	set value [format "%c%c" $value1 $value2]	
	} else {
	  	set value [format "%c" $value]
	}
  } else {
  	set value [format "0x%08x" $value]
  }
  set varValues($win:$subnode) $value
}

proc hierlist_insert_node {mpe win parent subnode struct array} {
    global g_nShowLocalAddresses
    global hierInfo
    global varValues
    global varNumValues
    global g_browserFont
    global arrayRanges
    global nodeChildren
    global nodeLabels
    global varFormat    
    global varAddrs
    global g_globalBrowserVars0
    global g_globalBrowserVars3
    global g_globalBrowserId

    if {$parent == $g_globalBrowserId(0)} {
		set g_globalBrowserVars0($subnode) $nodeLabels($win:$subnode)
    } elseif {$parent == $g_globalBrowserId(3)} { 
		set g_globalBrowserVars3($subnode) $nodeLabels($win:$subnode)
    }



	set room "\t\t\t\t\t\t\t\t\t\t\t\t\t"

#    option add *Label*font $g_browserFont
    option add *Entry*font $g_browserFont
	
    set indent ""

    set i 0
    foreach digit [split $subnode "-"] {
	if [expr $i > 1] {
	        append indent "\t"
	}
	incr i
    }
# b0d0e0
    set activebg [option get $win activeColor Color]

    $win.hbox mark set pos "$parent:start"

        if {$struct == 1} {
            set arrow "$win.hbox.arrow-$subnode"
            label $arrow -image $hierInfo(sideArrow) \
                -borderwidth 0
            bind $arrow <ButtonPress-1> \
                "hierlist_expand $mpe $win $subnode"
            $win.hbox window create pos -window $arrow
        }

	set l  "$win.hbox.label+$subnode"
	if {$g_nShowLocalAddresses($mpe) == 1} {
		set lAddr [format " @ %08x" $varAddrs($win:$subnode)]
	} else {
		set lAddr ""
	}
        label $l -text "$indent$nodeLabels($win:$subnode)$lAddr" -borderwidth 0 -bg white 

	if [expr $i <= 2] {
		set ml [menu $l.menu -tearoff 0]
		$ml add command -label "Delete"  -command [list hierlist_delete_node $win $subnode]
		bind $l <Button-3> [list tk_popup $ml %X %Y]
	}
        $win.hbox window create pos -window $l

#        $win.hbox insert pos "$indent$nodeLabels($win:$subnode)" $subnode

        if {$array > 0} {
            $win.hbox insert pos "\[" $subnode
            set array_en "$win.hbox.aentry-$subnode"
            entry $array_en -textvariable arrayRanges($win:$subnode) -width 5 -borderwidth 0
	    bind $array_en <Return> [list hierlist_range_CB $mpe $win $subnode]
            $win.hbox window create pos -window $array_en
            $win.hbox insert pos "\]" $subnode
        }

#	set rl  "$win.hbox.label+$subnode+room"
#       label $rl -text $room -borderwidth 0 
#	$win.hbox window create pos -window $rl

        $win.hbox insert pos "$room" $subnode 


        set en "$win.hbox.entry-$subnode"

        entry $en -textvariable varValues($win:$subnode) -width 45 -borderwidth 0 
	bind $en <ButtonRelease> [list dummyTextEvent 0]
	bind $en <Return> [list hierlist_update_CB $mpe $win $subnode]

	set varFormat($win:$subnode) "Hex"
	set m [menu $en.menu -tearoff 0]
	$m add radio -label "Dec"  -variable varFormat($win:$subnode) -command [list hierlist_change_format $en $win $subnode]
	$m add radio -label "Hex" -variable varFormat($win:$subnode) -command [list hierlist_change_format $en $win $subnode]
	$m add radio -label "ASCII" -variable varFormat($win:$subnode) -command [list hierlist_change_format $en $win $subnode]
 
	if {[string first "." $varValues($win:$subnode)] != -1} {
		set varFormat($win:$subnode) "Float"
	} else {
		bind $en <Button-3> [list tk_popup $m %X %Y]
	}

        $win.hbox window create pos -window $en
		
        $win.hbox insert pos \
            "\n" $subnode


#	set line  "$win.hbox.label+$subnode+line"
#       frame $line -height 1 -width 120
#
#        $win.hbox window create pos -window $line -align top -stretch 0
#
#        $win.hbox insert pos \
#            "\n" $subnode

        $win.hbox tag bind $subnode <Enter> \
            "$win.hbox tag configure $subnode -background $activebg"

        $win.hbox tag bind $subnode <Leave> \
            "$win.hbox tag configure $subnode -background {}"

        $win.hbox mark set "$subnode:start" pos
        $win.hbox mark gravity "$subnode:start" left

	if {$struct == 1} {
    	$win.hbox mark set "$subnode:end" pos
	}
}

proc hierlist_toggle_CB {mpe win node} {
	xlisp gg-browse-toggle-entry $mpe "\"$node\""
}

proc hierlist_update_CB {mpe win node} {
    global varValues
    global varNumValues
	if [catch {set value [expr $varValues($win:$node) * 1]} result] {
		tk_messageBox -message "Only numeric values allowed!"
		return
	}
	xlisp gg-browse-set-value! $mpe "\"$node\"" $value
#	xlisp gg-browse-update $mpe "\"$node\"" "\"$varValues($win:$node)\""
}

proc hierlist_range_CB {mpe win node} {
    global arrayRanges
#tk_messageBox -message "range cb"
 	regexp {([0-9]+)?(\.+)?([0-9]+)?} $arrayRanges($win:$node) match from sep to
	if {$to == ""} {
		set to arrayRanges($win:$node)
	}
	if {$from == ""} {
		set from 0
	}
	xlisp gg-browse-range $mpe "\"$node\"" $from $to
}

proc hierlist_expand {mpe win node} {
    global hierInfo
    global nodeState
    global hierInfo
    global g_statusText
    global nodeChildren

	if {![info exists nodeChildren($win:$node)]} {
		return
	}
    
	if {$nodeChildren($win:$node) == ""} {
		set ins 0
		set oldStatus $g_statusText($mpe)
		set g_statusText($mpe) "Opening structure/array..."
		showBusy $mpe
		hierlist_toggle_CB $mpe $win $node
		hideBusy $mpe
		set g_statusText($mpe) $oldStatus
	} else {
		set ins 1
	}
	
    set arrow "$win.hbox.arrow-$node"
    set image [$arrow cget -image]

    if {$image == $hierInfo(sideArrow)} {
        $arrow configure -image $hierInfo(downArrow)
        bind $arrow <ButtonPress-1> \
            "hierlist_collapse $mpe $win $node"
		set nodeState($win:$node) 1
        if {$ins == 1} {
			hierlist_insert $mpe $win $node
		}
    }
}

proc hierlist_collapse {mpe win node} {
    global hierInfo

    set arrow "$win.hbox.arrow-$node"
    set image [$arrow cget -image]

    if {$image == $hierInfo(downArrow)} {
        $arrow configure -image $hierInfo(sideArrow)
        bind $arrow <ButtonPress-1> \
            "hierlist_expand $mpe $win $node"
		set nodeState($win:$node) 0
        $win.hbox delete "$node:start" "$node:end"
    }
}

proc hierlist_erase {win node parent} {
    global hierInfo
    global structFlags
    
	if {![winfo exists $win.hbox]} {
		return
	}
#	tk_messageBox -message "$win\n$node\n$parent"	
	set s [$win.hbox index $node:start]

	if {$structFlags($win:$node) == 0} {
       		$win.hbox delete "$s -1 lines" "$node:start"
		return
	}
    set arrow "$win.hbox.arrow-$node"

    if {![winfo exists $arrow]} {
	return
    }

    set image [$arrow cget -image]

    if {$image == $hierInfo(downArrow)} {

       $win.hbox delete "$s -1 lines" "$node:end"
    } else {
       $win.hbox delete "$s -1 lines" "$node:start"
    }

}



#######################################################################



