# PDSVM-FPGA
A parallel computing architecture designed for SVM on FPGA

Enviroment: ISE14.7 64bit;
FPGA: spartan6lx45-2csg324; 

Top Fitle: uart_test.v

external IPcore : 1 PLL, and 1 FIFO;
                 FIFO setting: Native Inteface, Independent Clock Block RAM, Write Width 8, Write Depth 2048, Read Width 8;
