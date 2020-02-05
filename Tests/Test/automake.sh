rm -rf ~/snabb/src/Test
rm -rf ~/snabb/src/obj/program/Test
rm ~/snabb/src/snabb
cp -r ~/Test ~/snabb/src/program
make -j -C ~/snabb
