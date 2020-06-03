`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  baud_decode.v                                    //
//                                                               // 
//  Created by       Nguyen Doan on 2/28/2020	                 //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//

module baud_decode(clk, rst, baud_control, baud_rate);
    input           clk, rst;
    input    [3:0]  baud_control; 
    output  [18:0]  baud_rate;
    
    reg     [18:0]  baud_rate;
    
    always @(*)
        case(baud_control)
            4'b0000: baud_rate = 19'd333_333;
            4'b0001: baud_rate = 19'd83_333;
            4'b0010: baud_rate = 19'd41_667;
            4'b0011: baud_rate = 19'd20_833;
            4'b0100: baud_rate = 19'd10_417;
            4'b0101: baud_rate = 19'd5_208;
            4'b0110: baud_rate = 19'd2_604;
            4'b0111: baud_rate = 19'd1_736;
            4'b1000: baud_rate = 19'd868;
            4'b1001: baud_rate = 19'd434;
            4'b1010: baud_rate = 19'd217;
            4'b1011: baud_rate = 19'd109;
            default: baud_rate = 19'd10_417;
        endcase
            
endmodule
