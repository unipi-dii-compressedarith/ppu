from vcd.gtkw import GTKWSave, GTKWColor
import io


gtkw = GTKWSave(io.StringIO())
with gtkw.group("mygroup"):
    gtkw.trace("a.b.x")
    gtkw.trace("a.b.y")
    gtkw.trace("a.b.z")

gtkw.dumpfile("aaa2.gtkw")
