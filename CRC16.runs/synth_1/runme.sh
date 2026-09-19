#!/bin/bash

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/agnibha/Xilinix/2025.2/Vitis/bin:/home/agnibha/Xilinix/2025.2/Vivado/ids_lite/ISE/bin/lin64:/home/agnibha/Xilinix/2025.2/Vivado/bin
else
  PATH=/home/agnibha/Xilinix/2025.2/Vitis/bin:/home/agnibha/Xilinix/2025.2/Vivado/ids_lite/ISE/bin/lin64:/home/agnibha/Xilinix/2025.2/Vivado/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/agnibha/Documents/acads/Reconfig/Lab Assignments/Lab 2/CRC16/CRC16.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log crc_top.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source crc_top.tcl
