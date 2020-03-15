x=''
if [ "$#" -ne 3 ]; then
    x=''
else
    x=$3
    echo $x
fi
echo $x
ssh $1 bash -s $x < $2

