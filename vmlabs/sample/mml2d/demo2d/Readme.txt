
The 2D Menu
===========

This document describes the format of the input parameters
and the joystick buttons used to change their values:

NOTE: Parameters which are displayed in BLACK have NO EFFECT on the display.

                Format          Joystick Control Button
                ------          -----------------------
Main Menu
=========
Navigation                      Up & Down, C (Up & Down)
Selection                       A
Exit                            Start

Line
====
Line Type       m2dLineKind     A
Fix Aspect      boolean         B
ColorBlend1     uint8           C (Left & Right)
ColorBlend2     uint8           C (Up & Down)
Alpha           uint32          Left & Right
Width           uint16          Up & Down
RandomArray[4]	int32           L & R
Exit                            Start

Polyline
========
Line Type		m2dLineKind		A
Fix Aspect		boolean			B
xCenter			int16			C (Left & Right)	
yCenter			int16			C (Up & Down)
xScale			2.8	            Left & Right
yScale			2.8             Up & Down
EscapeCode		uint32			L
Angle			16.16			Analog Stick
Exit                            Start

Ellipse
=======
Clut			                Z + A
Radius          int16           L & R
Fix Aspect      boolean         B
xCenter         int16           C (Left & Right)
yCenter         int16           C (Up & Down)
xScale          8.8             Left & Right
yScale          8.8             Up & Down
Borderwidth     uint16          Z + C (Left & Right)
Alpha           uint32          Z + C (Up & Down)
Fill            int32           A
Exit                            Start

Composite
=========
Clut			                Z + A
Exit                            Start
	