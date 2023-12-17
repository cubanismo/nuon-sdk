del *.mbi
bmp2mbm -img -ycrcb -nq bghi
ren bghi.mbi bghiycc.mbi
bmp2mbm -img -ycrcb -nq bglo
ren bglo.mbi bgloycc.mbi
bmp2mbm -img -grb bghi
ren bghi.mbi bghigrb.mbi
bmp2mbm -img -grb bglo
ren bglo.mbi bglogrb.mbi

