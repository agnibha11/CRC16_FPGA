transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+crc_top  -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.crc_top xil_defaultlib.glbl

do {crc_top.udo}

run 1000ns

endsim

quit -force
