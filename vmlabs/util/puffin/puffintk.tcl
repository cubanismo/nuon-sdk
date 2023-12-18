##########################################################################
# Visual Tcl v1.11 Project
############################################################################

# $Id: puffintk.tcl,v 1.3 2000/12/19 00:49:59 lreeber Exp $

# get rid of F10 MS Windows menu thing..
bind all <Key-F10> { }
bind all <KeyRelease-F10> { }


#toplevel .mdi
#frame .mdi.frame -width 800 -height 600
#pack .mdi.frame -expand yes -fill both


# TODO: 
#	- When run or one of the step buttons is clicked, make sure we 
#	  are in the correct file!!!
#

###   ###   ###   ###   ###   ###   ###
#  G L O B A L    V A R I A B L E S
#
global startPath
global searchPaths
global searchRecursive
global useBiosLoader

global widget; 
global workspaceFile
global g_grabOffset

# Number of MPE
global g_nMPEs
set    g_nMPEs	4


#
set g_bDisassembly(0) 0
set g_bDisassembly(1) 0
set g_bDisassembly(2) 0
set g_bDisassembly(3) 0
#
global g_nShowRegisters
set    g_nShowRegisters(0)   "Show Registers"
set    g_nShowRegisters(1)   "Show Registers"
set    g_nShowRegisters(2)   "Show Registers"
set    g_nShowRegisters(3)   "Show Registers"

global g_nIgnoreDA
set g_nIgnoreDA(0) 0
set g_nIgnoreDA(1) 0
set g_nIgnoreDA(2) 0
set g_nIgnoreDA(3) 0

global g_nShowLocalAddresses
set g_nShowLocalAddresses(0) 0
set g_nShowLocalAddresses(0) 1
set g_nShowLocalAddresses(0) 2
set g_nShowLocalAddresses(0) 3


global g_varString
set    g_varString ""
global g_varStringCopy
set    g_varStringCopy ""

global g_historyIndex
set    g_historyIndex 1
global g_historyPath
global g_historyType


global g_historyDebugIndex
set    g_historyDebugIndex 1
global g_historyDebugPath

global g_fnameList

global g_strLastFileSelDir

if {$tcl_platform(platform) == "unix"} {
        set g_strLastFileSelDir ""
} else {
        set g_strLastFileSelDir "./"
# xyz
}

set g_browserArrayIndex(0) 0
set g_browserArrayIndex(1) 0
set g_browserArrayIndex(2) 0
set g_browserArrayIndex(3) 0
set g_CMode(0) 0
set g_DisMode(0) 0
set g_CMode(1) 0
set g_DisMode(1) 0
set g_CMode(2) 0
set g_DisMode(2) 0
set g_CMode(3) 0
set g_DisMode(3) 0
set g_browserNeedsUpdate(0) 0
set g_browserNeedsUpdate(1) 0
set g_browserNeedsUpdate(2) 0
set g_browserNeedsUpdate(3) 0


global g_nDisassemblyFileIndex
set g_nDisassemblyFileIndex(0) -1
set g_nDisassemblyFileIndex(1) -1
set g_nDisassemblyFileIndex(2) -1
set g_nDisassemblyFileIndex(3) -1

global g_statusText


set g_statusText(0) "MPE 0 State: Stopped"
set g_statusText(1) "MPE 1 State: Stopped"
set g_statusText(2) "MPE 2 State: Stopped"
set g_statusText(3) "MPE 3 State: Stopped"

global g_textString
global g_startTextSel
global g_countTextSel
global g_MatchCase
global g_Direction
set g_textString(0) ""
set g_textString(1) ""
set g_textString(2) ""
set g_textString(3) ""
set g_startTextSel(0) "1.0"
set g_startTextSel(1) "1.0"
set g_startTextSel(2) "1.0"
set g_startTextSel(3) "1.0"
set g_countTextSel(0) 0
set g_countTextSel(1) 0
set g_countTextSel(2) 0
set g_countTextSel(3) 0
set g_MatchCase(0) 0
set g_MatchCase(1) 0
set g_MatchCase(2) 0
set g_MatchCase(3) 0
set g_Direction(0) "forward"
set g_Direction(1) "forward"
set g_Direction(2) "forward"
set g_Direction(3) "forward"



global g_bGlobalBrowser
set g_bGlobalBrowser 0
global g_globalBrowserId
set g_globalBrowserId(0) "globalBrowser0"
set g_globalBrowserId(3) "globalBrowser3"
global g_globalBrowserVars0
global g_globalBrowserVars3
	
set g_nStackFrame(0) 1
set g_nStackFrame(1) 1
set g_nStackFrame(2) 1
set g_nStackFrame(3) 1

global g_StackShownOnce
set g_StackShownOnce(0) 0
set g_StackShownOnce(1) 0
set g_StackShownOnce(2) 0
set g_StackShownOnce(3) 0

global g_globalBrowserGeom
set g_globalBrowserGeom "400x320+40+40"
###   ###   ###   ###   ###   ###   ###
#
#	The MPE Info
#	Members:
#		+strProjectPath
#		+strPathName
#		+bLoaded
#		+bOpen
#		+nLastFileIndex
#		+$Fname+bLoaded
#		+nListIndexToFileIndex+$i
#		+nFileIndexTolistIndex+$i
global g_cMpeInfo

# ... set some defaults...

set workspaceFile "$env(HOME)/.puffin2k.dfl"

set i 0
while {$i < $g_nMPEs } {
	set g_cMpeInfo($i+nLastFileIndex) -1
	set g_cMpeInfo($i+bLoaded) 0
	set g_cMpeInfo($i+bOpen) 0
	set g_cMpeInfo($i+strProjectPatch) "./"
# xyz
	incr i
}

global registerFont
global sourceFont
global listenerFont
global g_browserFont

global g_backgroundColor
global g_foregroundColor
global g_greyColor
global g_changedColor
global g_popupColor

switch $tcl_platform(platform) {
	unix {
		set g_browserFont "Courier 10"
		set registerFont "Courier 10"
		set sourceFont "Courier 11"
		set listenerFont "Courier 12"

		set g_backgroundColor white
		set g_foregroundColor black
		set g_changedColor blue
		set g_popupColor lightyellow
		set g_greyColor #f0f0e0
	}

	windows {
		set g_browserFont "Courier 10"
		set registerFont "Courier 8"
		set sourceFont "Courier 9"
		set listenerFont "Courier 10"

		set g_backgroundColor systemWindow
		set g_foregroundColor systemWindowText
		set g_changedColor blue
		set g_popupColor systemInfoBackground
		set g_greyColor systemButtonFace
	}

	macintosh {
		set g_browserFont "Courier 10"
		set registerFont "Courier 8"
		set sourceFont "Courier 9"
		set listenerFont "Courier 10"

		set g_backgroundColor systemWindowBody
		set g_foregroundColor systemButtonText
		set g_changedColor systemCaptionText
		set g_popupColor systemButtonFace
		set g_greyColor systemMenu
	}

}

#######################################################################
# USER DEFINED PROCEDURES
#
proc setBiosLoaderVar {} {
	global useBiosLoader

	if {[xlisp "eval" "*use-bios-loader?*"] == "#t"} {
		set useBiosLoader 1
	} else {
		set useBiosLoader 0
	}
}

proc init {argc argv} {
	global startPath
	global searchPaths
	global searchRecursive
	global useBiosLoader

	set useBiosLoader 0
	set searchRecursive 0
	set searchPaths ""
	set startPath [pwd]
	source_env "images.tcl"
}
init $argc $argv

###   ###   ###   ###   ###   ###   ###
#	:main

proc {main} {argc argv} {
# Stinky trick to get a XLISP variable which is not yet initialized! But it works ... ;-)
	after 100 setBiosLoaderVar
}

proc FindFile { startDir namePat rek} {
   set pwd [pwd]
#   puts "$startDir $namePat"
   if [catch {cd $startDir} err] {
	   tk_messageBox -type ok -default ok -message "Bad source path $startDir $err" -icon error
	   return $err
   }
#   foreach match [glob -nocomplain -- $namePat] {
#	   puts "MATCH"
#	   return [file join $startDir $match]
#   }
   
   if {[file exists [file join $startDir $namePat]]} {
	   return [file join $startDir $namePat]
   }   
   
   if {$rek == 1} {
	   foreach file [glob -nocomplain *] {
		   if [file isdirectory $file] {
			   set path [FindFile [file join $startDir $file] $namePat $rek]
			   if {$path != ""} {
				   return $path
			   }
		   }
	   }
   }
   cd $pwd
   return ""   
}

###   ###   ###   ###   ###   ###   ###
#	:mpeRefresh
#	CallBack()
#	called after a Load!!!

proc mpeRefresh { mpe file } {
	global g_cMpeInfo
	global env
	global g_fnameList
	global startPath
	global searchPaths
	global searchRecursive

	set base [mpeToWindow $mpe]
	if {$g_cMpeInfo($mpe+bOpen) == 0} {
		if [winfo exists $base] {
			wm deiconify $base
		}
	}
	if [winfo exists $base] {
		raise $base
	}


	xlisp gg-enable-disassembly $mpe "#f"

	set g_cMpeInfo($mpe+strProjectPath) [file dirname $file]

	set x $g_cMpeInfo($mpe+strProjectPath)
#	if {$x != "."} {
#		cd $x
#	}

	set fname [file tail $file]
	set title "#$mpe - MPE Debugger - $fname"
	if [winfo exists $base] {
		wm title $base $title
	}

	set objfile $g_cMpeInfo($mpe+strProjectPath)
	set file [string trim  $objfile \"]
		
	if [winfo exists $base] {
		$base.regFrame.fileList delete 0 end
	}
	set n 0
	set i 0

#	if {[info exists env(VMDB_SOURCE_PATH)]} {
#		set pathList [split $env(VMDB_SOURCE_PATH) ,]
#		lappend pathList $startPath
#	} else {
#		set pathList $startPath
#	}

	set pathList $searchPaths
	lappend pathList $startPath

# tk_messageBox -message "$pathList"

	puts "Searching source files in $pathList ...\n"
	while { [set fname [xlisp gg-get-file-reference $n $mpe]] != "()" } {
#	   puts "Searching: $fname"
		set g_statusText($mpe)  "Searching: $fname"
		showBusy $mpe
		
# tk_messageBox -message "mpe=$mpe fname=$fname"
		if {$fname != ""} {
			set j 0
			set bFound 0
			while {$j < $i}  {
				set m $g_cMpeInfo($mpe+nListIndexToFileIndex+$j)
				set fnameX $g_cMpeInfo($mpe+file$m+strPathName)
# commented out next line on 3/1/99 by hmk - Tricia had a problem that the same ".i" file
# showed up multiple times...
#				set fnameX [file tail $fnameX]
				if {$fnameX == $fname} {
					set bFound 1 
					break
				}
				incr j
			}
			if {$bFound == 0} {
				if {[string index $fname 0] == "*"} {
					set bStar 1
					set x [string last "*" $fname]
					incr x 
					set starName $fname
					set moduleName [string toupper [string range $fname 1 [expr $x-2]]]
					set fname [string range $fname $x end]		
				} else {
					set bStar 0
				}
# tk_messageBox -message "mpe=$mpe fname=$fname"
					set name [file tail $fname]
					set bLFound 0
					foreach pth $pathList {
						if {[file pathtype $fname] != "relative"} {
							if {[file exists $fname]} {
								set fname2 $fname
							} else {
								set fname2 ""
							}
						} else {
							set fname2 [FindFile $pth $name $searchRecursive]
						}
						if {$fname2 != ""} {
#							puts "$fname2"
							set g_cMpeInfo($mpe+file$n+strPathName) $fname2

							set fname [string trim $fname2 \"]
							set fname [file tail $fname]
							if {$bStar == 1} {
								set fname "$fname ($moduleName)"
							}

							lappend fnameList $fname					
#							puts "$fname"
#							$base.regFrame.fileList insert end $fname
							set g_cMpeInfo($mpe+$fname+bLoaded) 0
							set g_cMpeInfo($mpe+nLastFileIndex) -1
							set g_cMpeInfo($mpe+nListIndexToFileIndex+$i) $n
							set g_cMpeInfo($mpe+nFileIndexToListIndex+$n) $i
							set fileInfoListIndex($fname) $n
							incr i
							set bLFound 1
							break
						}
					}
					if {$bLFound == 0} {
#					    puts "NOT FOUND: $fname "
						xlisp gg-clear-file-reference! $n $mpe
					}
			}
		}
		incr n
	}
#	if {$g_cMpeInfo($mpe+strProjectPath) != "."} {
#		cd ".."
#	}
	set g_cMpeInfo($mpe+bLoaded) 1
	if {[info exists fnameList]} {
		set fnameList [lsort -dictionary -increasing $fnameList]
		set g_fnameList($mpe) $fnameList
		set i 0
		foreach fname $fnameList {
			if [winfo exists $base] {
				$base.regFrame.fileList insert end $fname
			}
			set n $fileInfoListIndex($fname) 
			set g_cMpeInfo($mpe+nListIndexToFileIndex+$i) $n
			set g_cMpeInfo($mpe+nFileIndexToListIndex+$n) $i
			incr i
		}
	}
	hideBusy $mpe
}

proc loadHistory { mpe filename type } {
global g_statusText

	set base [mpeToWindow $mpe]
	rmAllWatchEntries 0		
	removeAllBreakpoints $base $mpe 0

	set dir [file dirname $filename]
	set g_strLastFileSelDir $dir
	cd $dir	
	set oldStatus $g_statusText($mpe)
	set g_statusText($mpe) "Loading...                   "
	showBusy $mpe
	if {$type == "coff"} {
		set x [xlisp gg-load-coff-file "\"$filename\"" $mpe]
	} else {
		set x [xlisp gg-load-object-file "\"$filename\"" $mpe]
	}
	hideBusy $mpe
	set g_statusText($mpe) $oldStatus
	if {$x == "()"} {
		tk_messageBox -type ok -default ok -message "Failed to load MPO/COFF file!" -icon error
		set g_cMpeInfo($mpe+strProjectPath) 0
		set g_cMpeInfo($mpe+bLoaded) 0
		if [winfo exists $base] {
			wm title $base "MPE $mpe"
		}
	} 
}


proc loadDebugHistory { filename } {
global g_statusText

	rmAllWatchEntries 0
	set dir [file dirname $filename]
	cd $dir	  
	set i 0
	while {$i < 4} {
		set oldStatus($i) $g_statusText($i)
		set g_statusText($i) "Loading...                   "
		showBusy $i
		incr i
	}
	set x [xlisp load "\"$filename\""]
	set i 0
	while {$i < 4} {
		set g_statusText($i) $oldStatus($i)
		hideBusy $i
		incr i
	}
	if {$x == "()"} {
		tk_messageBox -type ok -default ok -message "Failed to load Debug file!" -icon error
	} 
}


proc saveDebugHistory { file } {
	global g_historyDebugIndex
	global g_historyDebugPath

	set base .mmp
	if {$g_historyDebugIndex > 4} {
		foreach base {.mmp} {
			$base.menuBar.menuFile delete 6
			$base.menuBar.menuFile delete 7
			$base.menuBar.menuFile delete 8
			$base.menuBar.menuFile delete 9

			set i 1
			set k $g_historyDebugIndex
			incr k -1
			while { $i < $k } {
				set g_historyDebugPath($i) $g_historyDebugPath([expr $i + 1])
				set flabel $g_historyDebugPath($i)
				set len [string length $flabel]


				if {$len > 18 } {
					set flabel [string range $flabel [expr $len - 18] $len]
				}
				set flabel "$i  ...$flabel"

				foreach b {.mmp} {		
					$b.menuBar.menuFile add command -label "$flabel" -command [list loadDebugHistory $g_historyDebugPath($i)]
				}
				incr i
			}
			set g_historyDebugIndex 4
		}
	}
	set i 1
	set bFound 0
	while { $i < $g_historyDebugIndex } {
		if { $g_historyDebugPath($i) == $file } {
			set bFound 1
		}
		incr i
	}
	if { $bFound == 1 } {
		return
	}

	set g_historyDebugPath($g_historyDebugIndex) $file				
	set flabel $file				
	set len [string length $flabel]
	if {$len > 18 } {
		set flabel [string range $flabel [expr $len - 18] $len]
	}
	set flabel "$g_historyDebugIndex  ...$flabel"
	if {$g_historyDebugIndex <= 4} {	
		incr g_historyDebugIndex
	}
	foreach b {.mmp} {		
		$b.menuBar.menuFile add command -underline 0 -label "$flabel" -command [list loadDebugHistory $file]
	}
}


proc saveHistory { base mpe file type } {
	global g_historyIndex
	global g_historyPath
	global g_historyType
	global g_cMpeInfo
	global g_strLastFileSelDir

	set n 0

	if {$g_historyIndex > 4} {
		foreach b {.mpe0+Top .mpe1+Top .mpe2+Top .mpe3+Top} {		
			if [winfo exists $b] {
				$b.menuBar.menuFile delete 7
				$b.menuBar.menuFile delete 8
				$b.menuBar.menuFile delete 9
				$b.menuBar.menuFile delete 10
			}
		}
		set i 1
		set k $g_historyIndex
		incr k -1
		while { $i < $k } {
			set g_historyPath($i) $g_historyPath([expr $i + 1])
			set g_historyType($i) $g_historyType([expr $i + 1])
			set flabel $g_historyPath($i)
			set len [string length $flabel]
			if {$len > 18 } {
				set flabel [string range $flabel [expr $len - 18] $len]
			}
			set flabel "$i  ...$flabel"
			set n 0
			foreach b {.mpe0+Top .mpe1+Top .mpe2+Top .mpe3+Top} {		
				if [winfo exists $b] {
					$b.menuBar.menuFile add command -label "$flabel" -command [list loadHistory $n $g_historyPath($i) $g_historyType($i)]
				}
				incr n
			}
			incr i
		}
		set g_historyIndex 4
	}
	set i 1
	set bFound 0
	while { $i < $g_historyIndex } {
		if { $g_historyPath($i) == $file } {
			set bFound 1
		}
		incr i
	}
	if { $bFound == 1 } {
		return
	}
	set g_historyPath($g_historyIndex) $file				
	set g_historyType($g_historyIndex) $type
	set flabel $file				
	set len [string length $flabel]
	if {$len > 18 } {
		set flabel [string range $flabel [expr $len - 18] $len]
	}
	set flabel "$g_historyIndex  ...$flabel"
	if {$g_historyIndex <= 4} {	
		incr g_historyIndex
	}
	set n 0
	foreach b {.mpe0+Top .mpe1+Top .mpe2+Top .mpe3+Top} {		
		if [winfo exists $b] {
			$b.menuBar.menuFile add command -underline 0 -label "$flabel" -command [list loadHistory $n $file $type]
		}
		incr n
	}
}


###   ###   ###   ###   ###   ###   ###
#	:loadSource
proc {loadSource} {base mpe} {
	global g_cMpeInfo
	global g_strLastFileSelDir
	global g_statusText

	set types {{{Assembly Sources} {.s} TEXT}
                   {{Assembly Sources} {.a} TEXT}}
	set mpofile [tk_getOpenFile -filetypes $types -initialdir $g_strLastFileSelDir]
	if {$mpofile != ""} {
		rmAllWatchEntries 0
		set g_strLastFileSelDir [file dirname $mpofile]
		cd $g_strLastFileSelDir
		set oldStatus $g_statusText($mpe)
		set g_statusText($mpe) "Loading...                   "
		showBusy $mpe
		set x [xlisp gg-load-source-file "\"$mpofile\"" $mpe]
		hideBusy $mpe
		set g_statusText($mpe) $oldStatus
		if {$x == "()"} {
			tk_messageBox -type ok -default ok -message "Failed to load source file!" -icon error
			set g_cMpeInfo($mpe+strProjectPath) 0
			set g_cMpeInfo($mpe+bLoaded) 0
			if [winfo exists $base] {
				wm title $base "MPE $mpe"
			}
		} else {
			saveHistory $base $mpe $mpofile mpo
		} 
	}
}


###   ###   ###   ###   ###   ###   ###
#	:setSearchPaths

proc exitPathsWindow { base } {
	global searchPaths

	set searchPaths [$base.fra19.pathlist get 0 end]
#	puts $searchPaths
	destroy $base
}

proc addPath { base } {
	global startPath

	set types {{{All Files} {*} ????}}
	set file [tk_getOpenFile -filetypes $types -initialdir $startPath -title "Select a file to add parent directory"]
	if {$file != ""} {
		$base.fra19.pathlist insert end [file dirname $file]
	}
}

proc delPath { base } {
	$base.fra19.pathlist delete [$base.fra19.pathlist curselection]
}

proc setSearchPaths { } {
    global searchRecursive
	global searchPaths
	
	set win .searchPathWind
    toplevel $win -class "SearchPath"

    wm resizable $win 0 0

    wm title $win "Define Search Paths"
    wm group $win .

    # please leave that here for the Find Box!!!
    wm geometry $win 400x400+491+231

    after idle [format {
        update idletasks
        wm minsize %s [winfo reqwidth %s] [winfo reqheight %s]
    } $win $win $win]

    set top $win
    set base $win
    bind $win <Return> [list $base.fra20.but26 invoke]

    ###################
    # CREATING WIDGETS
    ###################
    frame $base.fra18 \
        -borderwidth 2 -relief groove 
	checkbutton $base.fra18.che21 \
        -text {Search Recursive}  -variable searchRecursive
    frame $base.fra19 -borderwidth 2 -relief groove
    listbox $base.fra19.pathlist

    frame $base.fra20
    button $base.fra20.but26 \
        -text " Done " -command [list exitPathsWindow $base] -default active
    button $base.fra20.butAdd \
        -text " Add " -command [list addPath $base]
    button $base.fra20.butDel \
        -text " Delete " -command [list delPath $base]
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra18 -side top -fill x
    pack $base.fra18.che21 -side left
    pack $base.fra19 -side top -expand true -fill both
    pack $base.fra19.pathlist -expand true -fill both
	pack $base.fra20
	pack $base.fra20.but26 -side left
	pack $base.fra20.butAdd -side right
	pack $base.fra20.butDel -side right
	
	foreach p $searchPaths {
		$base.fra19.pathlist insert end $p
	}
	
#    focus $top.fra18.che21
    wm protocol $top WM_DELETE_WINDOW "$base.fra20.but26 invoke"

#    dialog_wait $top g_confirmStatus
#    destroy $top
		
}

###   ###   ###   ###   ###   ###   ###
#	:loadSymbols

proc {loadSymbols} {base mpe} {
	global g_strLastFileSelDir
	global g_cMpeInfo
	global g_statusText

	set types {{{COF Files} {.cof} COFF}}
	set cofffile [tk_getOpenFile -filetypes $types -initialdir $g_strLastFileSelDir]
	if {$cofffile != ""} {

		rmMPEWatchEntries $mpe
		set g_strLastFileSelDir [file dirname $cofffile]
		cd $g_strLastFileSelDir
		set oldStatus $g_statusText($mpe)
		set g_statusText($mpe) "Loading...                   "
		showBusy $mpe
		set x [xlisp gg-load-coff-symbols "\"$cofffile\"" $mpe]
		hideBusy $mpe
		set g_statusText($mpe) $oldStatus
		if {$x == "()"} {
			tk_messageBox -type ok -default ok -message "Failed to load symbols!" -icon error
			set g_cMpeInfo($mpe+strProjectPath) 0
			set g_cMpeInfo($mpe+bLoaded) 0
			if [winfo exists $base] {
				wm title $base "MPE $mpe"
			}
		} 
	}
}


###   ###   ###   ###   ###   ###   ###
#	:loadObject

proc {loadObject} {base mpe} {
	global g_strLastFileSelDir
	global g_cMpeInfo
	global g_statusText

	set types {{{Object Files} {.cof} COFF}
                   {{Object Files} {.mpo} MPOF}
                   {{COF Files} {.cof} COFF}
                   {{MPO Files} {.mpo} MPOF}}
	set cofffile [tk_getOpenFile -filetypes $types -initialdir $g_strLastFileSelDir]
	if {$cofffile != ""} {
		rmAllWatchEntries 0
		set g_strLastFileSelDir [file dirname $cofffile]
		cd $g_strLastFileSelDir
		set oldStatus $g_statusText($mpe)
		set g_statusText($mpe) "Loading...                   "
		showBusy $mpe
		set x [xlisp gg-load-object-file "\"$cofffile\"" $mpe]
		hideBusy $mpe
		set g_statusText($mpe) $oldStatus
		if {$x == "()"} {
			tk_messageBox -type ok -default ok -message "Failed to load object file!" -icon error
			set g_cMpeInfo($mpe+strProjectPath) 0
			set g_cMpeInfo($mpe+bLoaded) 0
			if [winfo exists $base] {
				wm title $base "MPE $mpe"
			}
		} else {
			saveHistory $base $mpe $cofffile coff
		}
	}
}

###   ###   ###   ###   ###   ###   ###
#	:reloadObject

proc {reloadObject} {base mpe} {
	global g_statusText

	set oldStatus $g_statusText($mpe)
	set g_statusText($mpe) "Reloading...                   "
	showBusy $mpe
	set x [xlisp gg-reload-object-file $mpe]
	hideBusy $mpe
	set g_statusText($mpe) $oldStatus
	if {$x == "()"} {
		tk_messageBox -type ok -default ok -message "Failed to reload object file!" -icon error
	}
}

###   ###   ###   ###   ###   ###   ###
#	:restartObject

proc {restartObject} {base mpe} {
	global g_statusText

	set oldStatus $g_statusText($mpe)
	set g_statusText($mpe) "Reloading...                   "
	showBusy $mpe
	xlisp gg-reset
	xlisp gg-stop 0
	xlisp gg-stop 1
	xlisp gg-stop 2
	xlisp gg-stop 3
	set x [xlisp gg-reload-object-file $mpe]
	hideBusy $mpe
	set g_statusText($mpe) $oldStatus
	if {$x == "()"} {
		tk_messageBox -type ok -default ok -message "Failed to reload object file!" -icon error
	}
}

###   ###   ###   ###   ###   ###   ###
#	:loadDebug

proc {loadDebug} {} {
	global g_cMpeInfo
	global g_statusText

	set types {{{Debug Files (Lisp)} {.dfl} DEBF} {{All Debug Files} {.dfl .d} DEBF}}
	set debugfile [tk_getOpenFile -filetypes $types]
	if {$debugfile != ""} {
		rmAllWatchEntries 0
		set g_strLastFileSelDir [file dirname $debugfile]
		cd $g_strLastFileSelDir
		set i 0
		while {$i < 4} {
			set oldStatus($i) $g_statusText($i)
			set g_statusText($i) "Loading...                   "
			showBusy $i
			incr i
		}
		set x [xlisp load "\"$debugfile\""]
		set i 0
		while {$i < 4} {
			hideBusy $i
			set g_statusText($i) $oldStatus($i)
			incr i
		}
		if {$x == "()"} {
			tk_messageBox -type ok -default ok -message "Failed to load Debug file!" -icon error
#			set g_cMpeInfo($mpe+strProjectPath) 0
#			set g_cMpeInfo($mpe+bLoaded) 0
		} else {
			saveDebugHistory $debugfile
		}
	}
}


proc exitPuffin {} {
	global g_nMPEs
	global regGState
	global g_historyPath
	global g_historyType
	global g_historyIndex
	global g_historyDebugPath
	global g_historyDebugIndex
	global .xLispTk
	global workspaceFile
	global tcl_platform
	global g_globalBrowserGeom

	set winList [list .mmp .watchTop .xLispTk ]
	for {set i 0} {$i < $g_nMPEs} {incr i} {
		lappend winList .mpe$i+Top
	}

	set fileId [open "$workspaceFile" w]
	
	foreach win $winList {
		if {![winfo exists $win] && $win != ".mmp"} {
			puts $fileId "(tcl \"destroy $win\")"
			continue
		}
		if {$win != ".mmp"} {
			puts $fileId "(tcl \"wm geometry $win [wm geometry $win]\")"
		} else {
			set g [wm geometry $win]
			regexp {([^\+]*)(\+.*)} $g match s p			
			puts $fileId "(tcl \"wm geometry $win $p\")"
		}
		set state [wm state $win]
		if {$state == "normal"} {
			puts $fileId "(tcl \"wm deiconify $win\")"
		} else {
			puts $fileId "(tcl \"wm iconify $win\")"
		}	
	}
	set i 1
	puts $fileId "(tcl \"set g_historyIndex $g_historyIndex\")"
	while {$i < $g_historyIndex} {
		puts $fileId "(tcl \"set g_historyPath($i) \\\"$g_historyPath($i)\\\"\")"
		puts $fileId "(tcl \"set g_historyType($i) \\\"$g_historyType($i)\\\"\")"
		incr i
	}	

	set i 1
	puts $fileId "(tcl \"set g_historyDebugIndex $g_historyDebugIndex\")"
	while {$i < $g_historyDebugIndex} {
		puts $fileId "(tcl \"set g_historyDebugPath($i) \\\"$g_historyDebugPath($i)\\\"\")"
		incr i
	}	
	if {[winfo exists .globalvars]} {
		set g_globalBrowserGeom [winfo geometry .globalvars]
	}
	puts $fileId "(tcl \"set g_globalBrowserGeom $g_globalBrowserGeom\")"

	set i 0
	while {$i < $g_nMPEs} {
		foreach group {General Bilinear MPE Interrupt DMA Commbus Special} {
			puts $fileId "(tcl \"set regGState($i$group) $regGState($i$group)\")"
		}
		incr i
	}


	close $fileId
	
	exit
}


###   ###   ###   ###   ###   ###   ###
#	:{Window}
#
proc {Window} {args} {
global vTcl
    set cmd [lindex $args 0]
    set name [lindex $args 1]
    set newname [lindex $args 2]
    set rest [lrange $args 3 end]
    if {$name == "" || $cmd == ""} {return}
    if {$newname == ""} {
        set newname $name
    }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists == "1" && $name != "."} {wm deiconify $name; return}
            if {[info procs vTclWindow(pre)$name] != ""} {
                eval "vTclWindow(pre)$name $newname $rest"
            }
            if {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[info procs vTclWindow(post)$name] != ""} {
                eval "vTclWindow(post)$name $newname $rest"
            }
        }
        hide    { if $exists {wm withdraw $newname; return} }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}


#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $base passive
    wm geometry $base 200x200+0+0
#    wm maxsize $base 1156 849
    wm minsize $base 104 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "vt"
    ###################
    # SETTING GEOMETRY
    ###################
}

#### ### ### ### ### ### ### ###
# 	Balloon Help 
#
toplevel .balloonHelp
label .balloonHelp.text -text " " -background lightyellow -border 1
pack .balloonHelp.text
wm withdraw .balloonHelp
wm transient .balloonHelp
wm overrideredirect .balloonHelp 1
global balloonHelpId

proc balloonHelpShow { } {
	global .balloonHelp

	wm deiconify .balloonHelp 
	raise .balloonHelp 

}
proc balloonHelpEvent {parent msg} {
	global .balloonHelp
	global balloonHelpId

	.balloonHelp.text configure -text $msg
	set x [winfo rootx $parent]
	set y [winfo rooty $parent]
	incr x 6
	incr y -14
	wm geometry .balloonHelp +$x+$y
	set balloonHelpId [after 500 balloonHelpShow]
}
proc balloonHelpCancel { } {
	global balloonHelpId

	after cancel $balloonHelpId
	wm withdraw .balloonHelp
}


proc puffinInfo { } {
global g_puffinInfo1
global g_puffinInfo2

	if {[winfo exists .info]} {
		return 
	}

	image create photo infoimage1 -data $g_puffinInfo1
	image create photo infoimage2 -data $g_puffinInfo2
    
	toplevel .info
	checkbutton .info.image -borderwidth 0 -indicatoron 0 -image infoimage1 -selectimage infoimage2 
	pack .info.image
}


proc IconifyAll {base} {
global g_iconifyList
        if {$base == ".mmp"} {
		set g_iconifyList ""
		set winlist [winfo children .]
		puts "Winlist $winlist"
		foreach win $winlist {
			if {[winfo ismapped $win]} {
				wm iconify $win
				lappend g_iconifyList $win
			}	
		}
	}

}

proc DeiconifyAll {base} {
global g_iconifyList

        if {$base == ".mmp"} {
		foreach win $g_iconifyList {
			wm deiconify $win
		}
	}
}

proc BiosLoader { s } {
	if {$s} {
		xlisp "set!" "*use-bios-loader?*" "#t"
	} else {
		xlisp "set!" "*use-bios-loader?*" "#f"
	}
}

###   ###   ###   ###   ###   ###   ###
#	:vTclWindow.mmpWindow
#

proc vTclWindow.mmpWindow {base title x y} {
    global g_iconRun
    global g_iconStep
    global g_iconStepin
    global g_iconStepout
    global g_iconStop
    global g_iconifyList
	global useBiosLoader

	
    set g_iconifyList ""

    if {$base == ""} {
        set base .mmpTop
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -menu $base.menuBar
    wm focusmodel $base passive
    wm geometry $base 550x80+$x+$y
    wm maxsize $base 550 80
    wm minsize $base 550 80
    wm overrideredirect $base 0
    wm resizable $base 1 1 
    wm deiconify $base
    wm title $base $title
#    wm transient $base .mpe0+Top

    bind $base <Destroy> {
        if {"%W" == ".mmp"} {
		exitPuffin
	}
    }

    # Keyboard acceleratos
    bind $base <Control-Key-F5> {xlisp gg-run-all}
    bind $base <Shift-Control-Key-F5> {xlisp gg-stop-all}
    bind $base <Control-Key-q> {destroy .mmp}
    bind $base <Unmap> {IconifyAll %W}
    bind $base <Map> {DeiconifyAll %W}

    #
    # Menu Bar Stuff
    #
    menu $base.menuBar \
        -cursor {} -tearoff 0 
    $base.menuBar add cascade -label File -underline 0 -menu $base.menuBar.menuFile 
    menu $base.menuBar.menuFile -tearoff 0


    $base.menuBar.menuFile add command -command {loadDebug} -label {Load Debug File...} 
    $base.menuBar.menuFile add separator
    $base.menuBar.menuFile add command -command [list setSearchPaths] -label {Define Search Paths...} 
    $base.menuBar.menuFile add check -variable useBiosLoader -command {BiosLoader $useBiosLoader} -label {Use BIOS Loader} 
#    $base.menuBar.menuFile add command -command [list restart 0] -label {Restart!} 
#    $base.menuBar.menuFile add separator
    $base.menuBar.menuFile add command -command {destroy .mmp} -label {Exit}  -accelerator Ctrl-Q
    $base.menuBar.menuFile add separator

    $base.menuBar add cascade -label Help -underline 0 -menu $base.menuBar.menuHelp
    menu $base.menuBar.menuHelp -tearoff 0
#    $base.menuBar.menuHelp add command -command \
#	{ tk_messageBox -type ok -message "Puffin 2K\nCopyright 1998 VM Labs, Inc."}\
#	 -label {About Puffin2K...}  
    $base.menuBar.menuHelp add command -command puffinInfo -label {About Puffin2K...}
 
    #
    # Command buttons (left to source code)
    #
    frame $base.commandFrame \
        -borderwidth 2 -height 40 -relief groove -width 160

    image create photo runimage -data $g_iconRun
    image create photo stopimage -data $g_iconStop    

    button $base.commandFrame.runButton \
        -text Run -image runimage -command {xlisp gg-run-all}
    button $base.commandFrame.stopButton \
        -text Stop -image stopimage -command {xlisp gg-stop-all}

    label $base.commandFrame.dummyLabel -text "  "

    button $base.commandFrame.mpe0Button \
        -text "MPE 0" -command { activateMPE 0 }
    button $base.commandFrame.mpe1Button \
        -text "MPE 1" -command { activateMPE 1 }
    button $base.commandFrame.mpe2Button \
        -text "MPE 2" -command { activateMPE 2 }
    button $base.commandFrame.mpe3Button \
        -text "MPE 3" -command { activateMPE 3 }

    button $base.commandFrame.watchButton \
        -text "Watch" -command  {activateWatch }
#  wm deiconify .watchTop; raise .watchTop 

    button $base.commandFrame.globalButton \
        -text "Global C" -command  {activateGlobal }


    button $base.commandFrame.resetButton \
        -text "Reset" -command { reset }

    set balloonHelpText($base.commandFrame.runButton)      "Run All"
    set balloonHelpText($base.commandFrame.stopButton)     "Stop All"
    set	balloonHelpText($base.commandFrame.mpe0Button)	   "Open MPE 0 Window"
    set	balloonHelpText($base.commandFrame.mpe1Button)	   "Open MPE 1 Window"
    set	balloonHelpText($base.commandFrame.mpe2Button)	   "Open MPE 2 Window"
    set	balloonHelpText($base.commandFrame.mpe3Button)	   "Open MPE 3 Window"
    set	balloonHelpText($base.commandFrame.watchButton)	   "Open Watch Window"
    set balloonHelpText($base.commandFrame.resetButton)    "Reset Merlin Media Processor"
    foreach b [list $base.commandFrame.runButton\
	       $base.commandFrame.stopButton\
	       $base.commandFrame.mpe0Button\
	       $base.commandFrame.mpe1Button\
	       $base.commandFrame.mpe2Button\
	       $base.commandFrame.mpe3Button\
	       $base.commandFrame.watchButton\
	       $base.commandFrame.resetButton] {
	bind $b <Enter> [ list balloonHelpEvent $b $balloonHelpText($b)]
	bind $b <Leave> { balloonHelpCancel }
	bind $b <1> { balloonHelpCancel }
    }

    #
    # Set geometry
    #                
    pack $base.commandFrame \
         -anchor center -expand 0 -fill both -side top 
    pack $base.commandFrame.runButton \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left
    pack $base.commandFrame.stopButton \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left         

    pack $base.commandFrame.dummyLabel \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left         

    pack $base.commandFrame.mpe0Button \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left         
    pack $base.commandFrame.mpe1Button \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left             
    pack $base.commandFrame.mpe2Button \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left 
    pack $base.commandFrame.mpe3Button \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left         
    pack $base.commandFrame.watchButton \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left         
    pack $base.commandFrame.globalButton \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side left         

    pack $base.commandFrame.resetButton \
        -in $base.commandFrame -anchor center -expand 0 -fill none -side right         


#frame .mmp.mdi -width 800 -height 600
#pack .mmp.mdi -expand yes -fill both -after .mmp.commandFrame
}



###   ###   ###   ###   ###   ###   ###
#	:vTclWindow.watchWindow
#
proc vTclWindow.watchWindow {base title x y} {

    if {$base == ""} {
        set base .watchTop
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel 
    wm focusmodel $base passive
    wm geometry $base 640x100+$x+$y
#    wm maxsize $base 1156 830
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base $title

    wm protocol $base WM_DELETE_WINDOW "watchWindowDelete $base"

    CreateWatchWidget $base

    # Fill it with life..
#    updateWatchWindow
}


#bind Menubutton <KeyPress-F10> { }

###   ###   ###   ###   ###   ###   ###
#	:vTclWindow.mpeWindow
#
proc vTclWindow.mpeWindow {base title mpe x y} {
    global g_foregroundColor
    global g_backgroundColor
    global g_iconRun
    global g_iconStep
    global g_iconStepin
    global g_iconStepout
    global g_iconStop
    global sourceFont
    global g_statusText    
    global g_nIgnoreDA
    global g_nShowRegisters
    global g_nShowLocalAddresses

    if {$base == ""} {
        set base .mpeTop
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -menu $base.menuBar
    wm focusmodel $base passive
    wm geometry $base 760x554+$x+$y
#    wm maxsize $base 1156 830
    wm minsize $base 760 400
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base $title
#    wm protocol $base WM_DELETE_WINDOW "wm iconify $base"
    wm protocol $base WM_DELETE_WINDOW "mpeWindowDelete $mpe $base"

#    wm transient $base .mmp

    #
    # Keyboard accelerators
    #
    bind $base <Control-Key-F5> {xlisp gg-run-all}
    bind $base <Shift-Control-Key-F5> {xlisp gg-stop-all}
    bind $base <Key-F5> [list mpeRun $base $mpe]
    bind $base <Shift-Key-F5> [list mpeStop $base $mpe]
    bind $base <Key-F10> [list mpeStepIn $base $mpe]
    bind $base <Key-F11> [list mpeStepOver $base $mpe]

    bind $base <Control-Key-d> [list $base.menuBar.menuEdit invoke 0]
    bind $base <Control-Key-b> [list $base.menuBar.menuEdit invoke 2]
    bind $base <Control-Key-w> [list $base.menuBar.menuWatch invoke 0]
    bind $base <Control-Key-o> [list $base.menuBar.menuFile invoke 0]
    bind $base <Escape> [list $base.menuBar.menuFile invoke 8]
    bind $base <Control-Key-q> {destroy .mmp}

    bind $base <Control-Key-f> [list $base.menuBar.menuFind invoke 0]
    bind $base <Key-F3> [list $base.menuBar.menuFind invoke 1]
    bind $base <Control-Key-g> [list $base.menuBar.menuFind invoke 1]

    #
    # Menu Bar Stuff
    #
    menu $base.menuBar \
        -cursor {} -tearoff 0 
    $base.menuBar add cascade -label File -underline 0 -menu $base.menuBar.menuFile 
    $base.menuBar add cascade -label Debug -underline 0 -menu $base.menuBar.menuEdit
    $base.menuBar add cascade -label Font -underline 0 -menu $base.menuBar.menuFont
    $base.menuBar add cascade -label Find -underline 1 -menu $base.menuBar.menuFind
    $base.menuBar add cascade -label View -underline 0 -menu $base.menuBar.menuView
    $base.menuBar add cascade -label Watch -underline 0 -menu $base.menuBar.menuWatch 
    menu $base.menuBar.menuFile -tearoff 0
    $base.menuBar.menuFile add command -command [list loadObject $base $mpe] -label {Load Object File...} -accelerator Ctrl-O
    $base.menuBar.menuFile add command -command [list loadSource $base $mpe] -label {Load Source File...} 
    $base.menuBar.menuFile add separator
    $base.menuBar.menuFile add command -command [list loadSymbols $base $mpe] -label {Load Symbols..} 
    $base.menuBar.menuFile add separator
    $base.menuBar.menuFile add command -command [list reloadObject $base $mpe] -label {Reload Object File} 
    $base.menuBar.menuFile add command -command [list restartObject $base $mpe] -label {Reset and Reload Object File} 
    $base.menuBar.menuFile add separator
    $base.menuBar.menuFile add command -command [list refresh $mpe] -label {Refresh} -accelerator Esc
    $base.menuBar.menuFile add separator
 
    menu $base.menuBar.menuEdit -tearoff 0 
    $base.menuBar.menuEdit add command -command [list mpeRun $base $mpe]\
	 -label Run -accelerator F5
    $base.menuBar.menuEdit add command -command [list mpeStop $base $mpe]\
	 -label Stop -accelerator Shift-F5
    $base.menuBar.menuEdit add command -command [list mpeStepIn $base $mpe]\
	 -label {Step in} -accelerator F10
    $base.menuBar.menuEdit add command -command [list mpeStepOver $base $mpe]\
	 -label {Step over} -accelerator F11
    $base.menuBar.menuEdit add separator

    menu $base.menuBar.menuFont -tearoff 0
    $base.menuBar.menuFont add command -command [list $base.sourceFrame.sourceText configure -font "Courier 9"]\
	 -label {Courier 9} 
    $base.menuBar.menuFont add command -command [list $base.sourceFrame.sourceText configure -font "Courier 10"]\
	 -label {Courier 10} 
    $base.menuBar.menuFont add command -command [list $base.sourceFrame.sourceText configure -font "Courier 12"]\
	 -label {Courier 12} 

    $base.menuBar.menuEdit add command -command [list disassembleAt $base $mpe]\
	 -label {Disassemble at...} -accelerator {Ctrl-D}
    $base.menuBar.menuEdit add separator
    $base.menuBar.menuEdit add command -command [list addBreakpoint $base $mpe]\
	 -label {Set/Clear breakpoint at...} -accelerator {Ctrl-B}
    $base.menuBar.menuEdit add command -command [list removeAllBreakpoints $base $mpe 1]\
	 -label {Remove all breakpoints} 
    $base.menuBar.menuEdit add command -command [list createBreakpointWindow $base "Breakpoints for MPE $mpe" $mpe 50 50]\
	 -label {Show breakpoints} 
    $base.menuBar.menuEdit add command -command [list setDABreakpoint $base $mpe]\
	 -label {Set DA Breakpoint} 
    $base.menuBar.menuEdit add check -variable g_nIgnoreDA($mpe) -command [list ignoreDABreakpoint $base $mpe]\
	 -label {Ignore DA Breakpoint} 


    menu $base.menuBar.menuFind -tearoff 0 
    $base.menuBar.menuFind add command -command [list findText $base $mpe]\
	 -label {Find...} -accelerator {Ctrl-F}
    $base.menuBar.menuFind add command -command [list findNext $base $mpe]\
	 -label {Find Next}  -accelerator {Ctrl-G}
    $base.menuBar.menuFind add command -command [list clearText $base $mpe]\
	 -label {Clear Highlight}
    $base.menuBar.menuFind add separator
    $base.menuBar.menuFind add command -command [list gotoLine $base $mpe]\
	 -label {Goto Line...}

    menu $base.menuBar.menuView -tearoff 0 
    $base.menuBar.menuView add radio -label {Show Registers} -variable g_nShowRegisters($mpe)\
		 -command [list toggleRegisterView $base $mpe]
    $base.menuBar.menuView add radio -label {Show Variables} -variable g_nShowRegisters($mpe)\
		 -command [list toggleRegisterView $base $mpe]

    $base.menuBar.menuView add separator
    $base.menuBar.menuView add command -label {Show Source} \
		 -command [list goBackToDisassembly $base $mpe] -state normal
    $base.menuBar.menuView add separator
    $base.menuBar.menuView add command -label {Show Current PC} \
		 -command [list goToCurrentPC $base $mpe] -state normal
#    $base.menuBar.menuView add separator
#   $base.menuBar.menuView add command -label {Show Stack Frame} \
#		 -command [list showStackFrame $base $mpe] -state disabled

    $base.menuBar.menuView add separator

    $base.menuBar.menuView add check -label {Show Local Addresses} -variable g_nShowLocalAddresses($mpe)\
		 -command [list showLocalAddress $base $mpe]


    menu $base.menuBar.menuWatch -tearoff 0 

    $base.menuBar.menuWatch add command -command [list addWatchEntry $base $mpe "" 0 0 0 0]\
	 -label {Add...}  -accelerator {Ctrl-W}
    $base.menuBar.menuWatch add command -command [list rmWatchEntry]\
	 -label {Remove selected} 
    if {$mpe == 0 || $mpe == 3} {
	    $base.menuBar.menuWatch add separator
	    $base.menuBar.menuWatch add command -command [list addGlobalCEntry $base $mpe]\
		 -label {Add Global C Variable...} 
    }

    #menu $base.menuBar.menuWatch
    #
    # File List & Register Frame
    #
    frame $base.regFrame \
        -borderwidth 2 -height 317 -relief groove -width 140 
    listbox $base.regFrame.fileList \
        -cursor fleur -yscrollcommand [list $base.regFrame.fileListScroll set]
    scrollbar $base.regFrame.fileListScroll \
        -orient vert -command [list $base.regFrame.fileList yview]
    bind $base.regFrame.fileList <ButtonRelease-1> \
	[list fileListEvent %W $mpe 0 0 0]
#    text $base.regFrame.regText \
#	-font {Courier 8} \
#       -height 22 -width 92 
    frame $base.regFrame.innerFrame 
    CreateRegisterWidget $base.regFrame.innerFrame $mpe

#    bind $base.regFrame.regText <ButtonRelease> [list dummyTextEvent $mpe]
#    $base.regFrame.regText configure -state disabled

    #
    # Source Code
    #
    frame $base.sourceFrame \
        -borderwidth 2 -height 75 -relief groove -width 125

    frame $base.sourceFrame.commandFrame \
        -borderwidth 2 -height 40 -border 0 -width 125

    #
    # Command buttons (left to source code)
    #
    image create photo runimage -data $g_iconRun
    image create photo stepimage -data $g_iconStep    
    image create photo stopimage -data $g_iconStop    
    image create photo stepinimage -data $g_iconStepin    
#    image create photo stepoutimage -data $g_iconStepout    

    button $base.sourceFrame.commandFrame.runButton \
        -text Run -image runimage \
	-command [list mpeRun $base $mpe]
    button $base.sourceFrame.commandFrame.stopButton \
        -text Stop -image stopimage \
	-command [list mpeStop $base $mpe]
    button $base.sourceFrame.commandFrame.stepInButton \
        -text "Step In" -image stepinimage \
	-command [list mpeStepIn $base $mpe]
#    button $base.sourceFrame.commandFrame.stepOutButton \
#        -text "Step Out" -image stepoutimage \
#	-command [list mpeStepOut $base $mpe]
    button $base.sourceFrame.commandFrame.stepOverButton \
        -text "Step Over" -image stepimage \
	-command [list mpeStepOver $base $mpe]


    set balloonHelpText($base.sourceFrame.commandFrame.runButton)      "Run (F5)"
    set balloonHelpText($base.sourceFrame.commandFrame.stopButton)     "Stop (Shift+F5)"
    set balloonHelpText($base.sourceFrame.commandFrame.stepInButton)   "Step In (F10)"
#    set balloonHelpText($base.sourceFrame.commandFrame.stepOutButton)  "Step Out (n/a)"
    set balloonHelpText($base.sourceFrame.commandFrame.stepOverButton) "Step Over (F11)"
    foreach b [list $base.sourceFrame.commandFrame.runButton\
	       $base.sourceFrame.commandFrame.stopButton\
	       $base.sourceFrame.commandFrame.stepInButton\
	       $base.sourceFrame.commandFrame.stepOverButton] {
	bind $b <Enter> [ list balloonHelpEvent $b $balloonHelpText($b)]
	bind $b <Leave> { balloonHelpCancel }
	bind $b <1> { balloonHelpCancel }
    }

    label $base.sourceFrame.commandFrame.statusLabel -textvariable g_statusText($mpe)


    # 
    # Grip for resizing panes...
    #
    frame $base.grip -width 10 -height 10 -borderwidth 2 -relief raised -cursor sb_v_double_arrow
    bind $base.grip <ButtonPress-1> "window_grab $base %Y" 	
    bind $base.grip <B1-Motion> "window_drag $base %Y" 
    bind $base.grip <ButtonRelease-1> "window_drop $base" 

    #
    # ... more source code...
    #           
    scrollbar $base.sourceFrame.sourceTextVScroll \
         -orient vert 
    scrollbar $base.sourceFrame.sourceTextHScroll \
        -orient horiz 
    text $base.sourceFrame.sourceText \
        -tabs {0.6c} -font $sourceFont -wrap none

     $base.sourceFrame.sourceText tag configure hilight -background $g_foregroundColor -foreground $g_backgroundColor
     $base.sourceFrame.sourceText tag configure tagBP -background white -foreground white
     $base.sourceFrame.sourceText tag bind tagBP <ButtonRelease-1> [list toggleBPEvent $base %W $mpe "@%x,%y"]

     $base.sourceFrame.sourceText tag bind tagBP <ButtonRelease-3> [list infoBPEvent $base %W $mpe "@%x,%y"]

     $base.sourceFrame.sourceText configure -cursor arrow
     $base.sourceFrame.sourceText configure -state disabled
     bind $base.sourceFrame.sourceText <ButtonRelease> [list dummyTextEvent $mpe]
     bind $base.sourceFrame.sourceText <Double-Button-1> [list sourceTextSelect $base %W $mpe "@%x,%y"]

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.regFrame \
        -anchor center -expand 0 -fill x -side top 
    pack propagate $base.regFrame 0

    pack $base.regFrame.fileList \
         -anchor center -expand 0 -fill y -side left 
    pack $base.regFrame.fileListScroll \
         -anchor center -expand 0 -fill y -side left 
    pack $base.regFrame.innerFrame \
         -anchor center -expand 1 -fill both -side top 

    pack $base.grip -side top -fill x


    pack $base.sourceFrame \
         -anchor center -expand 1 -fill both -side top

    pack $base.sourceFrame.commandFrame \
         -anchor center -expand 0 -fill both -side top 
    pack $base.sourceFrame.commandFrame.runButton \
         -anchor center -expand 0 -fill none -side left
    pack $base.sourceFrame.commandFrame.stopButton \
         -anchor center -expand 0 -fill none -side left         
    pack $base.sourceFrame.commandFrame.stepInButton \
         -anchor center -expand 0 -fill none -side left
#    pack $base.sourceFrame.commandFrame.stepOutButton \
#         -anchor center -expand 0 -fill none -side left
    pack $base.sourceFrame.commandFrame.stepOverButton \
         -anchor center -expand 0 -fill none -side left       
    pack $base.sourceFrame.commandFrame.statusLabel  -side right -anchor center
	#-relx 0.85 -rely 0.5 -anchor center

          
    pack $base.sourceFrame.sourceTextVScroll \
         -anchor center -expand 0 -fill y -side right 
    pack $base.sourceFrame.sourceTextHScroll \
        -anchor center -expand 0 -fill x -side bottom 
    pack $base.sourceFrame.sourceText \
         -anchor center -expand 1 -fill both -side top 
}

proc showLocalAddresses { base mpe } {
global g_browserNeedsUpdate
	varBrowseInternalClear $mpe root
	set g_browserNeedsUpdate($mpe) 1		
	toggleRegisterView $base $mpe
}
proc mpeWindowDelete { mpe base } {
global g_CMode
	if {$g_CMode($mpe) == 1} {
		varBrowseInternalClear $mpe root
	}
	destroy $base
}


proc watchWindowDelete { base } {
	rmAllWatchEntries 1
	destroy $base
}

proc activateGlobal {} {
global g_bGlobalBrowser

	update
	
	if {$g_bGlobalBrowser == 0} {
		createGlobalBrowserWindow .globalvars "Global C Variables" 0 40 120
		set g_bGlobalBrowser 1
	} else {
		wm deiconify  .globalvars
		raise .globalvars
	}
}


proc activateWatch {} {
    update

    if {[winfo exists .watchTop]} {
	wm deiconify  .watchTop
	raise .watchTop
    } else {
	vTclWindow.watchWindow .watchTop "Watch" 75 75
	recallWatchEntries	
	return

	set pos [expr 40 + 20 * $mpe]
	createMPEWindow .mpe$mpe+Top "#$mpe - MPE Debugger" $mpe $pos $pos
	set base .mpe$mpe+Top

	if {[info exists g_fnameList($mpe)]} {
		set i 0
		foreach fname $g_fnameList($mpe) {
			$base.regFrame.fileList insert end $fname
		}
	} else  {
		return
	}
	update
	set addr [xlisp gg-register "\"pcexec\"" $mpe]

	set x [xlisp gg-line-number $mpe $addr]
	set fileNo [lindex $x 0]
        set fileNo [string trim $fileNo (]

	if {$fileNo != ")" && $fileNo != "disassembly"} {
		set lineNo  [lindex $x 1]
 		set count   [lindex $x 2]
		set count   [string trim $count )]

		# force an update
		set fname [xlisp gg-get-file-reference $fileNo $mpe]
		set fname [string trim $fname \"]
		set fname [file tail $fname]

		set $g_cMpeInfo($mpe+nLastFileIndex) -1
		set g_cMpeInfo($mpe+$fname+bLoaded) 0		


		# we do a Redraw+ so that the stack frame appears
		updateSourceWindow $mpe $addr "Redraw++" $fileNo $lineNo $count
	
		set g_browserNeedsUpdate($mpe) 0
		varBrowseInternalClear $mpe root
		update
		set g_browserNeedsUpdate($mpe) 1
		set pc  [xlisp gg-browse-frame $mpe "\"root\"" 0]
		set g_browserNeedsUpdate($mpe) 1
		updateSourceWindow $mpe $pc "Redraw" $fileNo $lineNo $count
		set g_browserNeedsUpdate($mpe) 0
	} else {
		set g_bDisassembly($mpe) 1
		halt $mpe $addr "Redraw"
	}
    }
}

proc activateMPE { mpe } {
global g_fnameList
global g_cMpeInfo
global g_browserNeedsUpdate
    update

    if {[winfo exists .mpe$mpe+Top]} {
	wm deiconify  .mpe$mpe+Top
	raise .mpe$mpe+Top 
    } else {
	set pos [expr 40 + 20 * $mpe]
	createMPEWindow .mpe$mpe+Top "#$mpe - MPE Debugger" $mpe $pos $pos
	set base .mpe$mpe+Top

	if {[info exists g_fnameList($mpe)]} {
		set i 0
		foreach fname $g_fnameList($mpe) {
			$base.regFrame.fileList insert end $fname
		}
	} else  {
		return
	}
	update
	set addr [xlisp gg-register "\"pcexec\"" $mpe]

	set x [xlisp gg-line-number $mpe $addr]
	set fileNo [lindex $x 0]
        set fileNo [string trim $fileNo (]

	if {$fileNo != ")" && $fileNo != "disassembly"} {
		set lineNo  [lindex $x 1]
 		set count   [lindex $x 2]
		set count   [string trim $count )]

		# force an update
		set fname [xlisp gg-get-file-reference $fileNo $mpe]
		set fname [string trim $fname \"]
		set fname [file tail $fname]

		set $g_cMpeInfo($mpe+nLastFileIndex) -1
		set g_cMpeInfo($mpe+$fname+bLoaded) 0		


		# we do a Redraw+ so that the stack frame appears
		updateSourceWindow $mpe $addr "Redraw++" $fileNo $lineNo $count
	
		set g_browserNeedsUpdate($mpe) 0
		varBrowseInternalClear $mpe root
		update
		set g_browserNeedsUpdate($mpe) 1
		set pc  [xlisp gg-browse-frame $mpe "\"root\"" 0]
		set g_browserNeedsUpdate($mpe) 1
		updateSourceWindow $mpe $pc "Redraw" $fileNo $lineNo $count
		set g_browserNeedsUpdate($mpe) 0
	} else {
		set g_bDisassembly($mpe) 1
		halt $mpe $addr "Redraw"
	}
    }
}

###   ###   ###   ###   ###   ###   ### 

proc createBreakpointWindow {orgbase title mpe x y} {
global g_cMpeInfo
global g_bpListFileNo
global g_bpListLineNo
global sourceFont
    set base .listBreakpoints$mpe
 
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel 
    wm focusmodel $base passive
    wm geometry $base 450x320+$x+$y
    wm minsize $base 200 200
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base $title
    wm protocol $base WM_DELETE_WINDOW "deleteBreakpointWindow $base $mpe"

 
    label $base.label -font $sourceFont -text "Function                         File            Line   State" -justify left -anchor nw
    frame $base.frame -width 120 -height 160
    listbox $base.frame.bpList -font $sourceFont\
        -cursor fleur -yscrollcommand [list $base.frame.bpListScroll set]
    scrollbar $base.frame.bpListScroll \
        -orient vert -command [list $base.frame.bpList yview]
    bind $base.frame.bpList <ButtonRelease-1> \
	[list bpListEvent %W $orgbase $mpe]

    bind $base.frame.bpList <Shift-ButtonRelease-1> \
	[list bpListControlEvent %W $orgbase $mpe]
    bind $base.frame.bpList <ButtonRelease-3> \
	[list bpListControlEvent %W $orgbase $mpe]

    pack $base.label -expand 0 -fill x -side top
    pack $base.frame -anchor center -expand 1 -fill both -side top 
    pack $base.frame.bpList \
         -anchor center -expand 1 -fill both -side left 
    pack $base.frame.bpListScroll \
         -anchor center -expand 0 -fill y -side left 

    set n 0
    while { [set bp [xlisp gg-breakpoint $n $mpe]] != "()" } {
        # the address will be needed for calls to gg-break-settings and
        # gg-break-change!
        set addr [lindex $bp 0]
	set function  [lindex $bp 1]
	set l [string length $function]
	incr l -1
	set c [string index $function $l]
	if {$c == ")"} {
		set bNoFile 1
	} else {
		set bNoFile 0
	}
	set function [string trim $function (]
	set function [string trim $function )]

	set l [string length $function]
	while {$l < 32} {
		set function "$function "
		incr l
	}
	set function [string range $function 0 31]

	if {$bNoFile == 0} {
		set fileno  [lindex $bp 2]
		set lineno  [lindex $bp 3]
		set offset  [lindex $bp 4]
		set offset [string trim $offset )]
		set fname $g_cMpeInfo($mpe+file$fileno+strPathName) 
		set fname [string trim $fname \"]
		set fname [file tail $fname]

		set l [string length $fname]
		while {$l < 16} {
			set fname "$fname "
			incr l
		}
		set fname [string range $fname 0 15]

		set l [string length $lineno]
		while {$l < 5} {
			set lineno "$lineno "
			incr l
		}
		set linenno [string range $lineno 0 4]
	} else {
		set fname ""
		set lineno ""
	}

	set bpName "$function $fname $lineno 1"
	$base.frame.bpList insert end $bpName

	set g_bpListFileNo(mpe$mpe+$n) $fileno
	set g_bpListLineNo(mpe$mpe+$n) $lineno

	incr n
    }

}

proc bpListControlEvent {bpList orgbase mpe} {
global g_bpListFileNo
global g_bpListLineNo
global g_bDisassembly

	set n [$bpList curselection]

	if {$n == "" } {
		return
	}
	if {[info exists g_bpListFileNo(mpe$mpe+$n)]} {
		set fileNo $g_bpListFileNo(mpe$mpe+$n) 
		set lineNo $g_bpListLineNo(mpe$mpe+$n) 
	} else {
		return
	}
	set sel [$bpList get $n]

	$bpList delete $n

	set len [string length $sel]

	incr len -1
	set c [string range $sel $len $len]

	set m [expr $len - 2]
	set sel [string range $sel 0 $m]
	if {$c == "1"} {
		set sel "$sel 0"
	} else {
		set sel "$sel 1"
	}
	$bpList insert $n $sel

	xlisp gg-toggle-breakpoint-on-line! $fileNo $lineNo $mpe

	dummyTextEvent $mpe
#	if {$g_bDisassembly($mpe) == 0} {
#		xlisp gg-toggle-breakpoint-on-line! $fileNo $lineNo $mpe
#	} else {
#		xlisp gg-toggle-breakpoint-on-line! "\"disassembly\"" $lineNo $mpe
#	}
}

proc bpListEvent {bpList orgbase mpe} {
global g_bpListFileNo
global g_bpListLineNo

	set n [$bpList curselection]

	if {$n == "" } {
		return
	}
	if {[info exists g_bpListFileNo(mpe$mpe+$n)]} {
		set fileNo $g_bpListFileNo(mpe$mpe+$n) 
		set lineNo $g_bpListLineNo(mpe$mpe+$n) 
	} else {
		return
	}

	if {$fileNo == ""} {
		tk_messageBox -message "No source information available on this breakbpoint."
		return
	}
	if {$lineNo > 1} {
		incr lineNo -1
	}
	fileListEvent $orgbase.regFrame.fileList $mpe 2 $fileNo $lineNo
#	updateSourceWindow $mpe 0 "Redraw" $fileNo $lineNo 1
}


###   ###   ###   ###   ###   ###   ### 
proc deleteBreakpointWindow { base mpe } {

    destroy $base
}


###   ###   ###   ###   ###   ###   ### 
proc deleteGloablBrowserWindow { base mpe } {
global g_bGlobalBrowser

    destroy $base
    set g_bGlobalBrowser 0
}

#
# :createGlobalBrowserWindow

proc createGlobalBrowserWindow {base title mpe x y} {
global g_globalBrowserId
global g_bGlobalBrowser
global g_globalBrowserGeom
global g_globalBrowserVars0
global g_globalBrowserVars3

    if {$base == ""} {
        set base .globalvars
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -menu $base.menuBar
    wm focusmodel $base passive
    wm geometry $base $g_globalBrowserGeom
    wm minsize $base 200 200
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base $title
    wm protocol $base WM_DELETE_WINDOW "deleteGloablBrowserWindow $base $mpe"

    set g_bGlobalBrowser 1

    label $base.label0 -text "MPE 0:" -justify left -anchor nw
    frame $base.varFrame0 -width 120 -height 160

    set g_globalBrowserId(0) "globalBrowser0"
    set x [xlisp gg-make-browser $mpe "\"$g_globalBrowserId(0)\""]

    hierlist_create 0 $base.varFrame0.browser $g_globalBrowserId(0)

    # 
    # Grip for resizing panes...
    #
    frame $base.grip -width 10 -height 10 -borderwidth 2 -relief raised -cursor sb_v_double_arrow
    bind $base.grip <ButtonPress-1> "gvar_window_grab $base %Y" 	
    bind $base.grip <B1-Motion> "gvar_window_drag $base %Y" 
    bind $base.grip <ButtonRelease-1> "gvar_window_drop $base" 

    label $base.label3 -text "MPE 3:" -justify left -anchor nw
    frame $base.varFrame3 -width 120 -height 40

    set g_globalBrowserId(3) "globalBrowser3"
    set x [xlisp gg-make-browser $mpe "\"$g_globalBrowserId(3)\""]

    hierlist_create 3 $base.varFrame3.browser $g_globalBrowserId(3)

    pack $base.label0 -expand 0 -fill x -side top
    pack $base.varFrame0.browser -expand 1 -fill both -side top 
    pack propagate $base.varFrame0 0
    pack $base.varFrame0 -anchor center -expand 1 -fill x -side top 
    pack $base.grip -side top -fill x
    pack $base.label3 -expand 0 -fill x -side top 
    pack $base.varFrame3.browser -expand 1 -fill both -side top 
    pack $base.varFrame3 -anchor center -expand 1 -fill both -side top 

    foreach {key value} [array get g_globalBrowserVars0] {
	set varname "_$value"
	set x [xlisp gg-browse-add-symbol 0 "\"$g_globalBrowserId(0)\"" "\"$varname\""]
    }
    foreach {key value} [array get g_globalBrowserVars3] {
	set varname "_$value"
	set x [xlisp gg-browse-add-symbol 3 "\"$g_globalBrowserId(3)\"" "\"$varname\""]
    }

}

proc destroyGlobalBrowser {base} {
global g_bGlobalBrowser 
	set g_bGlobalBrowser 0
	destroy $base
}

###   ###   ###   ###   ###   ###   ### 
#	:toggleRegisterView
#
proc toggleRegisterView {base mpe} {

global g_nShowRegisters
global g_varStringCopy
global g_browserVarsName
global g_browserVarsParent
global g_browserVarsNode
global g_browserVarsValue
global g_browserVarsStruct
global g_cMpeInfo
global g_CMode
global g_DisMode	
global g_browserNeedsUpdate
	if {$g_nShowRegisters($mpe) == "Show Variables" } {
		destroy $base.regFrame.innerFrame

		frame $base.regFrame.innerFrame -bg white
		hierlist_create $mpe $base.regFrame.innerFrame.browser

		pack $base.regFrame.innerFrame.browser -expand 1 -fill both -side top 
		pack $base.regFrame.innerFrame \
			-anchor center -expand 1 -fill both -side top 

	        bind $base.regFrame.innerFrame <ButtonRelease> [list dummyTextEvent $mpe]

		varBrowse $mpe root
	} else {

		if {$g_CMode($mpe) == 1} {
			varBrowseInternalClear $mpe root
			set g_browserNeedsUpdate($mpe) 1		
		}

		destroy $base.regFrame.innerFrame
		frame $base.regFrame.innerFrame 
		CreateRegisterWidget $base.regFrame.innerFrame $mpe
		pack $base.regFrame.innerFrame \
			-anchor center -expand 1 -fill both -side top 
		UpdateRegisters $mpe	
	}
}

###   ###   ###   ###   ###   ###   ### 
#	:Grip Functions
#
proc window_grab {win y} {
	global g_grabOffset

	set g_grabOffset [expr $y-[winfo height $win.regFrame]] 
	$win.grip configure -relief sunken
}

proc window_drop {win} {
	$win.grip configure -relief raised
}

proc window_drag {win y} {
	global g_grabOffset
	$win.regFrame configure -height [expr $y-$g_grabOffset]
}



proc gvar_window_grab {win y} {
	global g_grabOffset

	set g_grabOffset [expr $y-[winfo height $win.varFrame0]] 
	$win.grip configure -relief sunken
}

proc gvar_window_drop {win} {
	$win.grip configure -relief raised
}

proc gvar_window_drag {win y} {
	global g_grabOffset
	$win.varFrame0 configure -height [expr $y-$g_grabOffset]
}

###   ###   ###   ###   ###   ###   ### 
#	:createMPEWindow
#
proc createMPEWindow { base title mpe x y } {
    	global g_cMpeInfo

	vTclWindow.mpeWindow $base $title $mpe $x $y

	$base.sourceFrame.sourceTextVScroll configure\
		 -command [list $base.sourceFrame.sourceText yview]
	$base.sourceFrame.sourceTextHScroll configure\
	        -command [list $base.sourceFrame.sourceText xview]
	$base.sourceFrame.sourceText configure\
		-xscrollcommand [list $base.sourceFrame.sourceTextHScroll set] \
	        -yscrollcommand [list $base.sourceFrame.sourceTextVScroll set]
	set g_cMpeInfo($mpe+bOpen) 1

#update
#setparent $base .mmp
}

###   ###   ###   ###   ###   ###   ### 
#	:refresh
#
proc refresh { mpe } {
	global g_bDisassembly

	set x [xlisp gg-refresh-registers $mpe]
	if {$g_bDisassembly($mpe) == 1} {
		updateSourceWindow $mpe 0 "Refresh" "disassembly" 0 0
	} else {
		updateSourceWindow $mpe 0 "Refresh" 0 0 0
	}
}

###   ###   ###   ###   ###   ###   ### 
#	:restart
#
proc restart {mpe} {
	global g_statusText
	global g_bGlobalBrowser
	global g_globalBrowserId
# old way:
if {0} {
	set g_statusText(0) "Please stand by, MPE 0 is restarting..."	
	set g_statusText(1) "Please stand by, MPE 1 is restarting..."	
	set g_statusText(2) "Please stand by, MPE 2 is restarting..."	
	set g_statusText(3) "Please stand by, MPE 3 is restarting..."	


	xlisp gg-restart

	set g_statusText(0) "MPE 0 State: Stopped"	
	set g_statusText(1) "MPE 1 State: Stopped"	
	set g_statusText(2) "MPE 2 State: Stopped"	
	set g_statusText(3) "MPE 3 State: Stopped"	

} else {
	set g_statusText($mpe) "Please stand by, MPEs are is restarting..."	
	update
	xlisp gg-restart

	if {$g_bGlobalBrowser == 1} {
		hierlist_delete_children $mpe .globalvars.varFrame0.browser $g_globalBrowserId(0)
		hierlist_delete_children $mpe .globalvars.varFrame3.browser $g_globalBrowserId(3)
	}

	set g_statusText($mpe) "MPE $mpe State: Stopped"
}
}

###   ###   ###   ###   ###   ###   ### 
#	:reset
#
proc reset {} {
	set choice "yes"
	
	set choice [tk_messageBox -type yesno -default no\
		-message "Do you really want to reset the MMP?"\
		-icon question]
	if { $choice == "yes" } {
		rmAllWatchEntries 0
		xlisp gg-reset
		clearMPEWindows
	}
}

proc mpeStartsRunning { mpe } {
global g_statusText
#	if {$mpe == 0} {
#		return
#	}
	set g_statusText($mpe) "MPE $mpe State: Running"
#	showBusy $mpe
}

###   ###   ###   ###   ###   ###   ### 
#	:mpeRun / Step / Stop commands
#


proc mpeRun { base mpe } {
global g_DisMode
global g_statusText

	set x [xlisp gg-running? $mpe]
	if {$x != "()"} {
		tk_messageBox -message "MPE is already running."
		return
	}
	# Note: do we need this here????
	xlisp gg-enable-disassembly $mpe "#f"
	set g_DisMode($mpe) 0
	set g_statusText($mpe) "MPE $mpe State: Running"
	showBusy $mpe
	xlisp gg-run $mpe
}
proc mpeStop { base mpe } {
global g_statusText
	set g_statusText($mpe) "MPE $mpe State: Stopped"
	hideBusy $mpe
	if [catch {xlisp gg-stop $mpe} result] {
		tk_messageBox -message "Merlin Exception: see Console window!"
	}

	refresh $mpe
}
proc mpeStepIn { base mpe } {
global g_statusText
	set x [xlisp gg-running? $mpe]
	if {$x != "()"} {
#		tk_messageBox -message "Can't step while MPE is running."
		return
	}
	showBusy $mpe
	set g_statusText($mpe) "MPE $mpe State: Running"
	$base.sourceFrame.commandFrame.statusLabel configure -text "MPE $mpe State: Running"
	xlisp gg-step $mpe
}
proc mpeStepOut { base mpe } {
global g_statusText
	showBusy $mpe
	set x [xlisp gg-running? $mpe]
	if {$x != "()"} {
#		tk_messageBox -message "Can't step while MPE is running."
		return
	}
	set g_statusText($mpe) "MPE $mpe State: Running"
	$base.sourceFrame.commandFrame.statusLabel configure -text "MPE $mpe State: Running"
	xlisp gg-step $mpe
}
proc mpeStepOver { base mpe } {
global g_statusText
	set x [xlisp gg-running? $mpe]
	if {$x != "()"} {
#		tk_messageBox -message "Can't step while MPE is running."
		return
	}
	showBusy $mpe
	set g_statusText($mpe) "MPE $mpe State: Running"
	xlisp gg-step-over $mpe
}

###   ###   ###   ###   ###   ###   ### 
#	:dummyTextEvent
#
proc dummyTextEvent { mpe } {
	global g_cMpeInfo

	set base [mpeToWindow $mpe]
	# TCL bug, we have to restore the fileList selection
	if { $g_cMpeInfo($mpe+nLastFileIndex) != -1 } {
		if {[info exists g_cMpeInfo($mpe+nFileIndexToListIndex+$g_cMpeInfo($mpe+nLastFileIndex))]} {
			set x $g_cMpeInfo($mpe+nFileIndexToListIndex+$g_cMpeInfo($mpe+nLastFileIndex))
			if [winfo exists $base.regFrame.fileList] {
				$base.regFrame.fileList selection set $x 
			}
		}
	}
}

###   ###   ###   ###   ###   ###   ### 
# :sourceTextSelect
#
proc sourceTextSelect { base sourceTextWidget mpe pos} {
	global g_cMpeInfo
	global g_bDisassembly
	global g_globalBrowserId
	global g_CMode
	global g_bGlobalBrowser
	global g_globalBrowserVars0
	global g_globalBrowserVars3
	if { $g_cMpeInfo($mpe+bLoaded) == 0 && $g_bDisassembly($mpe) == 0} {
		return
	}

	set index1 [$sourceTextWidget index "$pos wordstart"]
	set index2 [$sourceTextWidget index "$pos wordend"]
	set lineNo  [expr int($index1)]

	set x [winfo pointerx $base]
	set y [winfo pointery $base]
	set varname [$sourceTextWidget get $index1 $index2]

	#tk_messageBox -message "index1=$index1 index2=$index2 >$varname<"

	if {$varname == " " || $varname == "" || $varname == "\t" || $varname == "\n"} {
		return
	}
	set file $g_cMpeInfo($mpe+nLastFileIndex)
	if {[info exists g_cMpeInfo($mpe+file$file+strPathName)]} {
		set wholeFname "$g_cMpeInfo($mpe+file$file+strPathName)"
		set fname [file tail $wholeFname]
	} else {
		addWatchEntry $base $mpe $varname $x $y 0 0
		return
	}
	set xi  [string last "." $wholeFname]
	set ext [string range $wholeFname $xi end]
	if {$ext == ".c" || $ext == ".cpp" || $ext == ".cc"} {
		if {[info exists g_globalBrowserId]} {
			if {$g_bGlobalBrowser == 0} {
				createGlobalBrowserWindow .globalvars "Global C Variables" $mpe 40 120
				set g_bGlobalBrowser 1
			}
			set varname1 "_$varname"		
			set x [xlisp gg-browse-add-symbol $mpe "\"$g_globalBrowserId($mpe)\"" "\"$varname1\""]
			if {$x == "()"} {	
 				set listCKeywords [list "asm" "auto" "break" "case" "catch" "char" "class"\
					"const" "continue" "default" 'delete" "do" "double" "else"\
					"enum" "extern" "float" "for" "friend" "goto" "if" "inline"\
					"int" "long" "new" "operator" "private" "protected" "public"\
					"register" "return" "short" "signed" "sizeof" "static" "struct"\
					"switch" "template" "this" "throw" "try" "typedef" "union"\
					"unsigned" "virtual" "void" "volatile" "while"\
					"#ifdef" "#indef" "#if" "#else" "#endif" "#include"]

				set bFound 0
				foreach word $listCKeywords {
					if {$varname == $word} {
						set bFound 1
						break
					}
				}
				if {$bFound == 0} {
					tk_messageBox -message "$varname is not a global C variable."
				}
			} else {
#				if {$mpe == 0} {
#					set g_globalBrowserVars0($varname) $varname1
#				} else {
#					set g_globalBrowserVars3($varname) $varname1
#				}
			}
		}
	} else {
		addWatchEntry $base $mpe $varname $x $y 0 0
	}
	# TCL bug, we have to restore the fileList selection
	if { $g_cMpeInfo($mpe+nLastFileIndex) != -1 } {
		set x $g_cMpeInfo($mpe+nFileIndexToListIndex+$g_cMpeInfo($mpe+nLastFileIndex))
		if [winfo exists $base.regFrame.fileList] {
			$base.regFrame.fileList selection set $x 
		}
	}
}

###   ###   ###   ###   ###   ###   ### 
#	:toggleBPEvent
#
proc toggleBPEvent { base sourceTextWidget mpe pos} {
	global g_cMpeInfo
	global g_bDisassembly

	if { $g_cMpeInfo($mpe+bLoaded) == 0 && $g_bDisassembly($mpe) == 0} {
		return
	}

	set x [xlisp gg-running? $mpe]
	if {$x != "()"} {
		tk_messageBox -message "Can't set breakpoint while MPE is running."
		return
	}

	set index [$sourceTextWidget index "$pos linestart"]
	set lineNo  [expr int($index)]

	# Note: make sure g_cMpeInfo($mpe+nLastFileIndex) points 
	#       to the active source file!!
	if {$g_bDisassembly($mpe) == 0} {
		xlisp gg-toggle-breakpoint-on-line! $g_cMpeInfo($mpe+nLastFileIndex) $lineNo $mpe
	} else {
		xlisp gg-toggle-breakpoint-on-line! "\"disassembly\"" $lineNo $mpe
	}
	# TCL bug, we have to restore the fileList selection
	if { $g_cMpeInfo($mpe+nLastFileIndex) != -1 } {
		set x $g_cMpeInfo($mpe+nFileIndexToListIndex+$g_cMpeInfo($mpe+nLastFileIndex))
		if [winfo exists $base.regFrame.fileList] {
			$base.regFrame.fileList selection set $x 
		}
	}


}



# :infoBPEvent
proc infoBPEvent { base sourceTextWidget mpe pos} {
	global g_cMpeInfo
	global g_bDisassembly
global g_BPcondition
global g_BPcount
global g_BPbefore
global g_BPafter


	if { $g_cMpeInfo($mpe+bLoaded) == 0 && $g_bDisassembly($mpe) == 0} {
		return
	}

	set x [xlisp gg-running? $mpe]
	if {$x != "()"} {
		tk_messageBox -message "Can't check breakpoint while MPE is running."
		return
	}

	set index [$sourceTextWidget index "$pos linestart"]
	set lineNo  [expr int($index)]

	set addr [xlisp gg-address $g_cMpeInfo($mpe+nLastFileIndex) $lineNo $mpe]
	set info [xlisp gg-breakpoint-settings $mpe $addr]

	if {$info == "()"} {
		return
	}

        set s [getKeywordValue $info ":count"]
	
	if {$s == "()"} {
		set g_BPcount ""
	} else {
		set g_BPcount $s
	}

        set s [xlisp gg-breakpoint-condition $mpe $addr]
	
	if {$s == "()"} {
		set g_BPcondition ""
	} else {
		set g_BPcondition $s
	}


        set s [xlisp gg-breakpoint-after $mpe $addr]
	
	if {$s == "()"} {
		set g_BPafter ""
	} else {
		set g_BPafter $s
	}


        set s [xlisp gg-breakpoint-before $mpe $addr]
	
	if {$s == "()"} {
		set g_BPbefore ""
	} else {
		set g_BPbefore $s
	}

	# tk_messageBox -message "count=$g_BPcount after=$g_BPafter before=$g_BPbefore condition=$g_BPcondition" 

	configureBreakpoint $base $mpe $addr
}


# :showBusy
proc showBusy { mpe } {
global g_bgColor
	if [winfo exists .mpe$mpe+Top] {
		set g_bgColor [.mpe$mpe+Top.sourceFrame.commandFrame.statusLabel cget -bg]
		.mpe$mpe+Top.sourceFrame.commandFrame.statusLabel config -bg yellow

		update idletasks
	}
}

# :hideBusy
proc hideBusy { mpe } {
global g_bgColor

	if [winfo exists .mpe$mpe+Top] {
		if {[.mpe$mpe+Top.sourceFrame.commandFrame.statusLabel cget -bg] == "yellow"} {
			.mpe$mpe+Top.sourceFrame.commandFrame.statusLabel config -bg $g_bgColor
		}
	}
}

proc showStatus { msg } {
	toplevel .statusWindow
#	frame .statusWindow.frame 
	label .statusWindow.label -text $msg
#	pack  .statusWindow.frame  
	pack  .statusWindow.label 
	if [winfo exists .mpe0+Top] {
		.mpe0+Top.sourceFrame.sourceText config -bg gray
		update idletasks
		tkwait visibility .statusWindow.label
	}

}


proc hideStatus {} {
	if [winfo exists .mpe0+Top] {
		.mpe0+Top.sourceFrame.sourceText config -bg white
		destroy .statusWindow
	}
}


# :findText
proc findText { orgbase mpe} {
global g_confirmStatus
global g_textString
global g_startTextSel
global g_countTextSel
global g_MatchCase
global g_Direction

    set win .findWind
    toplevel $win -class "Find"

    wm resizable $win 0 0

    wm title $win "Find"
    wm group $win .

    # please leave that here for the Find Box!!!
    wm geometry $win 216x156+491+231

    after idle [format {
        update idletasks
        wm minsize %s [winfo reqwidth %s] [winfo reqheight %s]
    } $win $win $win]

    set top $win
    set base $win
    bind $win <Return> [list $base.but26 invoke]
    bind $win <Cancel> [list $base.but27 invoke]

    ###################
    # CREATING WIDGETS
    ###################
    frame $base.fra18 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    label $base.fra18.lab19 \
        -borderwidth 1 -text {Find what:} 
    entry $base.fra18.ent20 -textvariable g_textString($mpe)
    frame $base.fra19 
    checkbutton $base.fra19.che21 \
        -text {Match case}  -variable g_MatchCase($mpe)
    label $base.fra19.lab25 \
        -borderwidth 1 -text Direction: 
    frame $base.fra19.fra22 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    radiobutton $base.fra19.fra22.rad23 \
        -text Up -variable g_Direction($mpe) -value "backward"
    radiobutton $base.fra19.fra22.rad24 \
        -text Down -variable g_Direction($mpe) -value "forward"

    button $base.but26 \
        -text " OK " -command { set g_confirmStatus 1 } -default active
    button $base.but27 \
        -text Cancel -command { set g_confirmStatus 0 } 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra18 -side top -expand true -fill x
    pack $base.fra18.lab19 -side left
    pack $base.fra18.ent20 -side left
    pack $base.fra19 -side top -expand true -fill x
    pack $base.fra19.che21 
    pack $base.fra19.lab25 
    pack $base.fra19.fra22 
    pack $base.fra19.fra22.rad23 -anchor w
    pack $base.fra19.fra22.rad24 -anchor w
    pack $base.but26 -side left -padx 20
    pack $base.but27 -side right -padx 20

    focus $top.fra18.ent20
    wm protocol $top WM_DELETE_WINDOW "$top.but27 invoke"

    dialog_wait $top g_confirmStatus
    destroy $top

    if { $g_confirmStatus == "1" } {
        $orgbase.sourceFrame.sourceText configure -state normal
	if {$g_startTextSel($mpe) != ""} {
	        $orgbase.sourceFrame.sourceText tag remove hilight "$g_startTextSel($mpe)" "$g_startTextSel($mpe) +$g_countTextSel($mpe) chars"
	}
	if {$g_Direction($mpe) == "forward"} {
		if {$g_MatchCase($mpe) == 0} {
			set g_startTextSel($mpe) [$orgbase.sourceFrame.sourceText search -nocase -forward -count g_countTextSel($mpe) $g_textString($mpe) "$g_startTextSel($mpe) +$g_countTextSel($mpe) chars" end ]
		} else {
			set g_startTextSel($mpe) [$orgbase.sourceFrame.sourceText search -forward -count g_countTextSel($mpe) $g_textString$(mpe) "$g_startTextSel($mpe) +$g_countTextSel($mpe) chars" end ]
		}
	} else {
		if {$g_MatchCase == 0} {
			set g_startTextSel($mpe) [$orgbase.sourceFrame.sourceText search -nocase -backward -count g_countTextSel($mpe) $g_textString($mpe) $g_startTextSel($mpe) 1.0 ]
		} else {
			set g_startTextSel($mpe) [$orgbase.sourceFrame.sourceText search -backward -count g_countTextSel($mpe) $g_textString($mpe) $g_startTextSel($mpe) 1.0 ]
		}
	}
	if {$g_startTextSel($mpe) == ""} {
		$orgbase.sourceFrame.sourceText configure -state disabled
		if {$g_Direction($mpe) == "forward"} {
			set g_startTextSel($mpe) "1.0"
		} else {
			set g_startTextSel($mpe) "end"
		}
		set g_countTextSel($mpe) 0
		return
	} 
	 	$orgbase.sourceFrame.sourceText tag add hilight "$g_startTextSel($mpe)" "$g_startTextSel($mpe) + $g_countTextSel($mpe) chars" 
		$orgbase.sourceFrame.sourceText configure -state disabled

		set x [string first "." $g_startTextSel($mpe)]
		incr x -1
		set lineNo [string range $g_startTextSel($mpe) 0 $x]
		if {$lineNo != ""} {
			# Scroll down a bit - position current line
			#stupid way of doing this...
			if { $lineNo > 0 } {
				incr lineNo -1
				if { $lineNo > 0 } {
					incr lineNo -1
				}
				if { $lineNo > 0 } {
					incr lineNo -1
				}
				if { $lineNo > 0 } {
					incr lineNo -1
				}
			}
			$orgbase.sourceFrame.sourceText yview $lineNo
	}
    }
}

# :findNext
proc findNext { base mpe} {
global g_textString
global g_startTextSel
global g_countTextSel
global g_MatchCase
global g_Direction

	if {$g_textString($mpe) == "" } {
		findText $base $mpe
		return
	}
        $base.sourceFrame.sourceText configure -state normal
	if {$g_startTextSel($mpe) != ""} {
	        $base.sourceFrame.sourceText tag remove hilight "$g_startTextSel($mpe)" "$g_startTextSel($mpe) +$g_countTextSel($mpe) chars"
	}
	if {$g_Direction($mpe) == "forward"} {
		if {$g_MatchCase($mpe) == 0} {
			set g_startTextSel($mpe) [$base.sourceFrame.sourceText search -nocase -forward -count g_countTextSel($mpe) $g_textString($mpe) "$g_startTextSel($mpe) +$g_countTextSel($mpe) chars"  end ]
		} else {
			set g_startTextSel($mpe) [$base.sourceFrame.sourceText search -forward -count g_countTextSel($mpe) $g_textString($mpe) "$g_startTextSel($mpe) +$g_countTextSel($mpe) chars"  end ]
		}
	} else {
		if {$g_MatchCase($mpe) == 0} {
			set g_startTextSel($mpe) [$base.sourceFrame.sourceText search -nocase -backward -count g_countTextSel($mpe) $g_textString($mpe)  $g_startTextSel($mpe) 1.0 ]
		} else {
			set g_startTextSel($mpe) [$base.sourceFrame.sourceText search -backward -count g_countTextSel($mpe) $g_textString($mpe) $g_startTextSel($mpe) 1.0 ]
		}
	}
	if {$g_startTextSel($mpe) == ""} {
		$base.sourceFrame.sourceText configure -state disabled
		if {$g_Direction($mpe) == "forward"} {
			set g_startTextSel($mpe) "1.0"
		} else {
			set g_startTextSel($mpe) "end"
		}
		set g_countTextSel($mpe) 0
		return
	} 
	 	$base.sourceFrame.sourceText tag add hilight "$g_startTextSel($mpe)" "$g_startTextSel($mpe) +$g_countTextSel($mpe) chars" 

		$base.sourceFrame.sourceText configure -state disabled
		set x [string first "." $g_startTextSel($mpe)]
		incr x -1
		set lineNo [string range $g_startTextSel($mpe) 0 $x]
		if {$lineNo != ""} {
		# Scroll down a bit - position current line
		#stupid way of doing this...
		if { $lineNo > 0 } {
			incr lineNo -1
			if { $lineNo > 0 } {
				incr lineNo -1
			}
			if { $lineNo > 0 } {
				incr lineNo -1
			}
			if { $lineNo > 0 } {
				incr lineNo -1
			}
		}
		$base.sourceFrame.sourceText yview $lineNo
	}
}


proc clearText { base mpe} {
global g_textString
global g_startTextSel
global g_countTextSel
global g_cMpeInfo
	if {$g_startTextSel($mpe) != ""} {
	        $base.sourceFrame.sourceText configure -state normal
        	$base.sourceFrame.sourceText tag remove hilight "$g_startTextSel($mpe)" "$g_startTextSel($mpe) +$g_countTextSel($mpe) chars"
		$base.sourceFrame.sourceText configure -state disabled


		# Highlight current instruction
		set addr [xlisp gg-register "\"pcexec\"" $mpe]
		set x [xlisp gg-line-number $mpe $addr]

		set fileNo [lindex $x 0]
        	set fileNo [string trim $fileNo (]

		if {$fileNo == $g_cMpeInfo($mpe+nLastFileIndex)} {
			set lineNo  [lindex $x 1]
			set count   [lindex $x 2]
			set count   [string trim $count )]

			set lineNo2 [expr $lineNo + $count]
			$base.sourceFrame.sourceText configure -state normal
			$base.sourceFrame.sourceText tag remove hilight 1.0 end
			set lineNo2 [expr $lineNo + $count]
			$base.sourceFrame.sourceText tag add hilight "$lineNo.1" "$lineNo2.0" 
			$base.sourceFrame.sourceText configure -state disabled

			# Scroll down a bit - position current line
			#stupid way of doing this...
			if { $lineNo > 0 } {
				incr lineNo -1
				if { $lineNo > 0 } {
					incr lineNo -1
				}
				if { $lineNo > 0 } {
					incr lineNo -1
				}
				if { $lineNo > 0 } {
					incr lineNo -1
				}
			}
			$base.sourceFrame.sourceText yview $lineNo
		}
	}
}


# :gotoLine
proc gotoLine { base mpe} {
global g_confirmStatus
global g_lineNr
    set top [dialog_create "Goto Line"]

    bind $top <Return> [list $top.buttons.ok invoke]
    bind $top <Escape> [list $top.buttons.cancel invoke]

    set g_lineNr ""
    frame $top.fra22 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    label $top.fra22.lab23 \
        -anchor w -borderwidth 1 -justify left -text Line: -width 8 
    entry $top.fra22.ent24 -textvariable g_lineNr
    frame $top.buttons \
        -borderwidth 0 -height 75 -relief groove -width 125 

    button $top.buttons.ok -text "OK" -command { set g_confirmStatus 1 } -default active
    button $top.buttons.cancel -text "Cancel" -command { set g_confirmStatus 0 }

    grid $top.fra22 \
        -in $top -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab23 \
        -in $top.fra22 -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent24 \
        -in $top.fra22 -column 1 -row 0 -columnspan 1 -rowspan 1 

    grid $top.buttons \
        -in $top -column 0 -row 2 -columnspan 2 -rowspan 1 
    grid $top.buttons.ok \
        -in $top.buttons -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 12
    grid $top.buttons.cancel \
        -in $top.buttons -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 12

    focus $top.fra22.ent24
    
    wm protocol $top WM_DELETE_WINDOW "$top.buttons.cancel invoke"

    dialog_wait $top g_confirmStatus
    destroy $top

    if { $g_confirmStatus == 1 } {
	$base.sourceFrame.sourceText yview $g_lineNr
    }
}

proc addGlobalCEntry { base mpe } {
global g_confirmStatus
global g_var
global g_globalBrowserId
global g_bGlobalBrowser
    set top [dialog_create "Add Global C Variable"]

    bind $top <Return> [list $top.buttons.ok invoke]
    bind $top <Escape> [list $top.buttons.cancel invoke]


    set g_var ""
    frame $top.fra22 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    label $top.fra22.lab23 \
        -anchor w -borderwidth 1 -justify left -text Variable: -width 8 
    entry $top.fra22.ent24 -textvariable g_var
    frame $top.buttons \
        -borderwidth 0 -height 75 -relief groove -width 125 

    button $top.buttons.ok -text "OK" -command { set g_confirmStatus 1 } -default active
    button $top.buttons.cancel -text "Cancel" -command { set g_confirmStatus 0 }

    grid $top.fra22 \
        -in $top -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab23 \
        -in $top.fra22 -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent24 \
        -in $top.fra22 -column 1 -row 0 -columnspan 1 -rowspan 1 

    grid $top.buttons \
        -in $top -column 0 -row 2 -columnspan 2 -rowspan 1 
    grid $top.buttons.ok \
        -in $top.buttons -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 12
    grid $top.buttons.cancel \
        -in $top.buttons -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 12

    focus $top.fra22.ent24
    
    wm protocol $top WM_DELETE_WINDOW "$top.buttons.cancel invoke"

    dialog_wait $top g_confirmStatus
    destroy $top

    if { $g_confirmStatus == 1 } {
		if {$g_bGlobalBrowser == 0} {
			createGlobalBrowserWindow .globalvars "Global C Variables" $mpe 40 120
			set g_bGlobalBrowser 1
		}
		set varname1 "_$g_var"
		set x [xlisp gg-browse-add-symbol $mpe "\"$g_globalBrowserId($mpe)\"" "\"$varname1\""]
		if {$x == "()"} {
			tk_messageBox -message "$g_var is not a global C variable."
		}
    }
}


proc disassembleAt { base mpe } {
global g_confirmStatus
global g_addr
    set top [dialog_create "Disassamble at"]

    bind $top <Return> [list $top.buttons.ok invoke]
    bind $top <Escape> [list $top.buttons.cancel invoke]

    set g_addr ""
    frame $top.fra22 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    label $top.fra22.lab23 \
        -anchor w -borderwidth 1 -justify left -text "Address (Hex):" -width 12 
    entry $top.fra22.ent24 -textvariable g_addr
    frame $top.buttons \
        -borderwidth 0 -height 75 -relief groove -width 125 

    button $top.buttons.ok -text "OK" -command { set g_confirmStatus 1 } -default active
    button $top.buttons.cancel -text "Cancel" -command { set g_confirmStatus 0 }

    grid $top.fra22 \
        -in $top -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab23 \
        -in $top.fra22 -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent24 \
        -in $top.fra22 -column 1 -row 0 -columnspan 1 -rowspan 1 

    grid $top.buttons \
        -in $top -column 0 -row 2 -columnspan 2 -rowspan 1 
    grid $top.buttons.ok \
        -in $top.buttons -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 12
    grid $top.buttons.cancel \
        -in $top.buttons -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 12

    focus $top.fra22.ent24
    
    wm protocol $top WM_DELETE_WINDOW "$top.buttons.cancel invoke"

    dialog_wait $top g_confirmStatus
    destroy $top

    if { $g_confirmStatus == 1 } {
	set addr "0x$g_addr"
	if [catch {set addr [expr $addr * 1]} result] { 
		# not a number, so assume it's a label
		# set addr "~$g_addr"
		set addr [xlisp "~$g_addr"]
		if {$addr == "()"} {
			tk_messageBox -message "Unknown symbol."
			return	
		}
	} 
	halt $mpe $addr "Disassemble"
    }


}

# add breakpoint at an address
proc addBreakpoint { base mpe} {
global g_confirmStatus
global g_bpAddr
    set top [dialog_create "Set/Clear Breakpoint"]

    bind $top <Return> [list $top.buttons.ok invoke]
    bind $top <Escape> [list $top.buttons.cancel invoke]

    set g_bpAddr ""
    frame $top.fra22 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    label $top.fra22.lab23 \
        -anchor w -borderwidth 1 -justify left -text "Address (Hex):" -width 12
    entry $top.fra22.ent24 -textvariable g_bpAddr
    frame $top.buttons \
        -borderwidth 0 -height 75 -relief groove -width 125 

    button $top.buttons.ok -text "OK" -command { set g_confirmStatus 1 } -default active
    button $top.buttons.cancel -text "Cancel" -command { set g_confirmStatus 0 }

    grid $top.fra22 \
        -in $top -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab23 \
        -in $top.fra22 -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent24 \
        -in $top.fra22 -column 1 -row 0 -columnspan 1 -rowspan 1 

    grid $top.buttons \
        -in $top -column 0 -row 2 -columnspan 2 -rowspan 1 
    grid $top.buttons.ok \
        -in $top.buttons -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 12
    grid $top.buttons.cancel \
        -in $top.buttons -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 12

    focus $top.fra22.ent24
    
    wm protocol $top WM_DELETE_WINDOW "$top.buttons.cancel invoke"

    dialog_wait $top g_confirmStatus
    destroy $top

    if { $g_confirmStatus == 1 } {
	# if a number, convert to hex
	set bpAddr "0x$g_bpAddr"


	if [catch {set bpAddr [expr $bpAddr * 1]} result] { 
		# not a number, so assume it's a label
		set bpAddr "~$g_bpAddr"
	} 
	xlisp gg-toggle-breakpoint! $bpAddr $mpe
    }
}




global g_bpDAcount
global g_bpDAcondition

set g_bpDAcount "" 
set g_bpDAcondition ""

proc getKeywordValue { keyValueList key } {

	# find start of key/value pair
	set i [string first $key $keyValueList]

	# remove string prior to key
	set s [string range $keyValueList $i end]

	# find the end of the key
	regexp {[:a-zA-Z\-\?]*([^$]*)} $s match s

	# remove leading spaces before value
	set s [string trimleft $s]
	
	# remove everything following the value
	if {[string range $s 0 1] == "()"} {
		set s "()"
	} else {
		scan $s {%[^ )]} s
	}
    return $s
}

proc ignoreDABreakpoint { base mpe } {
global g_nIgnoreDA

	if {$g_nIgnoreDA($mpe) == 1} {
		set x [xlisp gg-data-breakpoint-change! $mpe ":breakpoint?" "#f" ]
	} else {
		set x [xlisp gg-data-breakpoint-change! $mpe ":breakpoint?" "#t" ]
	}
}

# set DA breakpoint at an address
proc setDABreakpoint { base mpe } {
global g_confirmStatus
global g_bpDAAddr
global g_bpDAcount
global g_bpDAcondition
global bpDARead
global bpDAWrite


	set info [xlisp gg-data-breakpoint-settings $mpe]

	if {$info != "()"} {

        set s [getKeywordValue $info ":count"]
	
		if {$s == "()"} {
			set g_bpDAcount ""
		} else {
			set g_bpDAcount $s
		}

        set s [xlisp gg-data-breakpoint-condition $mpe]
	
		if {$s == "()"} {
			set g_bpDAcondition ""
		} else {
			set g_bpDAcondition $s
		}

        set s [getKeywordValue $info ":address"]

		if {$s == "()"} {
			set g_bpDAAddr ""
		} else {
			set g_bpDAAddr $s
			set g_bpDAAddr [format "%x" $g_bpDAAddr]
		}

        set s [getKeywordValue $info ":read?"]
	
		if {$s == "()"} {
			set bpDARead 0
		} else {
			set bpDARead 1
		}

        set s [getKeywordValue $info ":write?"]
	
		if {$s == "()"} {
			set bpDAWrite 0
		} else {
			set bpDAWrite 1
		}

	} else {
		set g_bpDAAddr ""
        set g_bpDAcount ""
        set g_bpDAcondition ""
		set bpDAWrite 1
		set bpDARead 1
	}


    set top [dialog_create "Set DA Breakpoint"]

    bind $top <Return> [list set g_confirmStatus 1]
    bind $top <Escape> [list set g_confirmStatus 0]


    frame $top.fra22 -borderwidth 2 -height 75 -relief groove -width 125 
    label $top.fra22.lab23 -anchor e -borderwidth 1 -justify right -text Address(Hex/Symbol): -width 18
    label $top.fra22.lab24 -anchor e -borderwidth 1 -justify right -text Count: -width 18
    label $top.fra22.lab25 -anchor e -borderwidth 1 -justify right -text Condition: -width 18

    entry $top.fra22.ent24 -textvariable g_bpDAAddr
    entry $top.fra22.ent25 -textvariable g_bpDAcount
    entry $top.fra22.ent26 -textvariable g_bpDAcondition

    checkbutton $top.fra22.cb25 -text "DA Read Enable" -variable bpDARead
    checkbutton $top.fra22.cb26 -text "DA Write Enable" -variable bpDAWrite
    
    frame $top.buttons -borderwidth 0 -height 75 -relief groove -width 125 

    button $top.buttons.set -text "Set" -command { set g_confirmStatus 1 } -default active
    button $top.buttons.clear -text "Clear" -command { set g_confirmStatus 2 } 
    button $top.buttons.cancel -text "Cancel" -command { set g_confirmStatus 0 }

    grid $top.fra22 -in $top -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab23 -in $top.fra22 -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab24 -in $top.fra22 -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab25 -in $top.fra22 -column 0 -row 2 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent24 -in $top.fra22 -column 1 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent25 -in $top.fra22 -column 1 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent26 -in $top.fra22 -column 1 -row 2 -columnspan 1 -rowspan 1 

    grid $top.fra22.cb25 -in $top.fra22 -column 0 -row 3 -columnspan 1 -rowspan 1 
    grid $top.fra22.cb26 -in $top.fra22 -column 1 -row 3 -columnspan 1 -rowspan 1 

    grid $top.buttons -in $top -column 0 -row 2 -columnspan 2 -rowspan 1 
    grid $top.buttons.set -in $top.buttons -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 12
    grid $top.buttons.clear -in $top.buttons -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 12
    grid $top.buttons.cancel -in $top.buttons -column 2 -row 0 -columnspan 1 -rowspan 1 -padx 12

    focus $top.fra22.ent24
    
    wm protocol $top WM_DELETE_WINDOW "$top.buttons.cancel invoke"

    dialog_wait $top g_confirmStatus
    destroy $top

    if { $g_confirmStatus == 1 } {
	#
	# SET!
	#
	# if a number, convert to hex
	set bpDAAddr "0x$g_bpDAAddr"


	if [catch {set bpDAAddr [expr $bpDAAddr * 1]} result] { 
		# not a number, so assume it's a label
		set bpDAAddr "~$g_bpDAAddr"
	} 

	if {$g_bpDAcount == ""} {
		set g_bpDAcount "()"
	}
	if {$g_bpDAcondition == ""} {
		set g_bpDAcondition "()"
	} else {
		set g_bpDAcondition "\"$g_bpDAcondition\""
	}
	if {$bpDARead == "1"} {
		set bpDARead "#t"
	} else {
		set bpDARead "#f"
	}
	if {$bpDAWrite == "1"} {
		set bpDAWrite "#t"
	} else {
		set bpDAWrite "#f"
	}

	set x [xlisp gg-set-data-breakpoint! $bpDAAddr $mpe]

	set x [xlisp gg-data-breakpoint-change! $mpe ":breakpoint?" "#t" ":count" $g_bpDAcount ":condition" "$g_bpDAcondition" ":read?" $bpDARead ":write?" $bpDAWrite ]
    }
    if { $g_confirmStatus == 2 } {
	# CLEAR
	set x [xlisp gg-clear-data-breakpoint! $mpe]
    }
}


# :configureBreakpoint
proc configureBreakpoint { base mpe addr } {
global g_confirmStatus
global g_BPcondition
global g_BPcount
global g_BPbefore
global g_BPafter
    set top [dialog_create "Configure Breakpoint"]

    bind $top <Return> [list $top.buttons.ok invoke]
    bind $top <Escape> [list $top.buttons.cancel invoke]

    frame $top.fra22  -borderwidth 2 -height 75 -relief groove -width 125 
    label $top.fra22.lab23 -anchor w -borderwidth 1 -justify right -text Condition: -width 12
    entry $top.fra22.ent24 -textvariable g_BPcondition -width 32
    label $top.fra22.lab25 -anchor w -borderwidth 1 -justify right -text Count: -width 12
    entry $top.fra22.ent26 -textvariable g_BPcount -width 32
    label $top.fra22.lab27 -anchor w -borderwidth 1 -justify right -text "Before Method:" -width 12
    entry $top.fra22.ent28 -textvariable g_BPbefore -width 32
    label $top.fra22.lab29 -anchor w -borderwidth 1 -justify right -text "After Method:" -width 12 
    entry $top.fra22.ent30 -textvariable g_BPafter -width 32

    frame $top.buttons \
        -borderwidth 0 -height 75 -relief groove -width 125

    button $top.buttons.ok -text "OK" -command { set g_confirmStatus 1 } -default active
    button $top.buttons.cancel -text "Cancel" -command { set g_confirmStatus 0 }

    grid $top.fra22 -in $top -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab23 -in $top.fra22 -column 0 -row 0 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent24 -in $top.fra22 -column 1 -row 0 -columnspan 1 -rowspan 1
    grid $top.fra22.lab25 -in $top.fra22 -column 0 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent26 -in $top.fra22 -column 1 -row 1 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab27 -in $top.fra22 -column 0 -row 2 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent28 -in $top.fra22 -column 1 -row 2 -columnspan 1 -rowspan 1 
    grid $top.fra22.lab29 -in $top.fra22 -column 0 -row 3 -columnspan 1 -rowspan 1 
    grid $top.fra22.ent30 -in $top.fra22 -column 1 -row 3 -columnspan 1 -rowspan 1 

    grid $top.buttons \
        -in $top -column 0 -row 4 -columnspan 2 -rowspan 1 
    grid $top.buttons.ok \
        -in $top.buttons -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 12
    grid $top.buttons.cancel \
        -in $top.buttons -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 12

    focus $top.fra22.ent24
    
    wm protocol $top WM_DELETE_WINDOW "$top.buttons.cancel invoke"

    dialog_wait $top g_confirmStatus
    destroy $top

    if { $g_confirmStatus == 1 } {

	if {$g_BPcount == ""} {
		set g_BPcount "()"
	}

	if {$g_BPcondition == ""} {
		set g_BPcondition "()"
	} else {
		set g_BPcondition "\"$g_BPcondition\""
	}
	if {$g_BPafter == ""} {
		set g_BPafter "()"
	} else {
		set g_BPafter "\"$g_BPafter\""
	}
	if {$g_BPbefore == ""} {
		set g_BPbefore "()"
	} else {
		set g_BPbefore "\"$g_BPbefore\""
	}

	xlisp gg-breakpoint-change! $mpe $addr ":count" $g_BPcount ":condition" "$g_BPcondition" ":before" "$g_BPbefore" ":after" "$g_BPafter"
    }
}

###   ###   ###   ###   ###   ###   ### 
#	:removeAllBreakpoints
#
proc removeAllBreakpoints { base mpe ask} {
	global g_cMpeInfo
	global g_bDisassembly

	if { $g_cMpeInfo($mpe+bLoaded) == 0 && $g_bDisassembly($mpe) == 0} {
		return
	}
	
	set choice "yes"
	
	if {$ask == 1}  {
		set choice [tk_messageBox -type yesno -default no\
			-message "Do you really want to remove all breakpoints?"\
			-icon question]
	}
	if { $choice == "yes" } {
	 	xlisp gg-clear-all-breakpoints! $mpe
	}
}
###   ###   ###   ###   ###   ###   ### 
#	:setBP (callback)
#
proc setBP { mpe addr fileIndex lineNo} {
	global g_iconBP
	global g_cMpeInfo
	global g_bDisassembly

	if { $fileIndex != $g_cMpeInfo($mpe+nLastFileIndex) && $g_bDisassembly($mpe) == 0} {
		return
	}

	if { $fileIndex != "disassembly" && $g_bDisassembly($mpe) == 1} {
		return
	}
	set base [mpeToWindow $mpe]

 	set bP [image create photo -data $g_iconBP]
	if [winfo exists $base] {
	        $base.sourceFrame.sourceText image create "$lineNo.0" -image $bP
	
		# renew the tag (no idea why we need it, but otherwise
		#  we can't click on the red dot)
		$base.sourceFrame.sourceText tag add tagBP "$lineNo.0" "$lineNo.1"
	}
}

###   ###   ###   ###   ###   ###   ### 
#	:clearBP (callback)
#
proc clearBP { mpe addr fileIndex lineNo} {
	global g_cMpeInfo
	global g_bDisassembly

	set base [mpeToWindow $mpe]

	if [winfo exists $base] {	
		$base.sourceFrame.sourceText configure -state normal
        	$base.sourceFrame.sourceText delete "$lineNo.0" "$lineNo.1"
		$base.sourceFrame.sourceText configure -state disabled
		
		# renew the tag (no idea why we need it, but otherwise
		#  we can't click on the red dot)
		$base.sourceFrame.sourceText tag add tagBP "$lineNo.0" "$lineNo.1"
	}
}

###   ###   ###   ###   ###   ###   ###
#	:clearMPEWindows
#
proc clearMPEWindows {} {
	global g_nMPEs
	global g_cMpeInfo

	set i 0
	while { $i < $g_nMPEs } {
		if { $g_cMpeInfo($i+bLoaded) == 1 } {
			set base [mpeToWindow $i]
			if [winfo exists $base] {
				$base.sourceFrame.sourceText configure -state normal
				$base.regFrame.fileList delete 0 end
				$base.sourceFrame.sourceText delete 1.0 end
				$base.sourceFrame.sourceText configure -state disabled
				wm title $base "MPE $i"
			}
			set g_cMpeInfo($i+bOpen) 0
			set g_cMpeInfo($i+nLastFileIndex) -1
			set g_cMpeInfo($i+bLoaded) 0
			set g_cMpeInfo($i+strProjectPath) "./"
		}
		incr i
	}
}

###   ###   ###   ###   ###   ###   ###
#	:updateWatchWindow
#
proc updateWatchWindow {} {
	global g_nMPEs
return
	if {[winfo exists .watchTop] == 1} {
		.watchTop.watchFrame.watchText configure -state normal	
		.watchTop.watchFrame.watchText delete 1.0 end
		set i 0
		while { $i <  $g_nMPEs} {
			set watchStr [xlisp gg-watch-display-string $i]

			.watchTop.watchFrame.watchText insert end "==MPE $i:========================\n"
			.watchTop.watchFrame.watchText insert end $watchStr
			.watchTop.watchFrame.watchText insert end "\n"
			incr i
		}
		.watchTop.watchFrame.watchText configure -state disabled
	}
}
###   ###   ###   ###   ###   ###   ###
#	:mpeToWindow
#
proc mpeToWindow { mpe } {

	switch -exact -- $mpe {
		"0" { set base .mpe0+Top }
		"1" { set base .mpe1+Top }
		"2" { set base .mpe2+Top }
		"3" { set base .mpe3+Top }
	}

	return $base
}


###   ###   ###   ###   ###   ###   ###
#	:halt
#	disassemble code
proc halt {mpe addr reason} {

	global g_nMPEs
	global g_iconBP
	global g_cMpeInfo
	global g_nShowRegisters
	global g_bDisassembly
	global g_lastReason
	global g_lastAddr
	global g_statusText	

	hideBusy $mpe
	set base [mpeToWindow $mpe]
	set g_bDisassembly($mpe) 1


	if {$reason != "Refresh" && $reason != "Redraw" && $reason != "Start" && $reason != "Stopped" && $reason != "Stop" && $reason != "Step" && $reason != "Breakpoint" && $reason != "Disassemble"} {
		tk_messageBox -message "Exception: $reason"
	}

	# go back 32 bytes
	set org_addr $addr
	if {$reason != "Disassemble" && $reason != "Breakpoint" && $reason != "Start" && $reason != "Redraw"} {
		if { $addr > 0x20300020} {
			set addr [expr $addr - 0x20]
			set addr [expr $addr & 0xfffffffc]
			# tk_messageBox -message "halt addr=$addr reason=$reason"
		}
	}

	set g_lastReason $reason
	set g_lastAddr $addr

	# insert dummy break points
	set tab "\t"
 	set nl "\n"
 	set bP [image create photo -data $g_iconBP]

	if [winfo exists $base] {
		$base.sourceFrame.sourceText configure -state normal
	}
	set code [xlisp gg-disassemble $mpe $addr 80]
	set code [string trim $code \"]
	set lineList [split $code \012]
	if [winfo exists $base] {		
		$base.sourceFrame.sourceText delete 1.0 end
	}
	set lineNo 1

	foreach line $lineList  {
		if {$line != ""} {
			if [winfo exists $base] {
				$base.sourceFrame.sourceText insert end $tab 
	      			$base.sourceFrame.sourceText insert end $line 
				$base.sourceFrame.sourceText insert end $nl 
				$base.sourceFrame.sourceText tag add tagBP "$lineNo.0" "$lineNo.1"
			}
			incr lineNo
		}
	}
	if [winfo exists $base] {		
		$base.sourceFrame.sourceText configure -state disabled
	}
	# Highlight current instruction
	set x [xlisp gg-line-number $mpe $org_addr]


	set lineNo  [lindex $x 1]
	if {$lineNo != "()"} {
	    set count   [lindex $x 2]
	    set count   [string trim $count )]	
	    set lineNo2 [expr $lineNo + $count]

		if [winfo exists $base] {				
		    $base.sourceFrame.sourceText configure -state normal
		    $base.sourceFrame.sourceText tag remove hilight 1.0 end
		    $base.sourceFrame.sourceText tag add hilight "$lineNo.1" "$lineNo2.0" 
		    $base.sourceFrame.sourceText configure -state disabled
		}
	}
	# Update status
	if {$reason == "Stop"} {
		set reason "Stopped"
	}
	set g_statusText($mpe) "MPE $mpe State: $reason"

	# new, added 3/23/98 by hmk - now bps show up in disassembly
	xlisp gg-refresh-all-breakpoints $mpe
}
###   ###   ###   ###   ###   ###   ###
# :showStackFrame
#
proc showStackFrame {base mpe} {
global g_nStackFrame


     set n 0
     set fr [xlisp gg-frame $mpe $n]
     while {$fr != "()"} {
		set stackFrame($n) $fr
		incr n
		set fr [xlisp gg-frame $mpe $n]
     }

    if [winfo exists $base.menuBar.menuStack] {
	$base.menuBar delete "Stack"
	destroy $base.menuBar.menuStack
	update
    }  
    # done twice because the first time does not always get through!!!
    if [winfo exists $base.menuBar.menuStack] {
	$base.menuBar delete "Stack"
	destroy $base.menuBar.menuStack
	update
    }  
    update
    $base.menuBar add cascade -label Stack -underline 0 -menu $base.menuBar.menuStack
    menu $base.menuBar.menuStack -tearoff 0 


    set i 0 
    while { $i < $n } {
	    if [winfo exists $base.menuBar.menuStack] {
		    $base.menuBar.menuStack add radio -label "$stackFrame($i)" -variable g_nStackFrame($mpe)\
			 -command [list stackFrameEvent $base $mpe $i]
	    }
	    incr i 
    }
    set g_nStackFrame($mpe) "$stackFrame(0)"
    set g_StackShownOnce($mpe) 1
    return 
}


proc hideStackFrame {base mpe} {

    if [winfo exists $base.menuBar.menuStack] {
	$base.menuBar delete "Stack"
	destroy $base.menuBar.menuStack
	update
    } 
}

proc stackFrameEvent {stackList mpe n} {
global g_nStackFrame
global g_browserNeedsUpdate

	update
	if {$n != ""} {
		set g_browserNeedsUpdate($mpe) 0
		varBrowseClear $mpe root
		set pc  [xlisp gg-browse-frame $mpe "\"root\"" $n]

		set x [xlisp gg-line-number $mpe $pc]
		set fileNo [lindex $x 0]
	        set fileNo [string trim $fileNo (]
		if {$fileNo != "()"} {
		    set lineNo  [lindex $x 1]
		    set count   [lindex $x 2]
		    set count   [string trim $count )]
		} else {
			set fileNo 1
			set lineNo 0
			set count 1
		}
		updateSourceWindow $mpe $pc "Redraw" $fileNo $lineNo $count
	}

}

###   ###   ###   ###   ###   ###   ###
# :goBackToDisassembly {base mpe} {
#
proc goBackToDisassembly {base mpe} {
	global g_lastReason
	global g_lastAddr
	global g_cMpeInfo
	global g_bDisassembly 
	global g_DisMode
	global g_nDisassemblyFileIndex

	if { $g_DisMode($mpe) == 1 } {

		xlisp gg-enable-disassembly $mpe "#f"
		set g_DisMode($mpe) 0
		set addr [xlisp gg-register "\"pcexec\"" $mpe]

		set g_nDisassemblyFileIndex($mpe) -1
		set x [xlisp gg-line-number $mpe $addr]
		set fileNo [lindex $x 0]
	        set fileNo [string trim $fileNo (]
		if {$fileNo != ")"} {
#tk_messageBox -message "go to source mode; fileNo=$fileNo"

			set lineNo  [lindex $x 1]
	 		set count   [lindex $x 2]
			set count   [string trim $count )]
			set g_bDisassembly($mpe) 0

			set x  [xlisp gg-browse-frame $mpe "\"root\"" 0]
			# we do a Redraw+ so that the stack frame appears
			updateSourceWindow $mpe $addr "Redraw+" $fileNo $lineNo $count
		} else {
			set g_bDisassembly($mpe) 1
			halt $mpe $addr "Redraw"
		}	
	} else {
		hideStackFrame $base $mpe
		$base.menuBar.menuView entryconfigure 3 -label "Show Source"
		xlisp gg-enable-disassembly $mpe "#t"
		set addr [xlisp gg-register "\"pcexec\"" $mpe]
		set g_DisMode($mpe) 1
		set g_bDisassembly($mpe) 1

# FIX THIS:::: needs to point to file with current PC!!!!, not currently selected one!!
# fix starts here
		set x [xlisp gg-line-number $mpe $addr]

		set fileNo [lindex $x 0]
        	set fileNo [string trim $fileNo (]		
		set g_nDisassemblyFileIndex($mpe) $fileNo
#
# old way:
##		set g_nDisassemblyFileIndex($mpe) $g_cMpeInfo($mpe+nLastFileIndex)
# end of problem
		set g_cMpeInfo($mpe+nLastFileIndex) -1
		halt $mpe $addr "Disassemble"
	}	

	return
}





###   ###   ###   ###   ###   ###   ###
# :goToCurrentPC {base mpe} {
#
proc goToCurrentPC {base mpe} {
	global g_lastReason
	global g_lastAddr
	global g_cMpeInfo
	global g_bDisassembly 
	global g_DisMode
	global g_nDisassemblyFileIndex


	xlisp gg-enable-disassembly $mpe "#f"
	set g_DisMode($mpe) 0
	set addr [xlisp gg-register "\"pcexec\"" $mpe]

	set g_nDisassemblyFileIndex($mpe) -1
	set x [xlisp gg-line-number $mpe $addr]
	set fileNo [lindex $x 0]
        set fileNo [string trim $fileNo (]
	if {$fileNo != ")"} {
		set lineNo  [lindex $x 1]
 		set count   [lindex $x 2]
		set count   [string trim $count )]
		set g_bDisassembly($mpe) 0

		set x  [xlisp gg-browse-frame $mpe "\"root\"" 0]
		# we do a Redraw+ so that the stack frame appears
		updateSourceWindow $mpe $addr "Redraw+" $fileNo $lineNo $count
	} else {
		set g_bDisassembly($mpe) 1
		halt $mpe $addr "Redraw"
	}
}




###   ###   ###   ###   ###   ###   ###
#	:fileListEvent
#	Called either in the event a user clicked
#       in the fileList box or when updateSourceWindow
#	is called. Reason updateSourceWindow calls this
#       is that the due to execution we are in a new
#       file and have to display it.
#
#	typeOfCall specifies the type of call - 
#		0 if an event, 
#		1 if called by updateSourceWindow
#		2 caled by even in break point list
proc fileListEvent {fileList mpe typeOfCall fileIndex lineNo2} {
	global g_cMpeInfo
	global g_iconBP
	global g_DisMode
	global g_bDisassembly
	global g_nDisassemblyFileIndex
	global g_startTextSel

	if {![winfo exists .mpe$mpe+Top]} {
		return
	}
	set nLastListSel 0

	if { $g_cMpeInfo($mpe+bLoaded) == 0 } {
		# nothing loaded, nothing to do
		return
	}
#tk_messageBox -message "fileList: lastFileIndex=$g_cMpeInfo($mpe+nLastFileIndex)"
	if { $g_cMpeInfo($mpe+nLastFileIndex) != -1 } {
		if {[info exists g_cMpeInfo($mpe+nFileIndexToListIndex+$g_cMpeInfo($mpe+nLastFileIndex))]} {
			set nLastListSel $g_cMpeInfo($mpe+nFileIndexToListIndex+$g_cMpeInfo($mpe+nLastFileIndex))
		} else {
			return
		}
	
# HMK 10/15/98 - we take this out for now because people can't select the highlighted file!	
#		if {$typeOfCall == 0 && [$fileList curselection] == $nLastListSel} {
#			# if user re-selected current one, nothing to do
#			return
#		}
	} else {
		set nLastListSel 0
	}
	set i 0
	set base [mpeToWindow $mpe]
	set cpy_lastSelection $g_cMpeInfo($mpe+nLastFileIndex)	
	$base.regFrame.fileList selection clear $nLastListSel
	if {$typeOfCall == 0} {
		set i [$fileList curselection]
		if {$i != "" } {
			set fileIndex $g_cMpeInfo($mpe+nListIndexToFileIndex+$i)
		} else {
			if {[info exists g_cMpeInfo($mpe+nListIndexToFileIndex+0)] } {
				set fileIndex $g_cMpeInfo($mpe+nListIndexToFileIndex+0)
			}	
		}
	} 

#	tk_messageBox -message "call=$typeOfCall; i=$i; fI=$fileIndex last=$g_cMpeInfo($mpe+nLastFileIndex)"

        # Get file name of current file
	set fname [xlisp gg-get-file-reference $fileIndex $mpe]
	set fname [string trim $fname \"]
	set fname [file tail $fname]

        # if it's a new file, force an an update (reload)
	if {$g_cMpeInfo($mpe+nLastFileIndex) != $fileIndex } {
		# force an update
		set g_cMpeInfo($mpe+$fname+bLoaded) 0		
	}
	set cpy_bDisassembly $g_bDisassembly($mpe)
	set cpy_fileIndex $g_cMpeInfo($mpe+nLastFileIndex) 
	set g_cMpeInfo($mpe+nLastFileIndex) $fileIndex
	$base.menuBar.menuView entryconfigure 3 -label "Show Disassembly"	

	set g_bDisassembly($mpe) 0

# new: 3/25/99
			xlisp gg-enable-disassembly $mpe "#f"
			set g_DisMode($mpe) 0

			set g_nDisassemblyFileIndex($mpe) -1
# end new
	$base.sourceFrame.sourceText configure -state normal

	if {$fname != "" && $fname != "()" && $g_cMpeInfo($mpe+$fname+bLoaded) == 0 &&\
	 [info exists g_cMpeInfo($mpe+file$fileIndex+strPathName)]} {
		# Load source code
		# Build path name
#tk_messageBox -message "load source"
		if {[file tail $fname] == $fname} {
			set wholeFname "$g_cMpeInfo($mpe+file$fileIndex+strPathName)"
		} else {
			set wholeFname $fname
		}

		set x [file exists $wholeFname]
		if {$x == 0} {
			if {$typeOfCall == 0} {
if { 1 } {
			xlisp gg-enable-disassembly $mpe "#f"
			set g_DisMode($mpe) 0

			set g_nDisassemblyFileIndex($mpe) -1
} else {
				set g_bDisassembly($mpe) $cpy_bDisassembly
}
				set g_cMpeInfo($mpe+nLastFileIndex) $cpy_fileIndex 
				$base.regFrame.fileList selection set $cpy_lastSelection
				if {[$fileList curselection] != {}} {
					foreach $i {[$fileList curselection]} {
						if {$i != $cpy_lastSelection} {
							$base.regFrame.fileList selection clear $i
						}
					}
				}
				tk_messageBox -type ok -default ok\
				  -message "The source code file\n\"$wholeFname\"\n does not exist!"\
				  -icon error
			}

			$base.sourceFrame.sourceText configure -state disabled
			return 
		}
		# insert dummy break points
		set tab "\t"
	 	set nl "\n"
      		set bP [image create photo -data $g_iconBP]
		
		# read text line by line into widget
		set lineNo 1
		$base.sourceFrame.sourceText delete 1.0 end
	 	set __f [open $wholeFname r]
	# NEW as of 8/21/99 - for Japanese encoding
	fconfigure $__f -encoding shiftjis
	 	while {![eof $__f]} {
			gets $__f line
			$base.sourceFrame.sourceText insert end $tab 
	      		$base.sourceFrame.sourceText insert end $line 
	      		$base.sourceFrame.sourceText insert end $nl 
			$base.sourceFrame.sourceText tag add tagBP "$lineNo.0" "$lineNo.1"
			incr lineNo
		}
	 	close $__f
		set g_cMpeInfo($mpe+$fname+bLoaded) 1

		xlisp gg-refresh-all-breakpoints $mpe
		set g_startTextSel($mpe) "1.0"
	}
	$base.sourceFrame.sourceText configure -state disabled

	# remember what file we loaded
	$base.regFrame.fileList selection clear $nLastListSel
	if {[info exists g_cMpeInfo($mpe+nFileIndexToListIndex+$fileIndex)]} {
		set new $g_cMpeInfo($mpe+nFileIndexToListIndex+$fileIndex)
		$base.regFrame.fileList selection set $new
	}
	set g_cMpeInfo($mpe+nLastFileIndex) $fileIndex

	# Highlight current instruction

	set x [xlisp gg-running? $mpe]

	if {$x == "()"} {
		set addr [xlisp gg-register "\"pcexec\"" $mpe]
		set x [xlisp gg-line-number $mpe $addr]

		set fileNo [lindex $x 0]
	        set fileNo [string trim $fileNo (]
	} else {
		####?????????????????????????????????????
		return
	}

	if {$typeOfCall == 2} {
		$base.sourceFrame.sourceText yview $lineNo2
		return
	}

	if {$g_nDisassemblyFileIndex($mpe) == $fileIndex} {
#tk_messageBox -message "go back"
		goBackToDisassembly $base $mpe		
		set x [xlisp gg-line-number $mpe $addr]
		set fileNo [lindex $x 0]
        	set fileNo [string trim $fileNo (]
	}
	if {$fileNo == $fileIndex} {
		set lineNo  [lindex $x 1]
		set count   [lindex $x 2]
		set count   [string trim $count )]

		set lineNo2 [expr $lineNo + $count]
		$base.sourceFrame.sourceText configure -state normal
		$base.sourceFrame.sourceText tag remove hilight 1.0 end
		set lineNo2 [expr $lineNo + $count]
		$base.sourceFrame.sourceText tag add hilight "$lineNo.1" "$lineNo2.0" 
		$base.sourceFrame.sourceText configure -state disabled

		# Scroll down a bit - position current line
		#stupid way of doing this...
		if { $lineNo > 0 } {
			incr lineNo -1
			if { $lineNo > 0 } {
				incr lineNo -1
			}
			if { $lineNo > 0 } {
				incr lineNo -1
			}
			if { $lineNo > 0 } {
				incr lineNo -1
			}
		}
		$base.sourceFrame.sourceText yview $lineNo
	}
}

###   ###   ###   ###   ###   ###   ###
#	:updateSourceWindow
#
proc updateSourceWindow { mpe addr reason file lineNo count} {
	global g_nMPEs
	global g_iconBP
	global g_cMpeInfo
	global g_nShowRegisters
	global g_bDisassembly
	global g_CMode
	global g_DisMode	
	global g_statusText
	global g_StackShownOnce
#tk_messageBox -message "HaltOnLine: $mpe $addr $reason file=$file $lineNo $count"
	if {![winfo exists .mpe$mpe+Top]} {
		return
	}

	hideBusy $mpe
	set base [mpeToWindow $mpe]

	if {$reason != "Refresh" && $reason != "Redraw+" && $reason != "Redraw++" && $reason != "Redraw" && $reason != "Start" && $reason != "Stopped" 
	&& $reason != "Stop" && $reason != "Step" && $reason != "Breakpoint" && $reason != "Disassemble" 
	&& [string last "Breakpoint" $reason] == -1} {
		tk_messageBox -message "> Exception: $reason"
	}

	raise $base
	if {$reason != "Refresh"} {
		if { $g_cMpeInfo($mpe+bLoaded) == 0 && $file != "disassembly"} {
			# nothing loaded, nothing to do
			return
		}

		set base [mpeToWindow $mpe]

		# Update status
		set g_statusText($mpe) "MPE $mpe State: $reason"

		# #  # # # # # # # #
		# Update Source Code
		#
		if {$file != "disassembly" && $g_DisMode($mpe) == 0} {
		        # Get file name of current file
			if {[info exists g_cMpeInfo($mpe+file$file+strPathName)]} {
				set wholeFname "$g_cMpeInfo($mpe+file$file+strPathName)"
				set fname [file tail $wholeFname]
			} else {
				set fname [xlisp gg-get-file-reference $file $mpe]
				set fname [string trim $fname \"]
				if {[file tail $fname] == $fname} {
					set wholeFname "$g_cMpeInfo($mpe+strProjectPath)/$fname"
				} else {
					set wholeFname $fname
				}
			}
			set xi  [string last "." $wholeFname]
			set ext [string range $wholeFname $xi end]
			if {$ext == ".c" || $ext == ".cpp" || $ext == ".cc"} {
				set g_CMode($mpe) 1
				set x [xlisp gg-running? $mpe]
				if {$x == "()"} {
					if {$reason != "Redraw"} {
						showStackFrame $base $mpe
					}
					if {$g_nShowRegisters($mpe) != "Show Variables" || $reason == "Redraw++"} {
						set g_nShowRegisters($mpe) "Show Variables"
						toggleRegisterView $base $mpe			
					}
				}
			} else {
#				hideStackFrame $base $mpe
# new as of 4/30/99:
				if {$reason != "Redraw" && $g_StackShownOnce($mpe) == 1} {
					showStackFrame $base $mpe
				}
				set g_CMode($mpe) 0
				if {$g_nShowRegisters($mpe) == "Show Variables"} {
					set g_nShowRegisters($mpe) "Show Registers"
					toggleRegisterView $base $mpe			
				}
			}

			$base.menuBar.menuView entryconfigure 3 -label "Show Disassembly"

	 		if {[file exists $wholeFname]} {
				#
				#	Get Source From File
				#
				fileListEvent $base.regFrame.fileList $mpe 1 $file 0

				if {$g_DisMode($mpe) == 0} {
					# Highlight current instruction
					$base.sourceFrame.sourceText configure -state normal
					$base.sourceFrame.sourceText tag remove hilight 1.0 end
					set lineNo2 [expr $lineNo + $count]
					$base.sourceFrame.sourceText tag add hilight "$lineNo.1" "$lineNo2.0" 
					$base.sourceFrame.sourceText configure -state disabled

					# Scroll down a bit - position current line
					#stupid way of doing this...
					if { $lineNo > 0 } {
						incr lineNo -1
						if { $lineNo > 0 } {
							incr lineNo -1
						}
						if { $lineNo > 0 } {
							incr lineNo -1
						}
						if { $lineNo > 0 } {
							incr lineNo -1
						}
					}
					$base.sourceFrame.sourceText yview $lineNo
				}
			} 
		} else {
			hideStackFrame $base $mpe
			if {$g_bDisassembly($mpe) == 0} {
				halt $mpe $addr $reason
			}
			if {$g_nShowRegisters($mpe) == "Show Variables"} {
				set g_nShowRegisters($mpe) "Show Registers"
				toggleRegisterView $base $mpe			
			}
			set g_cMpeInfo($mpe+nLastFileIndex) -1
			$base.menuBar.menuView entryconfigure 3 -label "Show Source"

			# Highlight current instruction
			$base.sourceFrame.sourceText configure -state normal
			$base.sourceFrame.sourceText tag remove hilight 1.0 end
			set lineNo2 [expr $lineNo + $count]
			$base.sourceFrame.sourceText tag add hilight "$lineNo.1" "$lineNo2.0" 
			$base.sourceFrame.sourceText configure -state disabled

			
				if { $lineNo > 0 } {
					incr lineNo -1
					if { $lineNo > 0 } {
						incr lineNo -1
					}
					if { $lineNo > 0 } {
						incr lineNo -1
					}
					if { $lineNo > 0 } {
						incr lineNo -1
					}
				}
				$base.sourceFrame.sourceText yview $lineNo
		}
	
	}
	#
	# Update Register Frame
	#

	if {$g_nShowRegisters($mpe) == "Show Registers"} {
		set x [xlisp gg-running? $mpe]
		if {$x == "()"} {
			UpdateRegisters $mpe
		}
	}

	#
	# Update Watch Window
	#
	set x [xlisp gg-running? $mpe]
	if {$x == "()"} {
		updateWatchWindow
	}


	if {$reason == "Breakpoint" || [string last "Breakpoint" $reason] != -1} {
		refresh $mpe
	}
}

#####################################################################################################
# REGISTER WINDOW

source_env "register.tcl"

#####################################################################################################
# BROWSER WINDOW

source_env "browser.tcl"


proc varBrowseEntry { mpe parent node name addr value open size start end} {
global g_varString
global g_varStringCopy
global g_nShowRegisters 
global g_browserVarsName
global g_browserVarsAddr
global g_browserVarsParent
global g_browserVarsNode
global g_browserVarsValue
global g_browserVarsStruct
global g_browserVarsSize
global g_browserVarsStart
global g_browserVarsEnd
global g_browserArray
global g_browserArrayIndex
global g_browserNeedsUpdate
global g_browserIdToMpe
global g_globalBrowserId

#tk_messageBox -message "name=$name, node=$node, g_id=$g_globalBrowserId($mpe), parent=$parent"

	if {![winfo exists .mpe$mpe+Top]} {
		return
	}
	if {[string range $name 1 1] == "_"} {
		set name [string range $name 2 end]
	} else {
		set name [string range $name 1 end]
	}
	set name [string trim $name \"]

	if {$open == "#t"} {
		set struct 1
	} else {
		set struct 0
	}

	set g_browserIdToMpe($node) $mpe
	if {$size == "()"} {
		set size 0
	}
	if {$start == "()"} {
		set start 0
	}
	if {$end == "()"} {
		set end 0
	}

	if {$size == ""} {
		set size 0
	}
	if {$start == ""} {
		set start 0
	}
	if {$end == ""} {
		set end 0
	}


	set id $node
	set x [string first "-" $id]
	if {$x > 1 } {
		incr x -1
		set id [string range $id 0 $x]

	}
#tk_messageBox -message "id=$id"
	if {$id == $g_globalBrowserId($mpe) || ($g_nShowRegisters($mpe) == "Show Variables" && $parent != "root")} {
		if {0 && [string range $name 0 0] == "\["} {
			if {$name == "\[0\]"} {
				set i 1
				if {$id == $g_globalBrowserId($mpe)} {
					hierlist_add_child $mpe .globalvars.varFrame$mpe.browser $parent $node $name $addr $value $struct 
				} else {
					hierlist_add_child $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $parent $node $name $addr $value $struct 
					while {$i < $g_browserArrayIndex} {		
						set name $g_browserArray($mpe-$i-name)
						set addr $g_browserArray($mpe-$i-addr)
						set parent $g_browserArray($mpe-$i-parent)
						set node $g_browserArray($mpe-$i-node)
						set value $g_browserArray($mpe-$i-value)
						set open $g_browserArray($mpe-$i-open)
						set size $g_browserArray($mpe-$i-size)
						set start $g_browserArray($mpe-$i-start)
						set end $g_browserArray($mpe-$i-end)

						hierlist_add_child $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $parent $node $name $addr $value $struct $size $start $end

						unset g_browserArray($mpe-$i-name)
						unset g_browserArray($mpe-$i-addr)
						unset g_browserArray($mpe-$i-parent)
						unset g_browserArray($mpe-$i-node)
						unset g_browserArray($mpe-$i-value)
						unset g_browserArray($mpe-$i-open)
						unset g_browserArray($mpe-$i-start)
						unset g_browserArray($mpe-$i-end)
						unset g_browserArray($mpe-$i-size)

						incr i 1
					}
					set g_browserArrayIndex($mpe) 0
				}
			} else {
				set g_browserArray($mpe-$g_browserArrayIndex-name) $name
				set g_browserArray($mpe-$g_browserArrayIndex-addr) $addr
				set g_browserArray($mpe-$g_browserArrayIndex-parent) $parent
				set g_browserArray($mpe-$g_browserArrayIndex-node) $node
				set g_browserArray($mpe-$g_browserArrayIndex-value) $value
				set g_browserArray($mpe-$g_browserArrayIndex-open) $open
				set g_browserArray($mpe-$g_browserArrayIndex-start) $start
				set g_browserArray($mpe-$g_browserArrayIndex-end) $end
				set g_browserArray($mpe-$g_browserArrayIndex-size) $size
				incr g_browserArrayIndex($mpe) 1
			}
		} else {
			if {$id == $g_globalBrowserId($mpe)} {
				hierlist_add_child $mpe .globalvars.varFrame$mpe.browser $parent $node $name $addr $value $struct 
			} else {
				hierlist_add_child $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $parent $node $name $addr $value $struct $size $start $end
			}
		}
	}
	if {$parent == "root"} { 
		set g_browserVarsName($name-$mpe) $name
		set g_browserVarsAddr($name-$mpe) $addr
		set g_browserVarsParent($name-$mpe) $parent
		set g_browserVarsNode($name-$mpe) $node
		set g_browserVarsValue($name-$mpe) $value
		set g_browserVarsStruct($name-$mpe) $struct
		set g_browserVarsSize($name-$mpe) $size
		set g_browserVarsStart($name-$mpe) $start
		set g_browserVarsEnd($name-$mpe) $end
		set g_browserNeedsUpdate($mpe) 1
	}

}

proc varBrowse { mpe p} {
global g_varString
global g_nShowRegisters 
global g_varStringCopy
global g_browserVarsName
global g_browserVarsAddr
global g_browserVarsParent
global g_browserVarsNode
global g_browserVarsValue
global g_browserVarsStruct
global g_browserVarsSize
global g_browserVarsStart
global g_browserVarsEnd
global g_browserNeedsUpdate
global varValues

	if {![winfo exists .mpe$mpe+Top]} {
		return
	}
	if {$g_nShowRegisters($mpe) != "Show Variables"} {
		return
	}
	if {[info exists g_browserVarsName] && $g_browserNeedsUpdate($mpe)} {
		foreach {key value} [array get g_browserVarsName] {
			regexp {(.*)-([0-9])} $key match varName mpeNum
			if {$mpe == $mpeNum} {
				lappend nameList $varName
			}
		}
		if {[info exists nameList]} {
			set nameList [lsort -dictionary -decreasing $nameList]
			foreach key $nameList {

				set name $key
				set addr $g_browserVarsAddr($key-$mpe) 
				set parent $g_browserVarsParent($key-$mpe) 
				set node   $g_browserVarsNode($key-$mpe)
				set value  $g_browserVarsValue($key-$mpe)
				set struct $g_browserVarsStruct($key-$mpe)
				set size $g_browserVarsSize($key-$mpe)
				set start $g_browserVarsStart($key-$mpe)
				set end $g_browserVarsEnd($key-$mpe)

	
				if {[hierlist_node_query $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $node] == 0} {
					hierlist_add_child $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $parent $node $name $addr $value $struct $size $start $end
				} else {
					hierlist_update_node $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $node $value
				}
			}
			set g_browserNeedsUpdate($mpe) 0
		}
	} 
	return

}

# This one is just used for going back between disassembly and C.
# It clears the stuff out of the browser, but not out of the internal array
# Question: what happens if we jump to another function, and varBrowserClear gets called?
proc varBrowseInternalClear { mpe p } {
global g_browserVarsName
global g_browserVarsNode
global g_browserNeedsUpdate
global varValues
	if {![winfo exists .mpe$mpe+Top]} {
		return
	}
	if [winfo exists .mpe$mpe+Top.regFrame.innerFrame.browser] {
		hierlist_delete_children $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $p
	}
}

proc varBrowseClear { mpe p } {
global g_browserVarsName
global g_browserVarsNode
global g_browserNeedsUpdate

	if {![winfo exists .mpe$mpe+Top]} {
		return
	}
	if {[info exists g_browserVarsName] && $g_browserNeedsUpdate($mpe) != 1} {
		if [winfo exists .mpe$mpe+Top.regFrame.innerFrame.browser] {
			hierlist_delete_children $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $p
		}
	}

	if {[info exists g_browserVarsName] && $g_browserNeedsUpdate($mpe) != 1} {
		foreach {key value} [array get g_browserVarsName] {
			regexp {(.*)-([0-9])} $key match varName mpeNum
			if {$mpe == $mpeNum} {			
				set node   $g_browserVarsNode($key)
					unset g_browserVarsName($key)
			}
		}
	}
}

proc varBrowseUpdate { mpe p v } {
global g_varString
global g_nShowRegisters 
global g_globalBrowserId


#	tk_messageBox -message "browser update $p $v"

	if {![winfo exists .mpe$mpe+Top]} {
		return
	}
	set id $p
	set x [string first "-" $id]
	if {$x > 1 } {
		incr x -1
		set id [string range $id 0 $x]

	}
	if {$id == $g_globalBrowserId($mpe)} {
		hierlist_update_node $mpe .globalvars.varFrame$mpe.browser $p $v
		return
	}
	if {$g_nShowRegisters($mpe) == "Show Registers"} {
		return
	}

	hierlist_update_node $mpe .mpe$mpe+Top.regFrame.innerFrame.browser $p $v

}


proc varBrowseRemove { mpe p } {
global g_varString
global g_nShowRegisters 
global g_globalBrowserId

#	tk_messageBox -message "browser remove $p"

	if {![winfo exists .mpe$mpe+Top]} {
		return
	}
	set id $p
	set x [string first "-" $id]
	if {$x > 1 } {
		incr x -1
		set id [string range $id 0 $x]

	}
	if {$id == $g_globalBrowserId($mpe)} {
		hierlist_delete_node .globalvars.varFrame$mpe.browser $p 
		return
	}
	if {$g_nShowRegisters($mpe) == "Show Registers"} {
		return
	}
	hierlist_delete_node .mpe$mpe+Top.regFrame.innerFrame.browser $p 

}
	

#####################################################################################################
# WATCH WINDOW

source_env "watch.tcl"

#####################################################################################################
#####################################################################################################


Window show .


vTclWindow.mmpWindow .mmp "Puffin2k - MMP" 20 20
vTclWindow.watchWindow .watchTop "Watch" 75 75

# wm protocol .watchTop WM_DELETE_WINDOW "wm iconify .watchTop"
wm protocol .xLispTk WM_DELETE_WINDOW "wm iconify .xLispTk"

createMPEWindow .mpe0+Top "#0 - MPE Debugger" 0 40 40
createMPEWindow .mpe1+Top "#1 - MPE Debugger" 1 60 60
createMPEWindow .mpe2+Top "#2 - MPE Debugger" 2 80 80
createMPEWindow .mpe3+Top "#3 - MPE Debugger" 3 100 100

# createGlobalBrowserWindow .globalVars "Global Variables" 0 40 120

#wm iconify .mpe0+Top
#wm iconify .mpe1+Top
#wm iconify .mpe2+Top
#wm iconify .mpe3+Top
#wm iconify .watchTop

set bWSPLoaded 0
global workspaceFile
if {[file exists "$workspaceFile"] != 1} {
	set fileId [open "$workspaceFile" w]
puts $fileId "(tcl \"wm geometry .mmp +5+21\")"
puts $fileId "(tcl \"wm deiconify .mmp\")"
puts $fileId "(tcl \"wm geometry .watchTop 640x100+75+75\")"
puts $fileId "(tcl \"wm iconify .watchTop\")"
puts $fileId "(tcl \"wm geometry .xLispTk 80x30+5+21\")"
puts $fileId "(tcl \"wm deiconify .xLispTk\")"
puts $fileId "(tcl \"wm geometry .mpe0+Top 760x944+5+21\")"
puts $fileId "(tcl \"wm deiconify .mpe0+Top\")"
puts $fileId "(tcl \"wm geometry .mpe1+Top 760x554+5+21\")"
puts $fileId "(tcl \"wm deiconify .mpe1+Top\")"
puts $fileId "(tcl \"wm geometry .mpe2+Top 760x554+5+21\")"
puts $fileId "(tcl \"wm deiconify .mpe2+Top\")"
puts $fileId "(tcl \"wm geometry .mpe3+Top 760x554+5+21\")"
puts $fileId "(tcl \"wm deiconify .mpe3+Top\")"
puts $fileId "(tcl \"set g_historyIndex 1\")"
puts $fileId "(tcl \"set g_historyDebugIndex 1\")"
puts $fileId "(tcl \"set g_globalBrowserGeom 400x320+40+40\")"
puts $fileId "(tcl \"set regGState(0General) 1\")"
puts $fileId "(tcl \"set regGState(0Bilinear) 1\")"
puts $fileId "(tcl \"set regGState(0MPE) 1\")"
puts $fileId "(tcl \"set regGState(0Interrupt) 1\")"
puts $fileId "(tcl \"set regGState(0DMA) 1\")"
puts $fileId "(tcl \"set regGState(0Commbus) 1\")"
puts $fileId "(tcl \"set regGState(0Special) 1\")"
puts $fileId "(tcl \"set regGState(1General) 1\")"
puts $fileId "(tcl \"set regGState(1Bilinear) 1\")"
puts $fileId "(tcl \"set regGState(1MPE) 1\")"
puts $fileId "(tcl \"set regGState(1Interrupt) 1\")"
puts $fileId "(tcl \"set regGState(1DMA) 1\")"
puts $fileId "(tcl \"set regGState(1Commbus) 1\")"
puts $fileId "(tcl \"set regGState(1Special) 1\")"
puts $fileId "(tcl \"set regGState(2General) 1\")"
puts $fileId "(tcl \"set regGState(2Bilinear) 1\")"
puts $fileId "(tcl \"set regGState(2MPE) 1\")"
puts $fileId "(tcl \"set regGState(2Interrupt) 1\")"
puts $fileId "(tcl \"set regGState(2DMA) 1\")"
puts $fileId "(tcl \"set regGState(2Commbus) 1\")"
puts $fileId "(tcl \"set regGState(2Special) 1\")"
puts $fileId "(tcl \"set regGState(3General) 1\")"
puts $fileId "(tcl \"set regGState(3Bilinear) 1\")"
puts $fileId "(tcl \"set regGState(3MPE) 1\")"
puts $fileId "(tcl \"set regGState(3Interrupt) 1\")"
puts $fileId "(tcl \"set regGState(3DMA) 1\")"
puts $fileId "(tcl \"set regGState(3Commbus) 1\")"
puts $fileId "(tcl \"set regGState(3Special) 1\")"

	close $fileId
}

if {[file exists "$workspaceFile"] == 1} {
	xlisp load "\"$env(HOME)/.puffin2k.dfl\""
	set bWSPLoaded 1
}



if {$bWSPLoaded == 1} {
	set i 1
	while { $i < $g_historyIndex} {
		set flabel $g_historyPath($i)	
		set file $g_historyPath($i)	
		set len [string length $flabel]
		if {$len > 18 } {
			set flabel [string range $flabel [expr $len - 18] $len]
		}
		set flabel "$i  ...$flabel"

		set mpe 0
		set type $g_historyType($i)
		foreach b {.mpe0+Top .mpe1+Top .mpe2+Top .mpe3+Top} {	
			if {[winfo exists $b]} {
				$b.menuBar.menuFile add command -underline 0 -label "$flabel" -command [list loadHistory $mpe $file $type]
			}
			incr mpe
		}
		incr i
	}

	set i 1
	while { $i < $g_historyDebugIndex} {
		set flabel $g_historyDebugPath($i)	
		set file $g_historyDebugPath($i)	
		set len [string length $flabel]
		if {$len > 18 } {
			set flabel [string range $flabel [expr $len - 18] $len]
		}
		set flabel "$i  ...$flabel"

		foreach b {.mmp } {	
			$b.menuBar.menuFile add command -underline 0 -label "$flabel" -command [list loadDebugHistory $file]
		}
		incr i
	}

	set i 0
	while {$i < 4} {
	set g_regFirstTime($i) 1
		foreach group {General Bilinear MPE Interrupt DMA Special Commbus } {	
			if {[winfo exists .mpe$i+Top]} {
				ToggleGroup $i .mpe$i+Top.regFrame.innerFrame.baseframe$i.registers $group
			}
		}
		set g_regFirstTime($i) 0
		incr i
	}

}

main $argc $argv


#tk_messageBox -message "Hello" 
#toplevel .mdi
#frame .mdi -width 800 -height 600
#pack .mdi 
#-expand yes -fill both
#update
#setparent . .mmp




