#! /bin/bash

# Edit these values to match your project
# =========================================================
MYTEXDIR="textures/mandatory/"	#Path to textures
MYTEXNO="wall_north.png"		#North wall texture
MYTEXSO="wall_south.png"		#South wall texture
MYTEXWE="wall_west.png"			#West wall texture
MYTEXEA="wall_east.png"			#East wall texture
FILETYPE=.png					#Filetype of textures (xmp/png)
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

print_title() {
	printf "\n${BB}TEST $1:${RC} ${C}$2${RC}    \t"
	CNTR=$((CNTR+1))
}

print_header() {
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

print_continue() {
	echo
	read -p "Continue?" -n 1 -r
}

print_end() {
	printf "\n${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
	printf "${GB}\nALL TESTS FINISHED!\n${RC}"
	print_continue
}

delete_test_files() {
	${RM} ${DIR} ${MAP} ${LOG}
	${RM} ${MYTEXDIR}${TEX} ${MYTEXDIR}${TEX}${FILETYPE}
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

insert_map_elements() {
${ECHO} 'NO '${MYTEXDIR}${MYTEXNO}'
SO '${MYTEXDIR}${MYTEXSO}'
WE '${MYTEXDIR}${MYTEXWE}'
EA '${MYTEXDIR}${MYTEXEA}'

F 225,30,0
C 225,30,0
' > ${MAP}
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
	touch ${MAP}
	print_main_title
	print_continue
else
	printf "${RB}Error: ${RC}${Y}binary <$NAME> not found${RC}"
	${RM} ${MAP} ${LOG}
	exit
fi

# =========================================================
# FILE READ TESTS
# =========================================================

print_header "FILE READ TESTS"
${ECHO} 'NO '${MYTEXDIR}${MYTEXNO}'
SO '${MYTEXDIR}${MYTEXSO}'
WE '${MYTEXDIR}${MYTEXWE}'
EA '${MYTEXDIR}${MYTEXEA}'

F 220,100,0
C 225,30,0

111
1N1
111' > ${MAP}

print_title ${CNTR} "Too few arguments"
${BINPATH}${NAME} > /dev/null 2> ${LOG}
exitcode_checker $?
stderr_checker
message_checker

print_title ${CNTR} "Too many arguments"
${BINPATH}${NAME} ${MAP} ${MAP} > /dev/null 2> ${LOG}
exitcode_checker $?
stderr_checker
message_checker

print_title ${CNTR} "Argument is folder"
mkdir $DIR.cub
${BINPATH}${NAME} ${BINPATH}${DIR}.cub > /dev/null 2> ${LOG}
exitcode_checker $?
stderr_checker
message_checker
${RM} $DIR.cub

print_title ${CNTR} "File does not exist"
${BINPATH}${NAME} .... > /dev/null 2> ${LOG}
exitcode_checker $?
stderr_checker
message_checker

print_title ${CNTR} "File has no name"
mv ${MAP} .cub
${BINPATH}${NAME} ${BINPATH}.cub > /dev/null 2> ${LOG}
exitcode_checker $?
stderr_checker
message_checker
mv .cub ${MAP}

print_title ${CNTR} "No file extension"
${BINPATH}${NAME} ${MAP} > /dev/null 2> ${LOG}
exitcode_checker $?
stderr_checker
message_checker

print_title ${CNTR} "Bad file extension"
mv ${MAP} ${MAP}.cubb
${BINPATH}${NAME} ${MAP}.cubb > /dev/null 2> ${LOG}
exitcode_checker $?
stderr_checker
message_checker
mv ${MAP}.cubb ${MAP}

print_title ${CNTR} "Bad file extension"
mv ${MAP} ${MAP}.ccub
${BINPATH}${NAME} ${MAP}.ccub > /dev/null 2> ${LOG}
exitcode_checker $?
stderr_checker
message_checker
mv ${MAP}.ccub ${MAP}

# Add .cub extension to test map for running other tests
mv ${MAP} ${MAP}.cub
MAP=$(eval ${ECHO} ${MAP}.cub)

print_title ${CNTR} "No read permission"
chmod -r ${MAP}
run_cubed
chmod +r ${MAP}

print_title ${CNTR} "File is empty"
${ECHO} '' > ${MAP}
run_cubed

delete_test_files
print_end

# =========================================================
# TEXTURE PARSING TESTS
# =========================================================

print_header "TEXTURE PARSING TESTS"
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
}

print_title ${CNTR} "File is folder"
mkdir ${MYTEXDIR}${DIR}${FILETYPE}
texture_test "NO ${MYTEXDIR}${DIR}.png"
run_cubed
${RM} ${MYTEXDIR}${DIR}${FILETYPE}

print_title ${CNTR} "File does not exist"
texture_test "NO ${MYTEXDIR}...."
run_cubed

print_title ${CNTR} "File has no name"
mv ${MYTEXDIR}${TEX} ${MYTEXDIR}${FILETYPE}
texture_test "NO ${MYTEXDIR}.png"
run_cubed
mv ${MYTEXDIR}${FILETYPE} ${MYTEXDIR}${TEX}

print_title ${CNTR} "No file extension"
texture_test "NO ${MYTEXDIR}${TEX}"
run_cubed

print_title ${CNTR} "Bad file extension"
mv ${MYTEXDIR}${TEX} ${MYTEXDIR}${TEX}${FILETYPE}_
texture_test "NO ${MYTEXDIR}${TEX}${FILETYPE}_"
run_cubed
mv ${MYTEXDIR}${TEX}${FILETYPE}_ ${MYTEXDIR}${TEX}

print_title ${CNTR} "No read permission"
mv ${MYTEXDIR}${TEX} ${MYTEXDIR}${TEX}${FILETYPE}
chmod -r ${MYTEXDIR}${TEX}${FILETYPE}
texture_test "NO ${MYTEXDIR}${TEX}${FILETYPE}"
run_cubed
chmod +r ${MYTEXDIR}${TEX}${FILETYPE}

print_title ${CNTR} "Invalid separator"
texture_test "NO_ ${MYTEXDIR}${MYTEXNO}"
run_cubed

print_title ${CNTR} "Invalid identifier"
texture_test "No ${MYTEXDIR}${MYTEXNO}"
run_cubed

print_title ${CNTR} "Same element twice"
texture_test "SO ${MYTEXDIR}${MYTEXSO}"
run_cubed

print_title ${CNTR} "Missing element"
texture_test ""
run_cubed

delete_test_files
print_end

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
}

print_header "COLOR PARSING TESTS"
CNTR=1

print_title ${CNTR} "Too few values"
color_test "F 225,30"
run_cubed

print_title ${CNTR} "Too many values"
color_test "F 225,30,1,1"
run_cubed

print_title ${CNTR} "Invalid value"
color_test "F 225,30,256"
run_cubed

print_title ${CNTR} "Invalid value"
color_test "F 225,30,-0"
run_cubed

print_title ${CNTR} "Invalid value"
color_test "F _225,30,0"
run_cubed

print_title ${CNTR} "Extra comma	"
color_test "F 225,30,,0"
run_cubed

print_title ${CNTR} "Extra comma	"
color_test "F 225,30,0,"
run_cubed

print_title ${CNTR} "Invalid separator"
color_test "F_ 225,30,0"
run_cubed

print_title ${CNTR} "Invalid identifier"
color_test "f 225,30,0"
run_cubed

print_title ${CNTR} "Same element twice"
color_test "C 225,30,0"
run_cubed

print_title ${CNTR} "Missing element"
color_test ""
run_cubed

delete_test_files
print_end

# =========================================================
# MAP PARSING TESTS
# =========================================================

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
}

misc_test() {
insert_map_elements
${ECHO} '
'$1'
'$2'
'$3'
'$4'' >> ${MAP}
}

print_header "MAP PARSING TESTS"
CNTR=1

print_title ${CNTR} "Invalid dimension"
#		   $1   $2   $3   $4
misc_test '11' '11' '11' '11'
run_cubed

print_title ${CNTR} "Invalid dimension"
misc_test '' '' '111111' '111111'
run_cubed

print_title ${CNTR} "Invalid dimension"
misc_test '' '' '1' ''
run_cubed

print_title ${CNTR} "Empty line	"
misc_test '111' '1S1' '' '111'
run_cubed

print_title ${CNTR} "No map exists"
misc_test '' '' '' ''
run_cubed

print_title ${CNTR} "No player	"
#		 $1  $2  $3  $4  $5  $6  $7
map_test '0' '0' '1' '1' '1' '1' '1'
run_cubed

print_title ${CNTR} "Two players	"
map_test 'S' 'N' '1' '1' '1' '1' '1'
run_cubed

print_title ${CNTR} "Invalid character"
map_test 's' '0' '1' '1' '1' '1' '1'
run_cubed

print_title ${CNTR} "Invalid character"
map_test 'S' '2' '1' '1' '1' '1' '1'
run_cubed

print_title ${CNTR} "No closed walls"
map_test 'S' '0' '0' '1' '1' '1' '1'
run_cubed

print_title ${CNTR} "No closed walls"
map_test 'S' '0' '1' '0' '1' '1' '1'
run_cubed

print_title ${CNTR} "No closed walls"
map_test 'S' '0' '1' '1' '0' '1' '1'
run_cubed

print_title ${CNTR} "No closed walls"
map_test 'S' '0' '1' '1' '1' '0' '1'
run_cubed

print_title ${CNTR} "No closed walls"
map_test 'S' '0' '1' '1' '1' '1' '0'
run_cubed

delete_test_files
printf "\n${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
printf "${GB}\nALL TESTS FINISHED!\n${RC}"
