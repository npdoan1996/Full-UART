`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  SRflop.v                                         //
//                                                               // 
//  Created by       Nguyen Doan on 2/16/2020                    //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//


module SRflop(rst, clk, set, reset, Q);
    input       rst, clk;
    input       set, reset;
    output      Q;
    
    reg         Q;
    
    always @(posedge rst, posedge clk)
        if(rst) 
            Q <= 0; 
        else if (reset) 
            Q <= 1'b0;
        else if (set) 
            Q <= 1'b1;
        else    
            Q <= Q;
            
endmodule
