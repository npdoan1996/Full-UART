`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  Rx_engine.v                                      //
//                                                               // 
//  Created by       Nguyen Doan on 3/24/2020	                 //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//
module Rx_engine(clk, rst, BAUD_DECODE, EIGHT, PEN, OHEL, RX, 
                 READS, UART_RDATA, PERR, FERR, OVF, RX_RDY);
    input           clk, rst;
    input  [18:0]   BAUD_DECODE;
    input           EIGHT, PEN, OHEL;
    input           RX; 
    input           READS;
    output  [7:0]   UART_RDATA; 
    output          RX_RDY;
    output          PERR, FERR, OVF;
    
    wire   [18:0]   K;
    wire            BTU, DONE; 
    wire            Gen_Parity1, Gen_Parity2, Re_Parity;
    wire            Parity_Error;
    
    reg     [3:0]   Q;
    reg     [1:0]   state, n_state; 
    reg             START, DOIT;
    reg    [18:0]   count, n_count;
    reg     [3:0]   bit_count, bit_count_n;
    reg     [9:0]   shift_reg, RJ_out;
    reg             PERR, FERR, OVF, RX_RDY;
    reg             Stop_Bit;
            
    // RECEIVE ENGINE CONTROL
    // State Machine
    always @(posedge clk, posedge rst) 
        if (rst) 
            state <= 2'b0;
        else
            state <= n_state;
            
    always @*
        case(state)
            2'b00: begin 
                   n_state = RX?  2'b00 : 2'b01;
                   {START,DOIT} = 2'b00;
                   end
            2'b01: begin
                   n_state = RX?  2'b00 : (BTU? 2'b10 : 2'b01);
                   {START,DOIT} = 2'b11; 
                   end
            2'b10: begin
                   n_state = DONE? 2'b00 : 2'b10;
                   {START,DOIT} = 2'b01;
                   end
            default: {n_state,START,DOIT} = 4'b0;
        endcase
    
    // Bit time Counter
    assign K = START? BAUD_DECODE>>1 : BAUD_DECODE; 
    always @(posedge rst, posedge clk) 
        if (rst)
            count <= 19'b0; 
        else   
            count <= n_count; 
            
    always @(*) 
        casex({DOIT,BTU})
            2'b0?: n_count = 19'b0;
            2'b10: n_count = count + 19'b1;
            2'b11: n_count = 19'b0;
            default: n_count = 19'b0; 
        endcase
    assign BTU = (count == K);
    
    // Bit Counter
    always @(*) 
        case({EIGHT,PEN})
            2'b00: Q = 4'd9;
            2'b01: Q = 4'd10; 
            2'b10: Q = 4'd10;
            2'b11: Q = 4'd11;
            default: Q = 4'd9;
        endcase
        
    always @(posedge clk, posedge rst) 
        if (rst)
            bit_count <= 4'b0; 
        else 
            bit_count <= bit_count_n;
    
    always @(*)
        casex({DOIT,BTU})
            2'b0?: bit_count_n = 4'd0;
            2'b10: bit_count_n = bit_count;
            2'b11: bit_count_n = bit_count + 4'b1; 
            default: bit_count_n = 4'd0;
        endcase
         
    assign DONE = (bit_count == Q); 
             
    // RECEIVE ENGINE DATA PATH 
    // Shift Register
    always @(posedge clk, posedge rst) 
        if (rst) 
            shift_reg <= 10'b0; 
        else if (BTU & ~START)
            shift_reg <= {RX,shift_reg[9:1]};
        else
            shift_reg <= shift_reg;      
      
    // Right Justify        
    always @(*)
        case({PEN,EIGHT}) 
            2'b00: RJ_out = {2'b0,shift_reg[9:2]}; 
            2'b01: RJ_out = {1'b0,shift_reg[9:1]}; 
            2'b10: RJ_out = {1'b0,shift_reg[9:1]};
            2'b11: RJ_out = shift_reg; 
            default: RJ_out  = 10'b0; 
        endcase   
    
    // Parity Error
    assign UART_RDATA =  RJ_out[7:0]; 
    assign Gen_Parity1 = EIGHT? ^RJ_out[7:0] : ^{1'b0,RJ_out[6:0]}; 
    assign Gen_Parity2 = OHEL? ~Gen_Parity1 : Gen_Parity1;
    assign Re_Parity = EIGHT? RJ_out[8] : RJ_out[7]; 
    assign Parity_Error  = PEN & DONE & (Gen_Parity2 ^ Re_Parity);
    
    always @(posedge clk, posedge rst)
        if (rst) 
            PERR <= 1'b0;
        else if (Parity_Error)
            PERR <= 1'b1;
        else if(READS) 
            PERR <= 1'b0;
        else 
            PERR <= PERR; 
    
    // Framing Error
    always @(*)
        case({EIGHT,PEN}) 
            2'b00: Stop_Bit = RJ_out[7];
            2'b01: Stop_Bit = RJ_out[8];
            2'b10: Stop_Bit = RJ_out[8];
            2'b11: Stop_Bit = RJ_out[9];
            default: Stop_Bit = 1'b0;
        endcase
        
    always @(posedge clk, posedge rst)
        if (rst) 
            FERR <= 1'b0; 
        else if (~Stop_Bit&DONE)
            FERR <= 1'b1;
        else if (READS)
            FERR <= 1'b0;
        else 
            FERR <= FERR; 
     
    reg         DONE_reg;     
    always @(posedge clk, posedge rst) 
        if (rst)
            DONE_reg <= 1'b0;
        else if (DONE) 
            DONE_reg <= 1'b0;
        else 
            DONE_reg <= DONE_reg;
            
    // Overflow error
    always @(posedge clk, posedge rst)
        if (rst) 
            OVF <= 1'b0;
        else if (DONE_reg & RX_RDY)
            OVF <= 1'b1; 
        else if (READS)
            OVF <= 1'b0;
        else
            OVF <= OVF;
            
    // RX_RDY
    always @(posedge clk, posedge rst) 
        if (rst) 
            RX_RDY <= 1'b0;
        else if (DONE)
            RX_RDY <= 1'b1;
        else if (READS)
            RX_RDY <= 1'b0;
        else 
            RX_RDY <= RX_RDY;
           
       
endmodule
