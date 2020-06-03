`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  Rx_engine.v                                      //
//                                                               // 
//  Created by       Nguyen Doan on 3/24/2020	                 //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	     //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//
module Rx_engine_tb();
    reg           clk, rst;
    reg  [18:0]   BAUD_DECODE;
    reg           EIGHT, PEN, OHEL;
    reg           RX; 
    reg           READS;
    wire  [7:0]   UART_RDATA; 
    wire          RX_RDY;
    wire          PERR, FERR, OVF;
    integer       i;
    
    Rx_engine uut(.clk(clk), 
                  .rst(rst), 
                  .BAUD_DECODE(BAUD_DECODE), 
                  .EIGHT(EIGHT), 
                  .PEN(PEN), 
                  .OHEL(OHEL), 
                  .RX(RX), 
                  .READS(READS), 
                  .UART_RDATA(UART_RDATA), 
                  .PERR(PERR), 
                  .FERR(FERR), 
                  .OVF(OVF), 
                  .RX_RDY(RX_RDY));

    always #5 clk = ~clk;
    initial begin
       rst = 1'b1;
       clk = 1'b0;
       RX = 1'b0;
       BAUD_DECODE = 19'b0;
       {EIGHT,PEN,OHEL} = 3'b0; 
       READS = 1'b0;
       #100
       RX = 1'b1;
       BAUD_DECODE = 19'd109;
       EIGHT = 1'b1;
       PEN = 1'b0;
       OHEL = 1'b1;
       #100
       rst = 0;
       for (i=0;i<20;i=i+1)
           begin
           #1085
           RX = ~RX;
           end
//       #100
//       READS = 1'b1;
    end
endmodule
