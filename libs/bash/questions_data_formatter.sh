#! /bin/bash 

# Check if a questionFilename argument is provided
if [ $# -eq 0 ]; then
    echo "No questionFilename provided"
    exit 1
fi
# Check if an answersFilename argument is provided
if [ $# -eq 1 ]; then
    echo "No answersFilename provided"
    exit 1
fi
# Check if an outputFilename argument is provided
if [ $# -eq 2 ]; then
    outputFilename=$(date +%s%3N)
    echo "No outputFilename provided defaulting to $outputFilename ms"
else
    outputFilename="$3"
fi

echo "outputFilename: $outputFilename.json"

questionFilename="$1"
answersFilename="$2"

# This indicates the pattern for dividing the questions into groups.
questionDivider=6
questionNumberInFileLine=1
questionOuterArray=()

format_questions() {
    if [ -e "$questionFilename" ]; then 
        IFS=$'\n' read -d '' -r -a content < "$questionFilename"
        local questionInnerArray=()
        local choices=()
        for ((i = 0; i < ${#content[@]}; i++)); do
            local currentNumber=$((i+1))
            local divisibleByQuestionDivider=$((currentNumber%questionDivider))
            local percentage=$((currentNumber*100/${#content[@]}))
            echo -ne "\033[1G" # Move to the beginning of the line
            echo -ne "Processing: "
            echo -ne "$percentage%\033[0K"

            if [ $divisibleByQuestionDivider -eq 0 ]; then
                # local reference="\"reference\": \"${content[$i]}\""
                local choicesJoined=$(IFS=, ; echo "${choices[*]}")
                local index=$((($currentNumber/$questionDivider)*2))
                local answers=($(format_answers "$answersFilename" "$index"))
                local correctAnswer="\"correctAnswer\": {\"answer\": ${choices[${answers[0]}]},\"explanation\": \"${answers[@]:1}\"}"
                questionOuterArray+=("{\"choices\": [$choicesJoined], $correctAnswer, \"question\": \"${questionInnerArray[@]}\", \"reference\": \"${content[$i]}\"},")
                questionInnerArray=()
                choices=()
            elif [ $divisibleByQuestionDivider -eq $questionNumberInFileLine ]; then
                local removeNumberingWithRegEx=$(echo "${content[$i]}" | sed 's/^\s*\([0-9]\+\)\.\s*//; s/\s*$//')
                questionInnerArray+=("${removeNumberingWithRegEx}")
            else
                local removeLetteringWithRegEx=$(echo "${content[$i]}" | sed 's/^\s*\([A-Z]\)\.\s*//; s/\s*$//')
                choices+=("\"${removeLetteringWithRegEx}\"")
            fi
        done
        echo "${questionOuterArray[@]}" > "$outputFilename.json"
    fi
}

format_answers() {
    local alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    
    if [ -e "$answersFilename" ]; then 
        IFS=$'\n' read -d '' -r -a content < "$answersFilename"
        local choice=${content[$(($index-1))]}
        local indexOfChoice=$(expr index "$alphabet" "$choice")
        local answers=("$(echo $(($indexOfChoice-1)))" "${content[$index]}")
        echo "${answers[@]}"
    fi
}

format_questions "$questionFilename"