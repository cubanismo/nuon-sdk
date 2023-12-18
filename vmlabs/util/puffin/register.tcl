#####################################################################################################
# REGISTER WINDOW

global g_backgroundColor
global g_foregroundColor
global g_changedColor
global g_popupColor


#### ### ### ### ### ### ### ###
# 	Register Help 
#
toplevel .registerHelp
message .registerHelp.text -text " " -background $g_popupColor -border 1 -width 120 -font {Courier 10}
pack .registerHelp.text 
wm withdraw .registerHelp
wm transient .registerHelp
wm overrideredirect .registerHelp 1

global registerHelpId
global regValue
global regValueStr
global regBitfield
global regGState
global regGName
global regArray
global g_regFirstTime

set g_regFirstTime(0) 1
set g_regFirstTime(1) 1
set g_regFirstTime(2) 1
set g_regFirstTime(3) 1

proc registerHelpShow { } {
	global .registerHelp

	wm deiconify .registerHelp 
	raise .registerHelp 

}
proc registerHelpEvent {parent msg x y} {
	global .registerHelp
	global registerHelpId

	.registerHelp.text configure -text $msg -width 400

	incr x 6
	incr y -14
	wm geometry .registerHelp +$x+$y
	set registerHelpId [after 500 registerHelpShow]
}
proc registerHelpCancel { } {
	global registerHelpId

	after cancel $registerHelpId
	wm withdraw .registerHelp
}


proc UpdateRegisters {mpe} {
global regValue
global regValueStr
global regArray
global regBase
global regGroup
global regGState
global g_backgroundColor
global g_foregroundColor
global g_changedColor
global g_popupColor

	foreach reg [array names regArray] {
#		tk_messageBox -message "Get $reg of $mpe"
		if { $regGState($mpe$regGroup($reg)) == 1 } {
			set val [xlisp gg-register "\"$reg\"" $mpe]
			if {$val == $regValue($mpe$reg)} {
				$regBase($mpe$reg) configure -fg $g_foregroundColor	
			} else {
				$regBase($mpe$reg) configure -fg $g_changedColor
 			}

			set regValue($mpe$reg) $val
			set regValueStr($mpe$reg) [format "%08x" $regValue($mpe$reg)]
		}
	}
}

proc SetRegister {mpe name base} {
global regValue
global regValueStr

	set regValue($mpe$name) [expr int(0x$regValueStr($mpe$name))]
	xlisp gg-set-register! "\"$name\"" "#x$regValueStr($mpe$name)" $mpe
}

proc CreateBitfieldPopup {name value} {
global regBitfield
	set msg ""
	set max 0
	if {![info exists name]} {
		set name "empty"
	}
	if {$name == ""} {
		set name "empty"
	}
	foreach field $regBitfield($name) {
		regexp {([^.]*).([0-9]+):([0-9]+).(.*)} $field match bname start end type
		set len [string length $bname]
		if {$len > $max} {
			set max $len
		}
	}
	incr max
	set s "s"
	foreach field $regBitfield($name) {
		regexp {([^.]*).([0-9]+):([0-9]+).(.*)} $field match bname start end type
		if {$end < 31} {
			set m1 [expr (1<<($end+1))-1]
		} else {
			set m1 -1
		}
		set j  [expr $end-$start]
		set m2 1
		while {$j > 0} {
			set m2 [expr $m2<<1]
			set m2 [expr $m2|0x01]
			incr j -1
		}
		if [catch {set mask [expr ($m1^(int(pow(2,$start)-1)))]} result] {
			return $msg
		}
		if [catch {set val [expr ((int("$value")&$mask)>>$start)&$m2]} result] {
			return $msg
		}
		append msg [format "%-$max$s $type" $bname $val] "\n"
	}
	string trimright msg
	return $msg
}



proc EnterRegister {mpe base name x y} {
global regValue
	registerHelpEvent $base [CreateBitfieldPopup $name $regValue($mpe$name)] $x $y
}


proc LeaveRegister {base name} {
global regValue
	registerHelpCancel
}

proc SetRegisterBitfield {name bits} {
global regBitfield

	set regBitfield($name) $bits
}

proc UnsetRegisterBitfield {name bits} {
global regBitfield

	unset regBitfield($name)
}


proc {CreateRegister} {mpe base name x y group} {
global regValue
global regValueStr
global regArray
global regBitfield
global regBase
global regGroup
global g_backgroundColor
global g_foregroundColor

    frame $base.$name \
        -borderwidth 0 -height 201 -relief flat -width 250 
    label $base.$name.label$name \
        -borderwidth 0 -width 10 -text $name 
	bind $base.$name.label$name <Enter> [list EnterRegister $mpe $base.$name.label$name $name %X %Y]
	bind $base.$name.label$name <Leave> [list LeaveRegister $base.$name.label$name $name]

    set regGroup($name) $group
    set regArray($name) 1
    set regValue($mpe$name) "0"
    set regValueStr($mpe$name) "00000000"
    set regBitfield($name) [list "$name.0:31.%08x" "$name.0:31.%d"]

    set regBase($mpe$name) $base.$name.value$name
	
	entry $base.$name.value$name -fg $g_foregroundColor -bg $g_backgroundColor \
        -width 8 -borderwidth 0 -textvariable regValueStr($mpe$name)
	bind $base.$name.value$name <Return> [list SetRegister $mpe $name %W]
	# hmk:
        bind $base.$name.value$name <ButtonRelease> [list dummyTextEvent $mpe]

    grid $base.$name \
        -in $base -column $x -row $y -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.$name.label$name \
        -in $base.$name -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $base.$name.value$name \
        -in $base.$name -column 1 -row 0 -columnspan 1 -rowspan 1 
}


proc {CreateRegisterGroup} {base name num color} {
global regGState
    frame $base.$name \
        -borderwidth 1 -height 201 -relief flat -width 250 -bg $color 
    label $base.$name.group$name \
        -borderwidth 0 -width 8 -text $name -background $color

    grid $base.$name \
        -in $base -columnspan 1 -rowspan 1 \
       	-sticky w 

    grid $base.$name.group$name \
       	-in $base.$name -column 0 -row 0 -columnspan 1 -rowspan 2 \
        -sticky ew
    
}

proc {ToggleGroup} {mpe base name} {
	global regGState
	global regGName
	global g_regFirstTime	
	if {$regGState($mpe$name) == 0} {
		foreach group $regGName($mpe$name) {
			grid remove $base.$group
		}
	} else {
		foreach group $regGName($mpe$name) {
			grid $base.$group
		}
		if {$g_regFirstTime($mpe) != 1} {
			UpdateRegisters $mpe
		}
	}
}

proc {CreateGroupSelector} {base mpe names groups} {
	global regGState
	global regGName
	global g_regFirstTime
    frame $base.separator$mpe -height 1 -borderwidth 0 -relief flat -bg black

    frame $base.selector$mpe \
        -borderwidth 1 -height 201 -relief flat -width 250
    pack $base.selector$mpe \
        -in $base -side bottom -fill x

    pack $base.separator$mpe -in $base -side bottom -fill x

    set i 0
	foreach group $names {
		set regGName($mpe$group) [lindex $groups $i]
		if {$g_regFirstTime($mpe) == 1} {
			set regGState($mpe$group) 1		
		}

		checkbutton $base.selector$mpe.switch$group\
      	  -text $group -variable regGState($mpe$group) -command [list ToggleGroup $mpe $base.baseframe$mpe.registers $group]
   			grid $base.selector$mpe.switch$group -in $base.selector$mpe -column $i -row 0
		incr i
	}

}

proc ClearGroup {mpe name} {
	global regGState

	set regGState($mpe$name) 0
}

proc CreateRegisterWidget {base mpe} {    
global registerFont
global g_regFirstTime
global regBitfield
	frame $base.baseframe$mpe -background white

    set regBitfield(empty) [list ".0:31.%08x" ".0:31.%d"]

	canvas $base.baseframe$mpe.regcanvas \
	-scrollregion {0 0 600 500} -yscrollcommand [list $base.baseframe$mpe.regscrollbar set]
	scrollbar $base.baseframe$mpe.regscrollbar -orient vertical -command [list $base.baseframe$mpe.regcanvas yview]

	
	CreateGroupSelector $base $mpe {General Bilinear MPE Interrupt DMA Commbus Special} \
	{{v0 v1 v2 v3 v4 v5 v6 v7} {xy uv} {sp pc mpe} {int int1 int2} {dma} {commbus} {special}} 

	pack $base.baseframe$mpe.regscrollbar -side right -fill y
	pack $base.baseframe$mpe.regcanvas -side left -fill both -expand true
	pack $base.baseframe$mpe -side top -fill both -expand true

	frame $base.baseframe$mpe.registers -width 600 -height 500

	option add *Label*font $registerFont
	option add *Entry*font $registerFont
	
	CreateRegisterGroup $base.baseframe$mpe.registers v0 4 #c0c0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.v0 r0 1 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v0 r1 2 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v0 r2 3 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v0 r3 4 0 General

	CreateRegisterGroup $base.baseframe$mpe.registers v1 4 #c0c0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.v1 r4 1 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v1 r5 2 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v1 r6 3 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v1 r7 4 0 General

	CreateRegisterGroup $base.baseframe$mpe.registers v2 4 #c0c0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.v2 r8 1 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v2 r9 2 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v2 r10 3 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v2 r11 4 0 General

	CreateRegisterGroup $base.baseframe$mpe.registers v3 4 #c0c0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.v3 r12 1 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v3 r13 2 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v3 r14 3 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v3 r15 4 0 General

	CreateRegisterGroup $base.baseframe$mpe.registers v4 4 #c0c0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.v4 r16 1 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v4 r17 2 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v4 r18 3 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v4 r19 4 0 General

	CreateRegisterGroup $base.baseframe$mpe.registers v5 4 #c0c0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.v5 r20 1 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v5 r21 2 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v5 r22 3 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v5 r23 4 0 General

	CreateRegisterGroup $base.baseframe$mpe.registers v6 4 #c0c0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.v6 r24 1 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v6 r25 2 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v6 r26 3 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v6 r27 4 0 General

	CreateRegisterGroup $base.baseframe$mpe.registers v7 4 #c0c0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.v7 r28 1 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v7 r29 2 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v7 r30 3 0 General
	CreateRegister $mpe $base.baseframe$mpe.registers.v7 r31 4 0 General

	CreateRegisterGroup $base.baseframe$mpe.registers xy 4 #c0c7c0
	CreateRegister $mpe $base.baseframe$mpe.registers.xy rx 1 0 Bilinear
	CreateRegister $mpe $base.baseframe$mpe.registers.xy ry 1 1 Bilinear
	CreateRegister $mpe $base.baseframe$mpe.registers.xy xybase 2 0 Bilinear
	CreateRegister $mpe $base.baseframe$mpe.registers.xy xyctl 3 0 Bilinear
	SetRegisterBitfield xyctl {"xywidth.0:10.%#04x" "ytile.12:15.%#04x"\
	"xtile.16:19.%#04x" "xytype.20:23.%#04x" "xymipmap.24:26.%#04x"\
	"xychnorm.28:28.%x" "xrev.29:29.%x" "yrev.30:30.%x" }
	CreateRegister $mpe $base.baseframe$mpe.registers.xy xyrange 4 0 Bilinear
	SetRegisterBitfield xyrange {"yrange.0:9.%#04x" "xrange.16:25.%#04x"}
	
	CreateRegisterGroup $base.baseframe$mpe.registers uv 4 #c0c7c0
	CreateRegister $mpe $base.baseframe$mpe.registers.uv ru 1 0 Bilinear
	CreateRegister $mpe $base.baseframe$mpe.registers.uv rv 1 1 Bilinear
	CreateRegister $mpe $base.baseframe$mpe.registers.uv uvbase 2 0 Bilinear
	CreateRegister $mpe $base.baseframe$mpe.registers.uv uvctl 3 0 Bilinear
	SetRegisterBitfield uvctl {"uvwidth.0:10.%#04x" "vtile.12:15.%#04x"\
	"utile.16:19.%#04x" "uvtype.20:23.%#04x" "uvmipmap.24:26.%#04x"\
	"uvchnorm.28:28.%x" "urev.29:29.%x" "vrev.30:30.%x" }
	CreateRegister $mpe $base.baseframe$mpe.registers.uv uvrange 4 0 Bilinear
	SetRegisterBitfield uvrange {"vrange.0:9.%#04x" "urange.16:25.%#04x"}

	CreateRegisterGroup $base.baseframe$mpe.registers sp 4 #d0d0b0
	CreateRegister $mpe $base.baseframe$mpe.registers.sp rz 1 0 MPE
	CreateRegister $mpe $base.baseframe$mpe.registers.sp sp 2 0 MPE
	CreateRegister $mpe $base.baseframe$mpe.registers.sp rc0 3 0 MPE
	CreateRegister $mpe $base.baseframe$mpe.registers.sp rc1 4 0 MPE

	CreateRegisterGroup $base.baseframe$mpe.registers pc 4 #d0d0b0
	CreateRegister $mpe $base.baseframe$mpe.registers.pc pcexec 1 0 MPE
	CreateRegister $mpe $base.baseframe$mpe.registers.pc pcroute 2 0 MPE
	CreateRegister $mpe $base.baseframe$mpe.registers.pc pcfetch 3 0 MPE
	CreateRegister $mpe $base.baseframe$mpe.registers.pc cc 4 0 MPE
	SetRegisterBitfield cc {"z.0:0.%d" "c.1:1.%d" "v.2:2.%d" "n.3:3.%d"\
	"mv.4:4.%d" "c0z.5:5.%d" "c1z.6:6.%d" "modge.7:7.%d" "modmi.8:8.%d"\
	"cf0.9:9.%d" "cf1.10:10.%d"}

	CreateRegisterGroup $base.baseframe$mpe.registers mpe 4 #d0d0b0
	CreateRegister $mpe $base.baseframe$mpe.registers.mpe mpectl 1 0 MPE
	SetRegisterBitfield mpectl {"mpeGoClr.0:0.%d" "mpeGoSet.1:1.%d" "singleStepClr.2:2.%d" "singleStepSet.3:4.%d"\
	"daRdBrkEnClr.4:4.%d" "daRdBrkEnSet.5:5.%d" "daWrBrkEnClr.6:6.%d" "daWrBrkEnSet.7:7.%d" "intToHostClr.10:10.%d"\
	"intToHostSet.11:11.%d" "resetMpe.13:14.%d" "mpeWasResetClr.14:14.%d" "mpeWasReset.15:15.%d" "cycleTypeWren.23:23.%d"\
	"cycletype.24:27.%d"}

	CreateRegister $mpe $base.baseframe$mpe.registers.mpe excepsrc 2 0 MPE
	SetRegisterBitfield excepsrc {"halt.0:0.%d" "step.1:1.%d" "instBP.2:2.%d" "dataBP.3:3.%d" "memWrite.4:4.%d"\
	"mulWrite.5:5.%d" "Bilin.6:6.%d" "dbusAddr.7:7.%d" "iportAddr.8:8.%d" "mdma.9:9.%d" "odma.10:10.%d" "cdma.11:11.%d"\
	"copro.12:12.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.mpe excepclr 3 0 MPE
	CreateRegister $mpe $base.baseframe$mpe.registers.mpe excephalten 4 0 MPE
	SetRegisterBitfield excephalten {"halt.0:0.%d" "step.1:1.%d" "instBP.2:2.%d" "dataBP.3:3.%d" "memWrite.4:4.%d"\
	"mulWrite.5:5.%d" "bilin.6:6.%d" "dbusAddr.7:7.%d" "iportAddr.8:8.%d" "mdma.9:9.%d" "odma.10:10.%d" "cdma.11:11.%d"\
	"copro.12:12.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.mpe dabreak 1 1 MPE

	CreateRegister $mpe $base.baseframe$mpe.registers.mpe dcachectl 2 1 MPE
	SetRegisterBitfield dcachectl {"cBlockSize.0:1.%d" "cWaySize.4:5.%d" "cWayAssoc.8:10.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.mpe icachectl 3 1 MPE
	SetRegisterBitfield icachectl {"cBlockSize.0:1.%d" "cWaySize.4:5.%d" "cWayAssoc.8:10.%d"}

	CreateRegisterGroup $base.baseframe$mpe.registers int 3 #e0c0c0
	CreateRegister $mpe $base.baseframe$mpe.registers.int intsrc 1 0 Interrupt
	SetRegisterBitfield intsrc {"exception.0:0.%d" "software.1:1.%d" "commrecv.4:4.%d" "commxmit.5:5.%d"\
	"mdmadone.6:6.%d" "mdmaready.7:7.%d" "odmadone.8:8.%d" "odmaready.9:9.%d" "vdmadone.12:12.%d"\
	"vdmaready.13:13.%d" "bduscdet.21:21.%d" "bdumbdone.22:22.%d" "mcudctdone.23:23.%d"\
	"mcumbdone.24:24.%d" "debug.25:25.%d" "host.26:26.%d" "audio.27:27.%d"\
	"gpio.28:28.%d" "systimer0.29:29.%d" "systimer1.30:30.%d" "vidtimer.31:31.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.int intclr 2 0 Interrupt
	SetRegisterBitfield intclr {"exception.0:0.%d" "software.1:1.%d" "commrecv.4:4.%d" "commxmit.5:5.%d"\
	"mdmadone.6:6.%d" "mdmaready.7:7.%d" "odmadone.8:8.%d" "odmaready.9:9.%d" "vdmadone.12:12.%d"\
	"vdmaready.13:13.%d" "bduscdet.21:21.%d" "bdumbdone.22:22.%d" "mcudctdone.23:23.%d"\
	"mcumbdone.24:24.%d" "debug.25:25.%d" "host.26:26.%d" "audio.27:27.%d"\
	"gpio.28:28.%d" "systimer0.29:29.%d" "systimer1.30:30.%d" "vidtimer.31:31.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.int intctl 3 0 Interrupt
	SetRegisterBitfield intctl {"imaskhw1clr.0:0.%d" "imaskhw1set.1:1.%d" "imasksw1clr.2:2.%d"\
	"imasksw1set.3:3.%d" "imaskhw2clr.4:4.%d" "imaskhw2set.5:5.%d" "imasksw2clr.6:6.%d" "imasksw2set.7:7.%d"}
	
	CreateRegisterGroup $base.baseframe$mpe.registers int1 3 #e0c0c0
	CreateRegister $mpe $base.baseframe$mpe.registers.int1 intvec1 1 0 Interrupt
	CreateRegister $mpe $base.baseframe$mpe.registers.int1 rzi1 2 0 Interrupt
	CreateRegister $mpe $base.baseframe$mpe.registers.int1 inten1 3 0 Interrupt
	SetRegisterBitfield inten1 {"exception.0:0.%d" "software.1:1.%d" "commrecv.4:4.%d" "commxmit.5:5.%d"\
	"mdmadone.6:6.%d" "mdmaready.7:7.%d" "odmadone.8:8.%d" "odmaready.9:9.%d" "vdmadone.12:12.%d"\
	"vdmaready.13:13.%d" "bduscdet.21:21.%d" "bdumbdone.22:22.%d" "mcudctdone.23:23.%d"\
	"mcumbdone.24:24.%d" "debug.25:25.%d" "host.26:26.%d" "audio.27:27.%d"\
	"gpio.28:28.%d" "systimer0.29:29.%d" "systimer1.30:30.%d" "vidtimer.31:31.%d"}

	CreateRegisterGroup $base.baseframe$mpe.registers int2 3 #e0c0c0
	CreateRegister $mpe $base.baseframe$mpe.registers.int2 intvec2 1 0 Interrupt
	CreateRegister $mpe $base.baseframe$mpe.registers.int2 rzi2 2 0 Interrupt
	CreateRegister $mpe $base.baseframe$mpe.registers.int2 inten2sel 3 0 Interrupt

	CreateRegisterGroup $base.baseframe$mpe.registers dma 4 #b0d0e0
	CreateRegister $mpe $base.baseframe$mpe.registers.dma mdmactl 1 0 DMA
	SetRegisterBitfield mdmactl {"level.0:3.%d" "pending.4:4.%d" "prior.5:6.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.dma mdmacptr 2 0 DMA
	CreateRegister $mpe $base.baseframe$mpe.registers.dma odmactl 1 1 DMA
	SetRegisterBitfield odmactl {"level.0:3.%d" "pending.4:4.%d" "prior.5:6.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.dma odmacptr 2 1 DMA

	CreateRegisterGroup $base.baseframe$mpe.registers commbus 2 #b0e0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.commbus commctl 1 0 Commbus
	SetRegisterBitfield commctl {"txTargetID.0:7.%#02x" "txBusLock.12:12.%d" "txRetry.13:13.%d"\
	"txFailed.14:14.%d" "txFull.15:15.%d" "rxSenderID.16:23.%#02x" "rxDisable.30:30.%d" "rxFull.31:31.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.commbus comminfo 2 0 Commbus
	SetRegisterBitfield comminfo {"txinfo.0:7.%#02x" "rxinfo.16:23.%#02x"}

	CreateRegisterGroup $base.baseframe$mpe.registers special 4 #f0e0d0
	CreateRegister $mpe $base.baseframe$mpe.registers.special linpixctl 1 0 Special
	SetRegisterBitfield linpixctl {"linpixType.20:23.%d" "linpixChnorm.28:28.%d"}
	CreateRegister $mpe $base.baseframe$mpe.registers.special clutbase 2 0 Special
	CreateRegister $mpe $base.baseframe$mpe.registers.special svshift 3 0 Special
	CreateRegister $mpe $base.baseframe$mpe.registers.special acshift 4 0 Special
	
	$base.baseframe$mpe.regcanvas create window 0 0 -anchor nw -window $base.baseframe$mpe.registers

#	foreach group { Bilinear DMA Special } {
#		ClearGroup $mpe $group
#	}

	foreach group {General Bilinear MPE Interrupt DMA Special Commbus } {	
		ToggleGroup $mpe $base.baseframe$mpe.registers $group
	}

	set g_regFirstTime($mpe) 0

	option clear
}

