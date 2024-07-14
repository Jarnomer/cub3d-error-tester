#! /bin/bash

# Edit these values to match your project
# =========================================================
MYTEXDIR="textures/mandatory/"	#Path to textures
MYTEXNO="wall_north.png"		#North wall texture
MYTEXSO="wall_south.png"		#South wall texture
MYTEXWE="wall_west.png"			#West wall texture
MYTEXEA="wall_east.png"			#East wall texture
FILETYPE=.png					#Filetype of textures (xpm/png)
# =========================================================

R="\033[0;31m"	# Red
G="\033[0;32m"	# Green
Y="\033[0;33m"	# yellow
B="\033[0;34m"	# Blue
P="\033[0;35m"	# Purple
C="\033[0;36m"	# Cyan

RB="\033[1;31m"	# Bold
GB="\033[1;32m"
YB="\033[1;33m"
BB="\033[1;34m"
PB="\033[1;35m"
CB="\033[1;36m"

RC="\033[0m" 	# Reset Color
FLL="========================="
FLLTITLE="========================"

print_test_description() {
	printf "\n${BB}TEST $1:${RC} ${C}$2${RC}    \t"
	CNTR=$((CNTR+1))
}

print_test_header() {
	printf "\033c" #clear terminal
	printf "\n${BB}$1${RC}\n"
	printf "${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}\n"
	printf "TEST\tDESC\t\t\tEXITCODE\tSTDERR\t\tMESSAGE\n"
	printf "${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
}

print_main_title() {
	printf "\033c" #clear terminal
	printf "\n${CB}CUB3D:  \tERROR HANDLING TESTER${RC}\n"
	printf "${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}\n"
	printf "\n${BB}EXITCODE:\t${RC}Tests that exitcode is not zero, indicating error\n"
	printf "\n${BB}STDERR:  \t${RC}Tests that error message was written to stderr\n"
	printf "\n${BB}MESSAGE: \t${RC}Tests that error message included 'Error' and
\t\twas followed by your explicit error message\n\n"
	printf "${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}\n"
}

print_test_continue() {
	printf "\n${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
	printf "${GB}\nALL TESTS FINISHED!\n${RC}"
	echo
	read -p "Continue?" -n 1 -r
}

delete_test_files() {
	${RM} ${DIR} ${MAP} ${LOG}
	${RM} ${MYTEXDIR}${TEX}
	${RM} ${MYTEXDIR}${TEX}${FILETYPE}
}

trap handle_ctrlc SIGINT
handle_ctrlc() {
	delete_test_files
	exit
}

message_checker() {
	MSG=$(head -1 < ${LOG})
	CNT=$(wc -l < ${LOG})
	CHK=0
	if [[ $MSG == *"$ERR"* ]]; then
		CHK=$((CHK+1))
	fi
	if [ $CNT -gt 1 ]; then
		CHK=$((CHK+1))
	fi
	if [ $CHK -eq 2 ]; then
		printf "${GB}\t\t[OK]${RC}"
	else
		printf "${RB}\t\t[KO]${RC}"
	fi
}

stderr_checker() {
if [ ! -s "${LOG}" ]; then
	printf "${RB}\t\t[KO]${RC}"
else
	printf "${GB}\t\t[OK]${RC}"
fi
}

exitcode_checker() {
	if [ $1 -eq 139 ]; then
		printf "${YB}[SEGV]${RC}"
	elif [ $1 -eq 0 ]; then
		printf "${RB}[KO]${RC}"
	else
		printf "${GB}[OK]${RC}"
	fi
}

run_cubed() {
	${BINPATH}${NAME} ${MAP} > /dev/null 2> ${LOG}
	exitcode_checker $?
	stderr_checker
	message_checker
}

run_cubed_with_args() {
	${BINPATH}${NAME} $1 $2 > /dev/null 2> ${LOG}
	exitcode_checker $?
	stderr_checker
	message_checker
}

CNTR=1
ERR=Error
RM="rm -rf"
ECHO="echo -n"
NAME=cub3D
BINPATH=./
DIR=tmp_tst_dir
MAP=tmp_tst_map
TEX=tmp_tst_tex
LOG=errtest.log

if [ -f "$NAME" ]; then
	print_main_title
	print_test_continue
else
	printf "${RB}Error: ${RC}${Y}binary <$NAME> not found${RC}"
	exit
fi

# =========================================================
# FILE READ TESTS
# =========================================================

print_test_header "FILE READ TESTS"
${ECHO} 'NO '${MYTEXDIR}${MYTEXNO}'
SO '${MYTEXDIR}${MYTEXSO}'
WE '${MYTEXDIR}${MYTEXWE}'
EA '${MYTEXDIR}${MYTEXEA}'

F 220,100,0
C 225,30,0

111
1N1
111' > ${MAP}

print_test_description ${CNTR} "Too few arguments"
run_cubed_with_args "" ""

print_test_description ${CNTR} "Too many arguments"
run_cubed_with_args ${MAP} ${MAP}

print_test_description ${CNTR} "Argument is folder"
mkdir $DIR.cub
run_cubed_with_args ${BINPATH}${DIR}.cub ""
${RM} $DIR.cub

print_test_description ${CNTR} "File does not exist"
run_cubed_with_args .... ""

print_test_description ${CNTR} "File has no name"
mv ${MAP} .cub
run_cubed_with_args ${BINPATH}.cub ""
mv .cub ${MAP}

print_test_description ${CNTR} "No file extension"
run_cubed_with_args ${MAP} ""

print_test_description ${CNTR} "Bad file extension"
mv ${MAP} ${MAP}.cubb
run_cubed_with_args ${MAP}.cubb ""
mv ${MAP}.cubb ${MAP}

print_test_description ${CNTR} "Bad file extension"
mv ${MAP} ${MAP}.ccub
run_cubed_with_args ${MAP}.ccub ""
mv ${MAP}.ccub ${MAP}

mv ${MAP} ${MAP}.cub
MAP=$(eval ${ECHO} ${MAP}.cub)
print_test_description ${CNTR} "No read permission"
chmod -r ${MAP}
run_cubed
chmod +r ${MAP}

print_test_description ${CNTR} "File is empty"
${ECHO} '' > ${MAP}
run_cubed

delete_test_files
print_test_continue

# =========================================================
# TEXTURE PARSING TESTS
# =========================================================

print_test_header "TEXTURE PARSING TESTS"
cp ${MYTEXDIR}${MYTEXNO} ${MYTEXDIR}${TEX}
CNTR=1

texture_test() {
${ECHO} ''$1'
SO '${MYTEXDIR}${MYTEXSO}'
WE '${MYTEXDIR}${MYTEXWE}'
EA '${MYTEXDIR}${MYTEXEA}'

F 225,30,0
C 225,30,0

111
1N1
111' > ${MAP}
run_cubed
}

print_test_description ${CNTR} "File is folder"
mkdir ${MYTEXDIR}${DIR}${FILETYPE}
texture_test "NO ${MYTEXDIR}${DIR}${FILETYPE}"
${RM} ${MYTEXDIR}${DIR}${FILETYPE}

print_test_description ${CNTR} "File does not exist"
texture_test "NO ${MYTEXDIR}...."

print_test_description ${CNTR} "File has no name"
mv ${MYTEXDIR}${TEX} ${MYTEXDIR}${FILETYPE}
texture_test "NO ${MYTEXDIR}${FILETYPE}"
mv ${MYTEXDIR}${FILETYPE} ${MYTEXDIR}${TEX}

print_test_description ${CNTR} "No file extension"
texture_test "NO ${MYTEXDIR}${TEX}"

print_test_description ${CNTR} "Bad file extension"
mv ${MYTEXDIR}${TEX} ${MYTEXDIR}${TEX}${FILETYPE}_
texture_test "NO ${MYTEXDIR}${TEX}${FILETYPE}_"
mv ${MYTEXDIR}${TEX}${FILETYPE}_ ${MYTEXDIR}${TEX}

print_test_description ${CNTR} "No read permission"
mv ${MYTEXDIR}${TEX} ${MYTEXDIR}${TEX}${FILETYPE}
chmod -r ${MYTEXDIR}${TEX}${FILETYPE}
texture_test "NO ${MYTEXDIR}${TEX}${FILETYPE}"
chmod +r ${MYTEXDIR}${TEX}${FILETYPE}

print_test_description ${CNTR} "Invalid separator"
texture_test "NO_ ${MYTEXDIR}${MYTEXNO}"

print_test_description ${CNTR} "Invalid identifier"
texture_test "No ${MYTEXDIR}${MYTEXNO}"

print_test_description ${CNTR} "Same element twice"
texture_test "SO ${MYTEXDIR}${MYTEXSO}"

print_test_description ${CNTR} "Missing element"
texture_test ""

delete_test_files
print_test_continue

# =========================================================
# COLOR PARSING TESTS
# =========================================================

color_test() {
${ECHO} 'NO '${MYTEXDIR}${MYTEXNO}'
SO '${MYTEXDIR}${MYTEXSO}'
WE '${MYTEXDIR}${MYTEXWE}'
EA '${MYTEXDIR}${MYTEXEA}'

C 225,30,0
'$1'

111
1N1
111' > ${MAP}
run_cubed
}

print_test_header "COLOR PARSING TESTS"
CNTR=1

print_test_description ${CNTR} "Too few values"
color_test "F 225,30"

print_test_description ${CNTR} "Too many values"
color_test "F 225,30,1,1"

print_test_description ${CNTR} "Invalid value"
color_test "F 225,30,256"

print_test_description ${CNTR} "Invalid value"
color_test "F 225,30,-0"

print_test_description ${CNTR} "Invalid value"
color_test "F _225,30,0"

print_test_description ${CNTR} "Extra comma	"
color_test "F 225,30,,0"

print_test_description ${CNTR} "Extra comma	"
color_test "F 225,30,0,"

print_test_description ${CNTR} "Invalid separator"
color_test "F_ 225,30,0"

print_test_description ${CNTR} "Invalid identifier"
color_test "f 225,30,0"

print_test_description ${CNTR} "Same element twice"
color_test "C 225,30,0"

print_test_description ${CNTR} "Missing element"
color_test ""

delete_test_files
print_test_continue

# =========================================================
# MAP PARSING TESTS
# =========================================================

insert_map_elements() {
${ECHO} 'NO '${MYTEXDIR}${MYTEXNO}'
SO '${MYTEXDIR}${MYTEXSO}'
WE '${MYTEXDIR}${MYTEXWE}'
EA '${MYTEXDIR}${MYTEXEA}'

F 225,30,0
C 225,30,0
' > ${MAP}
}

misc_test() {
insert_map_elements
${ECHO} '
'$1'
'$2'
'$3'
'$4'' >> ${MAP}
run_cubed
}

map_test() {
insert_map_elements
${ECHO} '
1    1         1 1      1
        11111
        110011111111111111111111'$3'
        1000000000110000000000001
        1011001001110000000011111
        1001001000000'$1'0000001    
111111111011001001110000000011111
100000000011000001110111111011111
'$7'1110111111111011100000010001
11110111111111011101010010001
110000001101010111000000100011'$4'1111
100000000'$2'00000000000000100011111
10000000000000001101010010001
1100011111101111111011110001'$5'
110001   1100111 101111010001
111111   1111111 111'$6'11111111
1
1
1' >> ${MAP}
run_cubed
}

print_test_header "MAP PARSING TESTS"
CNTR=1

print_test_description ${CNTR} "Invalid dimension"
#          $1   $2   $3   $4
misc_test '11' 'N1' '11' '11'

print_test_description ${CNTR} "Invalid dimension"
misc_test '' '' '1111' '11N1'

print_test_description ${CNTR} "Invalid dimension"
misc_test '' '' '1' ''

print_test_description ${CNTR} "Empty line	"
misc_test '111' '1S1' '' '111'

print_test_description ${CNTR} "No map exists"
misc_test '' '' '' ''

print_test_description ${CNTR} "No player	"
#        $1  $2  $3  $4  $5  $6  $7
map_test '0' '0' '1' '1' '1' '1' '1'

print_test_description ${CNTR} "Two players	"
map_test 'S' 'N' '1' '1' '1' '1' '1'

print_test_description ${CNTR} "Invalid character"
map_test 's' '0' '1' '1' '1' '1' '1'

print_test_description ${CNTR} "Invalid character"
map_test 'S' '2' '1' '1' '1' '1' '1'

print_test_description ${CNTR} "No closed walls"
map_test 'S' '0' '0' '1' '1' '1' '1'

print_test_description ${CNTR} "No closed walls"
map_test 'S' '0' '1' '0' '1' '1' '1'

print_test_description ${CNTR} "No closed walls"
map_test 'S' '0' '1' '1' '0' '1' '1'

print_test_description ${CNTR} "No closed walls"
map_test 'S' '0' '1' '1' '1' '0' '1'

print_test_description ${CNTR} "No closed walls"
map_test 'S' '0' '1' '1' '1' '1' '0'

delete_test_files
printf "\n${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
printf "${GB}\nALL TESTS FINISHED!\n${RC}"
