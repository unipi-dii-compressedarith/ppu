import os
import pathlib

CMD = "tabstospaces.py"

path = pathlib.Path(".").absolute()

for src_file in [i for i in os.listdir(f"{path}/src") if i.lower() != "makefile"]:
    try:
        os.system(f"{CMD} {path}/src/{src_file}")
    except IsADirectoryError as e:
        pass
