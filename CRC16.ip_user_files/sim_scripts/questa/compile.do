vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../../../../Xilinix/2025.2/data/rsb/busdef" \
"../../../CRC16.srcs/sources_1/new/CRC16.v" \
"../../../CRC16.srcs/sources_1/new/CRC_RX.v" \
"../../../CRC16.srcs/sources_1/new/CRC_TX.v" \
"../../../CRC16.srcs/sources_1/new/MSG_MEM.v" \
"../../../CRC16.srcs/sources_1/new/SERIALIZER.v" \
"../../../CRC16.srcs/sources_1/new/CRC_CORE.v" \


vlog -work xil_defaultlib \
"glbl.v"

