llama -fm68k -o test_ob.hex test_ob.s
llama -fm68k -o ol_sprite.hex ol_sprite.s
llama -fm68k -o ol_circle.hex ol_circle.s
llama -fm68k -o ol_warps.hex ol_warps.s
llama -fm68k -o ol_line.hex ol_line.s
llama -fm68k -o moo_cow.hex moo_cow.s
llama -fm68k -o sourcetile.hex sourcetile.s
llama -fm68k -o olrlister.hex olrlister.s
llama -fm68k -o kryten.hex kryten.s
llama -fmpo -o ol_demo2.mpo ol_demo2.s
mload -p 0 -h ol_demo2.mpo -r
