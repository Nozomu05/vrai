#!/bin/bash


#partie 1
echo "choisir que faire\n1) accepter tout les traffics\n2) refuser tous les traffics"
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
	echo "choix invalidé"

fi


#partie 2
ajouter_regle() {
  echo "\nAjouter une règle :"
  echo "\nProtocole (tcp/udp) : " 
  read protocole
  echo "\nPort ou service : " 
  read port
  echo "\nAction (ACCEPT/DROP/REJECT) : " 
  read action
  echo "\nAdresse IP source (laisser vide pour tout) : " 
  read source
  echo "\nAdresse IP destination (laisser vide pour tout) : " 
  read destination

  cmd="iptables -A INPUT"
  if [[ -n $source ]]; then
    $cmd+=" -s $source"
  fi
  if [[ -n $destination ]]; then
    $cmd+=" -d $destination"
  fi
  $cmd+=" -p $protocole --dport $port -j $action"

  echo "Exécution : $cmd"
  eval $cmd
  echo "Règle ajoutée."
}

modifier_regle() {
  echo "\nModifier une règle :"
  iptables -L --line-numbers
  echo "\nNuméro de la règle à modifier  : " 
  read numero
  echo "\nProtocole (tcp/udp) : " 
  read protocole
  echo "\nPort ou service : " 
  read port
  echo "\nAction (ACCEPT/DROP/REJECT) : " 
  read action
  echo "\nAdresse IP source (laisser vide pour tout) : " 
  read source
  echo "\nAdresse IP destination (laisser vide pour tout) : " 
  read destination

  iptables -D INPUT $numero

  $cmd="iptables -A INPUT"
  if [[ -n $source ]]; then
    $cmd+=" -s $source"
  fi
  if [[ -n $destination ]]; then
    $cmd+=" -d $destination"
  fi
  $cmd+=" -p $protocole --dport $port -j $action"

  echo "Exécution : $cmd"
  eval $cmd
  echo "Règle modifiée."
}


supprimer_regle() {
  echo "\nSupprimer une règle :"
  iptables -L --line-numbers
  echo "\nNuméro de la règle a supprimer  : " 
  read numero
  iptables -D INPUT $numero
  echo "Règle supprimée."
}

echo -e "\nGestion des règle de pare-feu :"
echo "1) Ajouter une règle"
echo "2) Modifier une règle"
echo "3) Supprimer une règle"
echo "Votre choix : " 
read choix

case $choix in 
	1)
		ajouter_regle
		;;
	2)
		modifier_regle
		;;
	3)
		supprimer_regle
		;;
	*)
		echo "Choix invalide"
esac 

#partie 3

configurer_nat() {
    read -p "Activer le masquage NAT (oui/non) ? : " nat
    if [ "$nat" = "oui" ]; then
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    elif [ "$nat" = "non" ]; then 
    	 iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
    fi

    read -p "Rediriger un port (oui/non) ? : " port
    if [ "$port" = "oui" ]; then
        read -p "Port source : " port_source
        read -p "IP destination : " ip_dest
        read -p "Port destination : " port_dest
        iptables -t nat -A PREROUTING -p tcp --dport $port_source -j DNAT --to-destination $ip_dest:$port_dest
    fi
}
configurer_nat

#partie 4
activer_journalisation() {
    read -p "Activer la journalisation pour INPUT (oui/non) ? : " log_input
    if [ "$log_input" == "oui" ]; then
        iptables -A INPUT -j LOG --log-prefix "INPUT BLOCK: "
    elif [ "$log_input" == "non" ]; then
    	 iptables -D INPUT -j LOG --log-prefix "INPUT BLOCK: "
    fi
    read -p "Activer la journalisation pour OUTPUT (oui/non) ? : " log_output
    if [ "$log_output" == "oui" ]; then
        iptables -A OUTPUT -j LOG --log-prefix "OUTPUT BLOCK: "
    elif [ "$log_input" == "non" ]; then
    	 iptables -D INPUT -j LOG --log-prefix "OUTPUT BLOCK: "
    fi
}

activer_journalisation
