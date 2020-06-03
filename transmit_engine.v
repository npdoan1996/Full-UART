`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  transmit_engine.v                                //
//                                                               // 
//  Created by       Nguyen Doan on 2/28/2020	                 //
//  Copyright @ 2020 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work        	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//

module transmit_engine(clk, rst, write, out_port, eight, pen, ohel, 
		       baud_decode, TxRdy, Tx);
    input           clk, rst; 
    input           write, eight, pen, ohel;
    input  [18:0]   baud_decode;
    input   [7:0]   out_port; 
    output          TxRdy, Tx;
    
    reg             TxRdy, doit;
    reg    [18:0]   count, n_count;
    reg     [3:0]   bit_count, n_bit_count;
    reg     [7:0]   out_port_reg;
    reg             write_reg;
    reg             b9, b10;
    reg    [10:0]   shift_reg;
    
    wire            done, btu;
    wire            EP, OP;
    
    // SR flop for TxRdy
    always @(posedge rst, posedge clk)
        if (rst) 
            TxRdy <= 1'b1;
        else if (done == 1'b1)
            TxRdy <= 1'b1;
        else if (write == 1'b1) 
            TxRdy <= 1'b0;
        else    
            TxRdy <= TxRdy;
   
    // SR flop for doit         
    always @(posedge rst, posedge clk)
        if (rst) 
            doit <= 1'b0;
        else if (write == 1'b1)
            doit <= 1'b1;
        else if (done == 1'b1) 
            doit <= 1'b0;
        else    
            doit <= doit;
            
    // Bit time counter
    always @(posedge rst, posedge clk)
        if(rst)             
            count <= 19'b0;
        else    
            count <= n_count; 
 
    always @(*)
        casex ({doit,btu})
            2'b0?:      n_count = 19'b0;
            2'b10:      n_count = count + 1;
            2'b11:      n_count = 19'b0;
            default:    n_count = 19'b0;
        endcase
    
    assign btu = (count == baud_decode)? 1'b1 : 1'b0;
  
  
    // Bits counter
    always @(posedge rst, posedge clk)
        if(rst)             
            bit_count <= 4'b0;
        else    
            bit_count <= n_bit_count; 
 
    always @(*)
        casex ({doit,btu})
            2'b0?:      n_bit_count = 4'b0;
            2'b10:      n_bit_count = bit_count;
            2'b11:      n_bit_count = bit_count + 1;
            default:    n_bit_count = 4'b0;
        endcase
    
    assign done = (bit_count == 4'd11)? 1'b1 : 1'b0;  
    
    // loadable register for out_port 
    always @(posedge clk, posedge rst) 
        if(rst)
            out_port_reg <= 8'b0;
        else if (write)
            out_port_reg <= out_port; 
        else 
            out_port_reg <= out_port_reg; 
      
    // flop to hold write signal one more clock 
    
    always @(posedge clk, posedge rst)
        if(rst)
            write_reg <= 1'b0;
        else
            write_reg <= write;
            
    // Decoder for bit10 and bit9
    always @(*)
        casex({eight,pen,ohel})
            3'b00?:  {b10,b9} = 2'b11;
            3'b010:  {b10,b9} = {1'b1,EP};
            3'b011:  {b10,b9} = {1'b1,OP};
            3'b10?:  {b10,b9} = {1'b1, out_port_reg[7]};
            3'b110:  {b10,b9} = {EP, out_port_reg[7]};
            3'b111:  {b10,b9} = {OP, out_port_reg[7]};
            default: {b10,b9} = 2'b11;
        endcase
    
    // Parity bit 
    assign EP = eight? ^out_port_reg : ^out_port_reg[6:0];
    assign OP = eight? !(^out_port_reg) : !(out_port_reg[6:0]);
    
    // Shift register
    always @(posedge clk, posedge rst) 
        if(rst)
            shift_reg <= 11'h7FF;
        else if (write_reg) 
            shift_reg <= {b10,b9,out_port_reg[6:0],1'b0,1'b1};
        else if (btu)
            shift_reg <= {1'b1,shift_reg[10:1]};
        else 
            shift_reg <= shift_reg; 
             
    assign Tx = shift_reg[0];
    
endmodule
