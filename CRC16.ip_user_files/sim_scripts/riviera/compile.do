transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../../../../../../Xilinix/2025.2/data/rsb/busdef" -l xil_defaultlib \
"../../../CRC16.gen/sources_1/ip/vio_0/sim/vio_0.v" \
"../../../CRC16.srcs/sources_1/new/CRC16.v" \
"../../../CRC16.srcs/sources_1/new/CRC_CORE.v" \
"../../../CRC16.srcs/sources_1/new/CRC_RX.v" \
"../../../CRC16.srcs/sources_1/new/CRC_TX.v" \
"../../../CRC16.srcs/sources_1/new/CustomBuff.v" \
"../../../CRC16.srcs/sources_1/new/MSG_MEM.v" \
"../../../CRC16.srcs/sources_1/new/SERIALIZER.v" \
"../../../CRC16.srcs/sources_1/new/CRC_TOP.v" \


vlog -work xil_defaultlib \
"glbl.v"

