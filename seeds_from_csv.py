# Expects simple csv file with two columns like protocol:pseudo_surt,path. Example https://cz.seznam.www.,/path/to/somewhere
# If input data is valid, file out.seeds.txt will be generated containing one url per line. Only http, https protocols are allowed.
import csv
import sys


INPUT_PATH = "externallinks.csv"
OUTPUT_PATH = "out.seeds.txt"

i_file = open(INPUT_PATH)
o_file = open(OUTPUT_PATH, mode="w", encoding="utf8")

data = csv.reader(i_file)

proto_sep = "//"
addr_sep = "."
line_number = 0
while True:
    line_number += 1
    try:
        line = next(data)
    except StopIteration:
        break
    except Exception as e:
        print("Something went wrong on line:", line_number, file=sys.stderr)
        print(e, file=sys.stderr)
        print("But I am brave and I will continue!", file=sys.stderr)
        continue
    try:
        if len(line) != 2:
            print("invalid line, skipping", line_number, line, file=sys.stderr)
            continue
        dom, path = line
        if not dom.startswith("http"):
            continue
        # line = line.rstrip()
        dom = dom.rstrip(addr_sep)
        proto, addr = dom.split(proto_sep, maxsplit=2)
        addr = addr.split(addr_sep)
        # Should we filter wikipedia.org out?
        j = len(addr)
        new_addr = ""
        while j > 0:
            j -= 1
            new_addr += addr[j]
            if j != 0:
                new_addr += addr_sep
        seed = proto + proto_sep + new_addr + path
        print(seed, file=o_file)
    except Exception as e:
        print("Error while processing line:", line_number, line, file=sys.stderr)
        i_file.close()
        o_file.close()
        raise e

i_file.close()
o_file.close()
