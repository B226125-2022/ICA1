#!/bin/bash

# iterate()
# {

# }

TCO_FILE="fastq/Tco.fqfiles"

LINES="$(awk 'NR>1' $TCO_FILE)"
# echo "$lines"

DELIMITER=" "

get_grouped_items()
{
    while read line; do
        # echo "$line"
        line_name="$(cut -d " " -f 1 <<< $line)"
        line_sample_type="$(cut -d " " -f 2 <<< $line)"
        line_time="$(cut -d " " -f 4 <<< $line)"
        line_induction="$(cut -d " " -f 5 <<< $line)"
        # echo "$line_name $line_sample_type $line_time $line_induction"

        for sampletype in WT Clone1 Clone2; do
            for time in "0" "24" "48"; do
                for induction in Uninduced Induced; do
                    if [[ $line_sample_type == $sampletype ]] && [[ $line_time == $time ]] && [[ $line_induction == $induction ]]; then
                        echo "$line_name $line_sample_type $line_time $line_induction"
                        tco_line_num="$(grep -n $line_name $TCO_FILE | cut -d ':' -f 1)"
                        echo "$tco_line_num	$line_name" >> "$line_sample_type-$line_time-$line_induction.txt"
                        # trailing newline so the file can be read correctly
                        # echo "" >> "$line_sample_type-$line_time-$line_induction.txt"
                    fi
                done
            done
        done
    done <<< "$LINES"
}

get_grouped_items