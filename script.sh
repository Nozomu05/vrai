#!/bin/bash

echo "choisir que faire\n1) accepter tout les traffics\n2) refuser tout les traffics"
read valeur

if [ $valeur -eq 1 ]; then
	sudo iptables -P INPUT ACCEPT
	sudo iptables -P OUTPUT ACCEPT
	sudo iptables -P FORWARD ACCEPT
elif [ $valeur -eq 2 ]; then
	sudo iptables -P INPUT DROP
	sudo iptables -P OUTPUT DROP
	sudo iptables -P FORWARD DROP
else
	echo "choix invalide"

fi


