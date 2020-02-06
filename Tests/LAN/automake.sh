rm -rf ~/snabb/src/LAN
rm -rf ~/snabb/src/obj/program/LAN
rm ~/snabb/src/snabb
cp -r ~/MultiDimMonitor/Tests/LAN ~/snabb/src/program
make -j -C ~/snabb
