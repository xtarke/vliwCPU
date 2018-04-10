WCET_BIN=../../bin/wcet
CPU_BIN=../../cpu/bin/cpu

exit_error() {
    echo "Fatak Error: $* (status $?)" 1>&2
    exit 1
}

if [ -f wcet.csv ]; then 
    rm wcet.csv 
fi

if [ -f sim.csv ]; then 
    rm sim.csv 
fi

if [ -f result.csv ]; then 
    rm result.csv 
fi

for file in *.o; do
    echo Analyzing $file
    echo -e "\tWCET"
    $WCET_BIN -a ${file%.*o} >> wcet.csv 2> /dev/null || exit_error "$WCET_BIN"
    echo -e "\tSIM"
    $CPU_BIN --file ${file%.*o}.bin --quiet >> sim.csv 2> /dev/null || exit_error "$CPU_BIN"
done

$CPU_BIN --info >> result.csv 2> /dev/null
echo -e "" >> result.csv
echo -e "wcet:" >> result.csv
cat wcet.csv >> result.csv
echo -e "" >> result.csv
echo -e "sim:" >> result.csv
cat sim.csv >> result.csv
