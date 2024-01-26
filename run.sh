#!/usr/bin/env bash

set -o errexit # exit when a command fails.
# set -o nounset # exit when using undeclared variables
set -o pipefail # catch non-zero exit code in pipes

now() {
    date +'%Y-%M-%d %T'
}

[ "$1" != '' ] || { echo "Password must be set as first argument!"; exit 1; }

echo "$(now) Starting mariadb container"
. start.sh
sleep 10

echo "$(now) Creating new database"
mariadb --port=3306 --protocol=tcp --user=root --password="$1" --execute="create database wiki;"

echo "$(now) Starting download" 
curl -o wiki_dump.sql.gz -L https://dumps.wikimedia.org/cswiki/latest/cswiki-latest-externallinks.sql.gz

echo "$(now) Decompressing"
gunzip -f wiki_dump.sql.gz

echo "$(now) Importing sql file to database, this will take a while"
mariadb --port=3306 --protocol=tcp --user=root --password="$1" --database=wiki < wiki_dump.sql

echo "$(now) Exporting csv data"
mariadb --port=3306 --protocol=tcp --user=root --password="$1" --database=wiki < export_csv

echo "$(now) Moving to local directory"
docker cp $( docker ps -qf "name=db" ):/var/lib/mysql/externallinks.csv .

echo "$(now) Creating seeds"
python3 seeds_from_csv.py

echo "$(now) Sorting seeds"
sort -u -o sorted.seeds.txt out.seeds.txt

echo "$(now) Removing mariadb container"
docker compose rm --stop -f db

echo "$(now) Finished succesfully :)"
echo "Sorted seeds: sorted.seeds.txt"
echo "Unsorted seeds: out.seeds.txt"