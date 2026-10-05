`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2026 14:06:37
// Design Name: 
// Module Name: compteur
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


module compteur(
    input logic clock_i,
    input logic resetb_i,
    input logic en_cpt_i,
    input logic init_cpt_i,
    
    output logic [4:0] cpt_o
    );
    
    logic [4:0] cpt_s;

    always_ff @(posedge clock_i or negedge resetb_i) begin
        if (resetb_i == 1'b0) begin
            cpt_s <= 0;
        end else begin
        if (en_cpt_i == 1'b1) begin
            if (init_cpt_i == 1'b1) begin
                cpt_s <= 0;
            end
            else cpt_s <= cpt_s + 1;
                end
        end
  end

  assign cpt_o = cpt_s;
endmodule