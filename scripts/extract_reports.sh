REPORT_PATH=$1

util_reports=$(ls $REPORT_PATH/utilization_summary_*)
time_reports=$(ls $REPORT_PATH/timing_summary_*)
powr_reports=$(ls $REPORT_PATH/power_summary_*)


echo Part,Word,POSIT,LUTS,TOTAL_LUTS,PERC_LUTS,REGS,TOTAL_REGS,PERC_REGS > utilization_summary.txt
for report in ${util_reports[*]}; do
    #Remove extension
    report_="${report%.*}"


    # Extract report parameters
    word=$(echo $report_ | awk -F_ '$0=$3')
    posit=$(echo $report_ | awk -F_ '$0=$4')

    # Get file content
    content=$(cat $report)

    # Get report part name
    part_name_string=$(grep "Device" <<< "$content")
    part_name=$(echo $part_name_string | awk -F: '$0=$2')

    # Get utilization

    luts=$(grep "Slice LUTs*" <<< "$content")
    regs=$(grep "Slice Registers" <<< "$content")
    luts_val=$(echo $luts | awk -F'|' '{print $3","$6","$7}' )
    regs_val=$(echo $regs | awk -F'|' '{print $3","$6","$7}' )

    echo $part_name,$word,$posit,$luts_val,$regs_val >> utilization_summary.txt
done


echo Word,POSIT,clock,frequency,slack  > timing_summary.txt
for report in ${time_reports[*]}; do
    #Remove extension
    report_="${report%.*}"

    # Extract report parameters
    word=$(echo $report_ | awk -F_ '$0=$3')
    posit=$(echo $report_ | awk -F_ '$0=$4')

    # Get file content
    content=$(cat $report)
    
    # Get Timing
    clock=$(grep -m1 clk <<< "$content")
    full_wns=$(grep -m1 -A2 "WNS(ns)" <<< "$content")
    dirty_wns=$(grep -v "WNS(ns)" <<< "$full_wns")
    wns=$(grep -v "\-\-\-" <<< "$dirty_wns")

    clock_val=$(echo $clock | awk -F' ' '{print $4 "," $5 }' )
    wns_val=$(echo $wns   | awk -F' ' '{print $1}')    
    
    echo $word,$posit,$clock_val,$wns_val >> timing_summary.txt
done


echo Word,POSIT,total_pwr,dyna_pwr,static_pwr  > power_summary.txt
for report in ${powr_reports[*]}; do
    #Remove extension
    report_="${report%.*}"

    # Extract report parameters
    word=$(echo $report_ | awk -F_ '$0=$3')
    posit=$(echo $report_ | awk -F_ '$0=$4')

    # Get file content
    content=$(cat $report)
    
    # Get Timing
    total_pwr=$(grep "Total On-Chip Power (W)" <<< "$content")
    dyna_pwr=$(grep "Dynamic (W)" <<< "$content")
    static_pwr=$(grep "Device Static (W)" <<< "$content")
  
    total_pwr_val=$(echo $total_pwr | awk -F'|' '{print $3}' )
    dyna_pwr_val=$(echo $dyna_pwr | awk -F'|' '{print $3}' )
    static_pwr_val=$(echo $static_pwr | awk -F'|' '{print $3}' )

    echo $word,$posit,$total_pwr_val,$dyna_pwr_val,$static_pwr_val >> power_summary.txt
done

