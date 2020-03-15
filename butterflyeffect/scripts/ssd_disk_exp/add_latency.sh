tc qdisc del dev $1 root # Ensure you start from a clean slate
tc qdisc add dev $1 root handle 1: prio
tc qdisc add dev $1 parent 1:3 handle 30: netem delay $3
tc filter add dev $1 protocol ip parent 1:0 prio 3 u32 \
   match ip dst $2 flowid 1:3
