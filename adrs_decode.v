`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  adrs_decode.v                                    //
//                                                               // 
//  Created by       Nguyen Doan on 3/31/2020	                 //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//
module adrs_decode(port_id, read_strobe, write_strobe, writes,
                   reads);
    input       [15:0]      port_id;
    input                   write_strobe, read_strobe;
    output       [7:0]      writes, reads;
    
    reg          [7:0]      writes, reads;
   
    always @(*) 
        casex ({port_id[15],write_strobe,port_id[2:0]})
            5'b1_?_???: writes = 8'b0000_0000; 
            5'b0_1_000: writes = 8'b0000_0001;
            5'b0_1_001: writes = 8'b0000_0010;
            5'b0_1_010: writes = 8'b0000_0100; 
            5'b0_1_011: writes = 8'b0000_1000; 
            5'b0_1_100: writes = 8'b0001_0000;
            5'b0_1_101: writes = 8'b0010_0000;
            5'b0_1_110: writes = 8'b0100_0000;
            5'b0_1_111: writes = 8'b1000_0000;
            default: writes = 8'b0; 
        endcase 
     
    always @(*)
        casex ({port_id[15],read_strobe,port_id[2:0]})
            5'b1_?_???: reads = 8'b0000_0000; 
            5'b0_1_000: reads = 8'b0000_0001;
            5'b0_1_001: reads = 8'b0000_0010;
            5'b0_1_010: reads = 8'b0000_0100; 
            5'b0_1_011: reads = 8'b0000_1000; 
            5'b0_1_100: reads = 8'b0001_0000;
            5'b0_1_101: reads = 8'b0010_0000;
            5'b0_1_110: reads = 8'b0100_0000;
            5'b0_1_111: reads = 8'b1000_0000;
            default: reads = 8'b0; 
        endcase
       
endmodule