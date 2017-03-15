#!/bin/bash


norm="\\033[0m"
bold="\\033[1m"
unli="\\033[4m"
invi="\\033[8m"
red="\\033[31m"
gren="\\033[32m"
yell="\\033[33m"
viol="\\033[35m"
blue="\\033[36m"


#pong.sh {--serveur,--client}
#client : ps -ef | grep 'pong\.sh\ --serveur'
#serveur : wait for pts/client
#end : killall pid / killall pong.sh


#init screen
#	stty -icanon
#	tput civis
#	clear

#menu
#	if [ -z $* ]
	if [ "$1" != '--client' ] && [ "$1" != '--server' ]
		then
		echo -e "\tThis script is a simple pong game. It runs over two separates windows"
		echo -e "\t-one for each player- by using both of following arguments in two"
		echo -e "\tseparates terminals. So through an ssh tunnel, the two players can"
		echo -e "\trun the game over two distants computers."
		echo -e "\t\t${unli}example :${norm}"
		echo -e "\t\tuser1@pc1~$ pong.sh --server"
		echo -e "\t\tuser2@pc2~$ ssh user1@pc1"
		echo -e "\t\t > user1@pc1~$ pong.sh --client"
		echo -e "\tPlayer1 : ${yell}pong.sh --server${norm}"
		echo -e "\tPlayer2 : ${yell}pong.sh --client${norm}"
		exit 1
		fi

#secure
	if [ $2 ]
		then
		echo -e "\tonly one argument {${yell}--server${norm},${yell}--client${norm}}"
		exit 1
		fi

#client
	if [ $1 = '--client' ]
		then
		echo -e "${yell}\tWaiting for a server...${norm}"
		while true ; do : ; done
		fi



#serveur connect to client
	if [ $1 = '--server' ]
		then

#search client
		echo -e "${yell}\tWaiting for a client...${norm}"
		while [ -z "$(ps -ef | grep 'pong\.sh\ \-\-client')" ] ; do : ; done
		tty1=$(tty)
		tty2=$(ps -ef |grep 'pong\.sh\ \-\-client' | awk '{print "/dev/"$6}')

#init screen
		stty --file=$tty1 -icanon
		stty --file=$tty2 -icanon
		tput civis | tee $tty1 >$tty2
		clear | tee $tty1 >$tty2
		echo -e "${invi}" | tee $tty1 >$tty2
		echo -e "${norm}${blue}\t\tz : ↑\ts : ↓${norm}\t p : ||\t  w : ×${viol}\t  o : ↑\t l : ↓${invi}" | tee $tty1 >$tty2
		echo -e "${norm}${yell}################################################################################${invi}" | tee $tty1 >$tty2
		for d in $(seq 21)
			do
			echo -en "${norm}${yell}#${invi}" | tee $tty1 >$tty2
			tput hpa 40 | tee $tty1 >$tty2
			echo -en "${norm}${yell}|${invi}" | tee $tty1 >$tty2
			tput hpa 80 | tee $tty1 >$tty2
			echo -e "${norm}${yell}#${invi}" | tee $tty1 >$tty2
			done
		echo -en "${norm}${yell}################################################################################${invi}" | tee $tty1 >$tty2

#print raquette
		R1x=4
		R1yh=5
		R1yl=10
		R1yv=1
		for i in $(seq $R1yh $R1yl)
			do
			echo -en "${norm}${blue}\033[${i};${R1x}H|${invi}" | tee $tty1 >$tty2
			done
		R2x=77
		R2yh=15
		R2yl=20
		R2yv=1
		for i in $(seq $R2yh $R2yl)
			do
			echo -en "${norm}${viol}\033[${i};${R2x}H|${invi}" | tee $tty1 >$tty2
			done

#print ball
		Bx=10
		By=10
		Bxv=1
		Byv=1
		echo -en "${norm}\033[${By};${Bx}HO${invi}" | tee $tty1 >$tty2


		while true
			do

#key watch
			key1="$(dd if=$tty1 iflag=nonblock 2>/dev/null | head -c1)"
			key2="$(dd if=$tty2 iflag=nonblock 2>/dev/null | head -c1)"
#exit
			if [ "$key1" = w ] || [ "$key2" = w ]
				then
				clear | tee $tty1 >$tty2
				echo -en "${norm}" | tee $tty1 >$tty2
				tput cnorm | tee $tty1 >$tty2
				kill $(ps -ef | grep 'pong\.sh\ \-\-client' | awk '{print $2}')
				exit 0
				fi
#pause
			if [ "$key1" = p ] || [ "$key2" = p ]
				then
				p=1
				while [ $p = 1 ]
					do
					key1="$(dd if=$tty1 iflag=nonblock 2>/dev/null | head -c1)"
					key2="$(dd if=$tty2 iflag=nonblock 2>/dev/null | head -c1)"
					if [ "$key1" = p ] || [ "$key2" = p ] ; then p=0 ; fi
					sleep 0.05s
					done
				fi

#ball move
			if [ $Bx -le 2 ] ; then Bxv=$(( -$Bxv )) ; S2=$(( $S2+1 )) ; fi
			if [ $Bx -ge 79 ] ; then Bxv=$(( -$Bxv )) ; S1=$(( $S1+1 )) ; fi
			if [ $By -le 3 ] ; then Byv=$(( -$Byv )) ; fi
			if [ $By -ge 23 ] ; then Byv=$(( -$Byv )) ; fi
			if [ $Bx = $(( $R1x )) ] && [ $By -le $R1yl ] && [ $By -ge $R1yh ] ; then Bxv=$(( -$Bxv )) ; fi
			if [ $Bx = $(( $R2x )) ] && [ $By -le $R2yl ] && [ $By -ge $R2yh ] ; then Bxv=$(( -$Bxv )) ; fi
			echo -en "\033[${By};${Bx}H " | tee $tty1 >$tty2
			Bx=$(( $Bx+$Bxv ))
			By=$(( $By+$Byv ))
			echo -en "${norm}\033[${By};${Bx}HO${invi}" | tee $tty1 >$tty2
			if [ $Bx = 40 ] || [ $Bx = 42 ]
				then
				for d in $(seq 3 23)
					do
					echo -en "${norm}${yell}\033[${d};41H|${invi}" | tee $tty1 >$tty2
					done
				fi

#player1 raquette
			if [ "$key1" = z ] || [ "$key1" = s ]
				then
				for i in $(seq $R1yh $R1yl)
					do
					echo -en "\033[${i};${R1x}H " | tee $tty1 >$tty2
					done
				if [ "$key1" = z ] && [ $R1yh -gt 3 ]
					then
					R1yh=$(( $R1yh-$R1yv ))
					R1yl=$(( $R1yl-$R1yv ))
					fi
				if [ "$key1" = s ] && [ $R1yl -lt 23 ]
					then
					R1yh=$(( $R1yh+$R1yv ))
					R1yl=$(( $R1yl+$R1yv ))
					fi
				fi
			for i in $(seq $R1yh $R1yl)
				do
				echo -en "${norm}${blue}\033[${i};${R1x}H|${invi}" | tee $tty1 >$tty2
				done
#player2 raquette
			if [ "$key2" = o ] || [ "$key2" = l ]
				then
				for i in $(seq $R2yh $R2yl)
					do
					echo -en "\033[${i};${R2x}H " | tee $tty1 >$tty2
					done
				if [ "$key2" = o ] && [ $R2yh -gt 3 ]
					then
					R2yh=$(( $R2yh-$R2yv ))
					R2yl=$(( $R2yl-$R2yv ))
					fi
				if [ "$key2" = l ] && [ $R2yl -lt 23 ]
					then
					R2yh=$(( $R2yh+$R2yv ))
					R2yl=$(( $R2yl+$R2yv ))
					fi
				fi
			for i in $(seq $R2yh $R2yl)
				do
				echo -en "${norm}${viol}\033[${i};${R2x}H|${invi}" | tee $tty1 >$tty2
				done

#print score
			echo -en "${norm}${blue}${bold}\033[1;3H${S1}${invi}" | tee $tty1 >$tty2
			echo -en "${norm}${viol}${bold}	\033[1;77H${S2}${invi}" | tee $tty1 >$tty2
#tempo
			echo -en "\033[H" | tee $tty1 >$tty2
			sleep 0.03s
			done
		fi


