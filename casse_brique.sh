#!/bin/bash


norm="\\033[0m"
bold="\\033[1m"
unli="\\033[4m"
invi="\\033[8m"
red="\\033[31m"
gren="\\033[32m"
yell="\\033[33m"
blue="\\033[36m"


#init screen
	stty -icanon
	tput civis
	clear
	echo -e "${invi}"
	echo -e "${norm}\tq : ←\t\td : →\t\tp : Pause\tw : Exit${invi}"
	echo -e "${norm}${yell}################################################################################${invi}"
	for d in $(seq 21)
		do echo -en "${norm}${yell}#${invi}" ; tput hpa 80 ; echo -e "${norm}${yell}#${invi}"
		done
	echo -en "${norm}${yell}################################################################################${invi}"


#init briques création / affichage
	nQ=30
	Qxl=4
	Qyl=1
	Qs=#
	for i in $(seq 0 9)
		do
		Qa[$i]=1
		Qx[$i]=$(( 7+(3+$Qxl)*$i ))
		Qy[$i]=4
		done
	for i in $(seq 10 19)
		do
		Qa[$i]=1
		Qx[$i]=$(( 7+(3+$Qxl)*$(echo -n $i | tail -c1) ))
		Qy[$i]=6
		done
	for i in $(seq 20 29)
		do
		Qa[$i]=1
		Qx[$i]=$(( 7+(3+$Qxl)*$(echo -n $i | tail -c1) ))
		Qy[$i]=8
		done
	for i in $(seq 0 29)
		do
		echo -en "${norm}\033[${Qy[$i]};${Qx[$i]}H$(seq -s"$Qs" 0 $Qxl | tr -d '[:digit:]')${invi}"
		done


#init balle
	Bx=10
	By=10
	Bxv=1
	Byv=1
	echo -en "${norm}\033[${By};${Bx}HO${invi}"


#init raquette
	Rx1=10
	Rx2=20
	Ry=20
	echo -en "${norm}\033[${Ry};${Rx1}H$(seq -s"_" $Rx1 $Rx2 | tr -d '[:digit:]')${invi}"


while true
	do

#déplacement raquette / gestion clavier
	key="$(dd if=$(tty) iflag=nonblock 2>/dev/null | head -c1)"
	case $key in
		q )
			echo -en "${norm}\033[${Ry};${Rx1}H$(seq -s" " $Rx1 $Rx2 | tr -d '[:digit:]')${invi}"
			if [ $Rx1 -gt 2 ]
				then
				Rx1=$(($Rx1-2))
				Rx2=$(($Rx2-2))
				fi
			echo -en "${norm}\033[${Ry};${Rx1}H$(seq -s"_" $Rx1 $Rx2 | tr -d '[:digit:]')${invi}"
			;;
		d )
			echo -en "${norm}\033[${Ry};${Rx1}H$(seq -s" " $Rx1 $Rx2 | tr -d '[:digit:]')${invi}"
			if [ $Rx2 -lt 79 ]
				then
				Rx1=$(($Rx1+2))
				Rx2=$(($Rx2+2))
				fi
			echo -en "${norm}\033[${Ry};${Rx1}H$(seq -s"_" $Rx1 $Rx2 | tr -d '[:digit:]')${invi}"
			;;
		w )
			clear
			echo -en "${norm}"
			tput cnorm
			exit 0
			;;
		p )
			read
			;;
		esac


#déplacement balle
	echo -en "\033[${By};${Bx}H "
	if [ $Bx -le 2 ] ; then Bxv=$(( -$Bxv )) ; fi
	if [ $Bx -ge 79 ] ; then Bxv=$(( -$Bxv )) ; fi
	if [ $By -le 3 ] ; then Byv=$(( -$Byv )) ; fi
	if [ $By -ge 23 ]
		then
		mal=$(( $mal+1 ))
		echo -en "${norm}${red}\033[1;77H${mal}${invi}"
		Byv=$(( -$Byv ))
		fi
	if [ $By = $Ry ] && [ $Bx -ge $Rx1 ] && [ $Bx -le $Rx2 ]
		then
		Byv=$(( -$Byv ))
		echo -en "${norm}\033[${Ry};${Rx1}H$(seq -s"_" $Rx1 $Rx2 | tr -d '[:digit:]')${invi}"
		fi
	for i in $(seq 0 29)
		do
		if [ ${Qa[$i]} ] 
			then
			if [ $By = ${Qy[$i]} ] && [ $Bx -ge ${Qx[$i]} ] && [ $Bx -le $(( ${Qx[$i]}+$Qxl)) ]
				then
				Qa[$i]=
				nQ=$(( $nQ-1 ))
				echo -en "\033[${Qy[$i]};${Qx[$i]}H$(seq -s' ' 0 $Qxl | tr -d '[:digit:]')"
				Byv=$(( -$Byv ))
				fi
			fi
		done
	Bx=$(( $Bx+$Bxv ))
	By=$(( $By+$Byv ))
	echo -en "${norm}\033[${By};${Bx}HO${invi}"


#fin du jeu
	if [ $nQ = 0 ]
		then
		echo -en "${norm}${blue}\033[12;39HFINI${invi}"
		read
		clear
		echo -en "${norm}"
		tput cnorm
		exit 0
		fi


#tempo
	echo -en "\033[H"
	sleep 0.05s
	done 
