`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2026 14:40:26
// Design Name: 
// Module Name: data_reg
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

module data_reg
(
    input  logic              clock_i,   //main clock
    input  logic              resetb_i,  //asynchronous reset active low
    input  logic [4:0]        data_i,
    input  logic              en_i,
    input  logic              choix_i, // choix_i = 0 - key / choix_i = 1 - nonce
    output logic [127:0]      data_o
);
  logic [127:0] data_s;

  always_ff @(posedge clock_i or negedge resetb_i) begin : seq_0
    if (resetb_i == 1'b0) begin
    if (choix_i == 1'b1)
    data_s <= 128'h8A55114D1CB6A9A2_BE263D4D7AECAAFF;
    else 
    data_s <= 128'h4ED0EC0B98C529B7_C8CDDF37BCD0284A;
    end 
    
    else begin
      if (en_i == 1'b1) begin
//        if (init_i == 1'b1) begin
//          data_s <= '0;
//        end else begin
          data_s <= {data_s[128:0], data_i};
//        end
      end else begin
        data_s <= data_s;
      end
    end
  end : seq_0
  assign data_o = data_s;

endmodule : data_reg
