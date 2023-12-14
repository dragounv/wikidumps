[ -f "$1" ] || ( echo "The file $1 does not exist or is not regular!"; exit 1 )

docker cp -q "$1" $( docker ps -qf "name=db" ):/root || ( echo "docker cp failed"; exit 1 )

