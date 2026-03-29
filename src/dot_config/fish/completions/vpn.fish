complete -c vpn -n "__fish_seen_subcommand_from connect c" -s c -l config -r -d "Path to config file"
complete -c vpn -n "not __fish_seen_subcommand_from connect disconnect status c d s" -a "connect" -d "Connect to VPN"
complete -c vpn -n "not __fish_seen_subcommand_from connect disconnect status c d s" -a "disconnect" -d "Disconnect from VPN"
complete -c vpn -n "not __fish_seen_subcommand_from connect disconnect status c d s" -a "status" -d "Show VPN status"
