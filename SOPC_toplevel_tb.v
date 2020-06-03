`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  SOPC_toplevel_tb.v                               //
//                                                               // 
//  Created by       Nguyen Doan on 4/10/2020	                 //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work        	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//
module SOPC_toplevel_tb;
    reg               clk, rst; 
    reg   [15:0]      switches; 
    reg               RX;
    wire              TX;
    
    integer           i;
    SOPC_toplevel uut(.clk(clk), 
                      .rst(rst), 
                      .switches(switches), 
                      .RX(RX), 
                      .TX(TX));
                      
    always #5 clk = ~clk;
    initial begin 
    clk = 1'b0; 
    rst = 1'b1; 
   ////////////////////////////////////////////
   // case 1: 7 bit correct no parity good stop
   ////////////////////////////////////////////
    switches = 8'hB0;
    RX = 1'b1;
    i = 0;
    rst = 1'b0;
    #10000
    for (i=0;i<8;i=i+1)
      begin
      #1085
      RX = ~RX;
      end
   ////////////////////////////////////////////
   // case 2: 7 bit correct no parity bad stop
   ////////////////////////////////////////////     
   #10000
   rst = 1;
   #100
   rst = 0;
   #10000
   for (i=0;i<7;i=i+1)
      begin
      #1085
      RX = ~RX;
      end  
   ////////////////////////////////////////////
   // case 3: 7 bit correct even parity good stop
   ////////////////////////////////////////////
   #10000
   switches = 8'hB4;  //7 bit even parity 7E1
   rst = 1;
   #100
   rst = 0;
   #10000
   RX = 1;
   i = 0 ;
   #100
   for (i=0;i<8;i=i+1)
      begin
      #1085
      RX = ~RX;
      end  
   end 

endmodule
