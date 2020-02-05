rm -rf ~/snabb/src/VLAN
rm -rf ~/snabb/src/obj/program/VLAN
rm ~/snabb/src/snabb
cp -r ~/VLAN ~/snabb/src/program
make -j -C ~/snabb
