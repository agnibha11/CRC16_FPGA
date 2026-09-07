transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+crc_core  -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.crc_core xil_defaultlib.glbl

do {crc_core.udo}

run 1000ns

endsim

quit -force
