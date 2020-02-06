rm -rf ~/snabb/src/MultiDimSnabb
rm -rf ~/snabb/src/obj/program/MultiDimSnabb
rm ~/snabb/src/snabb
cp -r ~/MultiDimMonitor/MultiDimSnabb ~/snabb/src/program
make -j -C ~/snabb
