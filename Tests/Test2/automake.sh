rm -rf ~/snabb/src/Test2
rm -rf ~/snabb/src/obj/program/Test2
rm ~/snabb/src/snabb
cp -r ~/Test2 ~/snabb/src/program
make -j -C ~/snabb
