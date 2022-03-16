set tmpdir $::env(PATH)
puts $tmpdir

# Auto added signals
set filterKeyword "monitor"
set filterCondition ","
set minTime "1ms"
set maxTime "1s"

set monitorSignals [list]
set index -1
set nfacs [ gtkwave::getNumFacs ]

# Auto added signals
for {set i 0} {$i < $nfacs } {incr i} {
    set facname [ gtkwave::getFacName $i ]
    set index [ string first $filterKeyword $facname  ]
    set index2 [ string first $filterCondition $facname  ]
    
    if {$index != -1 && $index2 == -1} {
    	lappend monitorSignals "$facname"
	}
}

# Ditch all signals
gtkwave::/Edit/Highlight_All
gtkwave::/Edit/Cut
gtkwave::setFromEntry $minTime
gtkwave::setToEntry $maxTime
gtkwave::/Time/Zoom/Zoom_Best_Fit

# Add signals
set filter [list led.blue led.green led.red msp430.port_out5\[7:0\] msp430.intr_num\[7:0\] msp430.intr_gie ]
gtkwave::addSignalsFromList $filter
gtkwave::addSignalsFromList $monitorSignals
# Convert monitor signals
gtkwave::highlightSignalsFromList $monitorSignals
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/UnHighlight_All

# expand specific signals
gtkwave::highlightSignalsFromList "msp430.port_out5\[7:0\]"
gtkwave::/Edit/Expand
gtkwave::deleteSignalsFromList [list msp430.port_out5\[3\] msp430.port_out5\[7\]]
gtkwave::highlightSignalsFromList "msp430.intr_num\[7:0\]"
gtkwave::/Edit/Expand
gtkwave::deleteSignalsFromList [list msp430.intr_num\[7\] msp430.intr_num\[6\] msp430.intr_num\[5\] msp430.intr_num\[4\] msp430.intr_num\[3\] msp430.intr_num\[2\] msp430.intr_num\[0\]]

# introduce blanks
gtkwave::highlightSignalsFromList "led.red"
gtkwave::/Edit/Insert_Blank
gtkwave::highlightSignalsFromList "msp430.intr_num\[1\]"
gtkwave::/Edit/Insert_Blank
gtkwave::/Edit/UnHighlight_All
# gtkwave::unhighlightSignalsFromList "led.red msp430.intr_num\[1\]"

# rename to aliases
gtkwave::highlightSignalsFromList "msp430.port_out5\[4\]"
gtkwave::/Edit/Alias_Highlighted_Trace red
gtkwave::highlightSignalsFromList "msp430.port_out5\[2\]"
gtkwave::/Edit/Alias_Highlighted_Trace white
gtkwave::highlightSignalsFromList "msp430.port_out5\[5\]"
gtkwave::/Edit/Alias_Highlighted_Trace green
gtkwave::highlightSignalsFromList "msp430.port_out5\[1\]"
gtkwave::/Edit/Alias_Highlighted_Trace brown
gtkwave::highlightSignalsFromList "msp430.port_out5\[0\]"
gtkwave::/Edit/Alias_Highlighted_Trace purple
gtkwave::highlightSignalsFromList "msp430.port_out5\[6\]"
gtkwave::/Edit/Alias_Highlighted_Trace blue

gtkwave::highlightSignalsFromList "led.red"
gtkwave::/Edit/Data_Format/Invert/On
gtkwave::highlightSignalsFromList "led.green"
gtkwave::/Edit/Data_Format/Invert/On
gtkwave::highlightSignalsFromList "led.blue"
gtkwave::/Edit/Data_Format/Invert/On
gtkwave::unhighlightSignalsFromList $filter

# Add port_out4, highlight and expand
set timecount [list msp430.port_out4\[7:0\]]
gtkwave::addSignalsFromList $timecount
gtkwave::highlightSignalsFromList $timecount
gtkwave::/Edit/Expand

# Start looking after this value
set startingTime "1ms"
puts "Starting from marker point 1ms we will measure the amount of micros between each EVEN edge. Please take care that the initial marker must be placed in a 0 position to measure the 1 periods."

# Define loop
proc loopSignal {index} {
    gtkwave::highlightSignalsFromList "msp430.port_out4\[$index\]"
    gtkwave::setMarker startingTime

    set newmarker 1
    set marker 0
    set cumsum 0

    while {$newmarker > $marker} {
        # Start find
        set newmarker [ gtkwave::findNextEdge ]
        set marker $newmarker
        # Stop find
        set newmarker [ gtkwave::findNextEdge ]

        # Calculate difference and convert to (us) to avoid overflow
        set diff [expr {$newmarker - $marker}]
        set diff [expr {$diff / 1000}]
        incr cumsum $diff

        # Useful for debugging the intermediate values that contribute to the sum        
        # puts [format "%s %s %s %s %s %s - %s %s" "M1" $marker "M2" $newmarker "Diff" $diff "sum" $cumsum]

        # Error case
        if {$diff > 15000} {
            puts "Pausing because diff > 10000 micros. Press enter to advance to next edge and start debugging."
            puts [format "%s %s %s %s %s %s" "M1" $marker "M2" $newmarker "Diff" $diff]
            gets stdin someVar
            break
        }
    }

    # Make sure each highlight is cancelled
    gtkwave::unhighlightSignalsFromList "msp430.port_out4\[$index\]"
    return $cumsum
}

# Measure up-time on each signal of port_out4
puts "Sum total amount of the time signal pin is HIGH"
puts "Signal port_out4 index 0"
set time_intrpt [loopSignal 0]
puts $time_intrpt
puts "Signal port_out4 index 1"
set time_sched [loopSignal 1]
puts $time_sched

# Define your sum here
puts [format "%s %s - %s %s - %s %s" "Total overhead (pin 0+1)" [expr {$time_intrpt + $time_sched}] "Interrupt" $time_intrpt "Scheduler" $time_sched]

puts "Signal port_out4 index 2"
puts [loopSignal 2]
puts "Signal port_out4 index 3"
puts [loopSignal 3]
puts "Signal port_out4 index 4"
puts [loopSignal 4]
puts "Signal port_out4 index 5"
puts [loopSignal 5]
puts "Signal port_out4 index 6"
puts [loopSignal 6]
puts "Signal port_out4 index 7"
puts [loopSignal 7]



puts "Good luck on the lab! D.Zwart and D. Offerhaus"
