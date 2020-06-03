`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  SOPC_toplevel.v                                  //
//                                                               // 
//  Created by       Nguyen Doan on 4/7/2020	                 //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work        	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//
module SOPC_toplevel(clk, rst, switches, RX, TX, LED);
    input               clk, rst; 
    input   [15:0]      switches; 
    input               RX;
    output              TX;
    output  [15:0]      LED;
    
    reg     [15:0]      IN_PORT;
    reg     [15:0]      LED;
    
    wire                rst_S; 
    wire                INT, READ_STROBE, WRITE_STROBE, INT_ACK;
    wire                UART_INT;
    wire    [15:0]      PORT_ID, OUT_PORT;
    wire     [7:0]      WRITES, READS;
    wire     [7:0]      UART_DS;
    
    AISO
        AISO(.reset(rst), .clk(clk), .reset_S(rst_S));
   
    tramelblaze_top 
        TB(.CLK(clk), 
           .RESET(rst_S), 
           .IN_PORT(IN_PORT), 
           .INTERRUPT(INT), 
           .OUT_PORT(OUT_PORT), 
           .PORT_ID(PORT_ID), 
           .READ_STROBE(READ_STROBE), 
           .WRITE_STROBE(WRITE_STROBE), 
           .INTERRUPT_ACK(INT_ACK));
    
    always @(*) 
        begin
        IN_PORT = 16'b0;
        if (READS[1]|READS[0])
            IN_PORT = UART_DS;
        else if (READS[6])
            IN_PORT = switches;
        end
 
           
    adrs_decode
        Adrs_decode(.port_id(PORT_ID), 
                    .read_strobe(READ_STROBE), 
                    .write_strobe(WRITE_STROBE), 
                    .writes(WRITES),
                    .reads(READS));
                    
   UART
        UART(.clk(clk), 
             .rst(rst_S), 
             .WRITES(WRITES), 
             .READS(READS), 
             .UDI(OUT_PORT[7:0]), 
             .RX(RX), 
             .UART_INT(UART_INT), 
             .TX(TX), 
             .UDO(UART_DS));
             
   SRflop
        INT_RS(.rst(rst_S), 
               .clk(clk), 
               .set(UART_INT), 
               .reset(INT_ACK), 
               .Q(INT));
    
    // LED output          
    always @(posedge clk, posedge rst) 
        if (rst) 
            LED <= 16'b0; 
        else if (WRITES[2])
            LED <= OUT_PORT;
        else 
            LED <= LED;
            
endmodule
