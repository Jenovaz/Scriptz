# pip install pyfiglet
import pyfiglet

for word in ("SCRIPT BY", "JENOVAZ"):
    art = pyfiglet.figlet_format(word, font="ansi_shadow")
    print("\n".join(line.rstrip() for line in art.splitlines()))
