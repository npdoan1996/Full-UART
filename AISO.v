`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  AISO.v                                           //
//                                                               // 
//  Created by       Nguyen Doan on 9/6/2019	                 //
//  Copyright @ 2019 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//


module AISO(reset, clk, reset_S);
    input           reset, clk;
    output  wire    reset_S;
    reg             Qmeta, Qok;
    
    always @ (posedge reset, posedge clk)
        begin 
        if (reset) {Qmeta,Qok}  <= 2'b0;
        else       {Qmeta,Qok} <= {1'b1,Qmeta};
        end
        
    assign reset_S = ~Qok;
endmodule
