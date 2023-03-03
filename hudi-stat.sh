#!/bin/bash
path=$1
shift
table=$(basename $path)
sections=$@

for section in $sections; do
    echo
    echo "[ ${section^^} ]"
    echo
    if [[ "$section" == "storage" ]]; then
        # show file layout from local with tree cli
        aws s3 sync --delete $path /tmp/$table --exclude "*$" --exclude ".hoodie/*" --exclude "*/.hoodie*" &>/dev/null
        tree --du -ahs -D --timefmt '%T' /tmp/$table
    else
        # make hudi-cli scripts and execute
        echo "connect --path $path" > /tmp/hudi-cli-scripts
        case $section in
            timeline)
                echo "timeline show active" >> /tmp/hudi-cli-scripts
            ;;
            compactions)
                echo "compactions show all" >> /tmp/hudi-cli-scripts
            ;;
            commits)
                echo "commits show" >> /tmp/hudi-cli-scripts
            ;;
        esac
        # for hudi-cli, only script mode can exit automatically
        hudi-cli script /tmp/hudi-cli-scripts 2>/dev/null | grep -o -e '^[╔].*\|^[║].*\|^[╠].*\|^[╟].*\|^[╚].*'
    fi
done