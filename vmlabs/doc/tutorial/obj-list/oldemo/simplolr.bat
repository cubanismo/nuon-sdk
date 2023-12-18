llama -fm68k -o ol_sprite.hex ol_sprite.s
llama -fm68k -o ol_line.hex ol_line.s
llama -fm68k -o ol_warps.hex ol_warps.s
llama -fm68k -o test_ob.hex test_ob.s
llama -fmpo -o simpleolr.mpo simpleolr.s
mload -p 0 -h simpleolr.mpo -r -m
