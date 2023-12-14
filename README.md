# Wikidumps

This is very lazy and crude way to convert and work with wikipedia dumps.

## Požadavky

- git
- bash
- python
- docker
- docker-compose
- mariadb-client

## Použití

> Pozor zatím to funguje jen pro externallinks tabulku.

`git pull` stáhne repozitář.

Teď je dobré změnit heslo v `docker-compose.yml`. Případně odkomentovat nastavení pro adminer, ale nebude nutné pro automatické vytváření semínek.

Pokud ještě nemáš stažený dump soubor, tak ho můžeš stáhnout pomocí:

```bash
curl -L požadovaná_url
```

Pokud má soubor příponu .gz pak pusť:

```bash
gunzip cesta_k_souboru
```

Výsledkem by měl být .sql soubor. 

Teď vytvoř novou databázy, do které pak nahrajeme data. example nahraď správným heslem.

```bash
mariadb --port=3306 --protocol=tcp --user=root --password=example --execute="create database wiki;"
```

Teď naimportujeme sql soubor do databáze.

```bash
mariadb --port=3306 --protocol=tcp --user=root --password=example --database=wiki < cesta_k_souboru
```

Vyexportujeme data v csv formátu pomocí předpřipraveného sql scriptu.

```bash
mariadb --port=3306 --protocol=tcp --user=root --password=example --database=wiki < export_csv
```

Přesuneme exportovaný soubor z kontejneru do aktuálního adresáře.

```bash
docker cp $( docker ps -qf "name=db" ):/var/lib/mysql/externallinks.csv .
```

Vygenerujeme seznam semínek pomocí scriptu seeds_from_csv.py

```bash
python3 seeds_from_csv.py
```

> Varování! Pokus otevřít daný soubor ve VS Code může mít za následek crash minimálně samotného editoru. Pro pohdlné čtení souboru je nejlepší použít less či jiný pager.

## Quick commands

```bash
# Open sql shell
mariadb --port=3306 --protocol=tcp --user=root --password=example --database=wiki
```