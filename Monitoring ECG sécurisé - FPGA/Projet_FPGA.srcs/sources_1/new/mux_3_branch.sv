`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2026 16:40:27
// Design Name: 
// Module Name: mux_3_branch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_3_branch(
    input logic [1:0] selecteur_i,
    input logic [63:0] cipher_i, 
    input logic [127:0] tag_i,
    output logic [63:0] sortie_o
    );
    
    always_comb begin
       case(selecteur_i)
       2'b00 : sortie_o = cipher_i;
       2'b01 :sortie_o = tag_i[127:64];
       2'b10 : sortie_o = tag_i[63:0];
       default : sortie_o = cipher_i;
        endcase
    end
    
endmodule :mux_3_branch
