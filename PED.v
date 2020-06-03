`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  PED.v                                            //
//                                                               // 
//  Created by       Nguyen Doan on 9/6/2019	                 //
//  Copyright @ 2018 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//


module PED(reset, clk, in, ped);
    
input           clk, reset, in;
output          ped;

reg             q1, q2;
reg             nq1, nq2;
  
////////////////////////////////////////
// continuous assignment for ped      //
////////////////////////////////////////
assign ped = q1 & ~q2;

////////////////////////////////////////
// combination logiic clock           //
////////////////////////////////////////
always @(*)
    begin 
    nq1 = in;
    nq2 = q1;
    end 
    
////////////////////////////////////////
// sequential logic block             //
////////////////////////////////////////
always @(posedge clk, posedge reset)
    if (reset) {q1,q2} <= 2'b0;
    else     {q1,q2} <= {nq1,nq2};
 
endmodule
