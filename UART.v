`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  UART.v                                           //
//                                                               // 
//  Created by       Nguyen Doan on 3/31/2020	                 //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	     //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//

module UART(clk, rst, WRITES, READS, UDI, RX, UART_INT, TX, UDO);

    input               clk, rst, RX;
    input       [7:0]   READS, WRITES;
    input       [7:0]   UDI;
    output              TX, UART_INT;
    output      [7:0]   UDO; 
    
    reg         [7:0]   UART_config, UDO;
    
    wire       [18:0]   baud_decode; 
    wire        [7:0]   UART_RDATA;
    wire                TX_RDY, RX_RDY, TX_PED, RX_PED;
    wire                PERR, FERR, OVF;
    
    
    always @(posedge clk, posedge rst) 
        if (rst) 
            UART_config <= 8'b0;
        else if (WRITES[6])
            UART_config <= UDI; 
        else 
            UART_config <= UART_config;
    
    baud_decode 
        BAUD_DECODE(.clk(clk), 
                    .rst(rst), 
                    .baud_control(UART_config[7:4]), 
                    .baud_rate(baud_decode)); 
    Rx_engine
        RX_engine   (.clk(clk), 
                     .rst(rst), 
                     .BAUD_DECODE(baud_decode), 
                     .EIGHT(UART_config[3]), 
                     .PEN(UART_config[2]),
                     .OHEL(UART_config[1]), 
                     .RX(RX), 
                     .READS(READS[0]), 
                     .UART_RDATA(UART_RDATA), 
                     .PERR(PERR), 
                     .FERR(FERR), 
                     .OVF(OVF), 
                     .RX_RDY(RX_RDY));    
  
    transmit_engine
        TX_engine   (.clk(clk), 
                     .rst(rst), 
                     .write(WRITES[0]), 
                     .out_port(UDI), 
                     .eight(UART_config[3]), 
                     .pen(UART_config[2]), 
                     .ohel(UART_config[1]), 
		             .baud_decode(baud_decode), 
		             .TxRdy(TX_RDY), 
		             .Tx(TX));    
	
	// UART DATA OUT 
	always @(*)
	   begin
	   UDO = 8'b0;
	   if (READS[0])
	       UDO = UART_RDATA;
	   else if (READS[1])
	       UDO = {3'b0,OVF,FERR,PERR,TX_RDY,RX_RDY};
	   end 
	   
    // UART_INT
    PED 
        RxPED (.reset(rst), .clk(clk), .in(RX_RDY), .ped(RX_PED));
    PED    
        TxPED (.reset(rst), .clk(clk), .in(TX_RDY), .ped(TX_PED));
        
    assign UART_INT = RX_PED | TX_PED;
    
endmodule
