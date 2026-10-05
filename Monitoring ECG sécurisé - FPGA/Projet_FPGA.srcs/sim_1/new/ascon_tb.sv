//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2026 15:18:31
// Design Name: 
// Module Name: ascon_tb
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
`timescale 1ns / 1ps
import ascon_pack::*;

module ascon_tb(
 
    );
    
    // Déclaration de l'ensemble des variables pour piloter 
    // variables for inputs
    logic         clock_s;
    logic         reset_s;
    logic         init_s;
    logic         associate_data_s;
    logic         finalisation_s;
    logic [ 63:0] data_s;
    logic         data_valid_s;
    logic [127:0] key_s;
    logic [127:0] nonce_s;
    //logic [180:0] plain_text_s;
    logic[0:22][63:0] trame_c;
    // variables for outputs
    logic         end_associate_s;
    logic [ 63:0] cipher_s;
    logic         cipher_valid_s;
    logic [127:0] tag_s;
    logic         end_tag_s;
    logic         end_snitialisation_s;
    logic         end_cipher_s;
 // instance du circuit à simuler 
   
    ascon DUT(
     // variables for inputs
        .clock_i(clock_s),
        .reset_i(reset_s),
        .init_i(init_s),
        .associate_data_i(associate_data_s),
        .finalisation_i(finalisation_s),
        .data_i(data_s),
        .data_valid_i(data_valid_s),
        .key_i(key_s),
        .nonce_i(nonce_s),
        
        .end_associate_o(end_associate_s),
        .cipher_o(cipher_s),
        .cipher_valid_o(cipher_valid_s),
        .tag_o(tag_s),
        .end_tag_o(end_tag_s),
        .end_initialisation_o(end_initialisation_s),
        .end_cipher_o(end_cipher_s));
    
    initial begin 
    clock_s = 1'b0;
        forever #10 clock_s = ~clock_s; // période de 20 nano pour avoir une horloge à 50MHz
    end
    
    initial begin
    // affectation des variables internes à des variables par défaut
    reset_s = 1'b0; 
    init_s = 1'b0; 
    key_s = 128'h8A55114D1CB6A9A2_BE263D4D7AECAAFF;
    nonce_s = 128'h4ED0EC0B98C529B7_C8CDDF37BCD0284A;
    trame_c = { 
        64'h5A_5B_5B_5A_5A_5A_5A_5A,
        64'h59_55_4E_4A_4C_4F_54_55,
        64'h53_51_53_54_56_57_58_57,
        64'h5A_5A_59_57_56_59_5B_5A,
        64'h55_54_54_52_52_50_4F_4F,
        64'h4C_4C_4D_4D_4A_49_44_44,
        64'h47_47_46_44_42_43_41_40,
        64'h3B_36_38_3E_44_49_49_47,
        64'h47_46_46_44_43_42_43_45,
        64'h47_45_44_45_46_47_4A_49,
        64'h47_45_48_4F_58_69_7C_92,
        64'hAE_CE_ED_FF_FF_E3_B4_7C,
        64'h47_16_00_04_17_29_36_3C,
        64'h3F_3E_40_41_41_41_40_3F,
        64'h3F_40_3F_3E_3B_3A_3B_3E,
        64'h3D_3E_3C_39_3C_41_46_46,
        64'h46_45_44_47_46_4A_4C_4F,
        64'h4C_50_55_55_52_4F_51_55,
        64'h59_5C_5A_59_5A_5C_5C_5B,
        64'h59_59_57_53_51_50_4F_4F,
        64'h53_57_5A_5C_5A_5B_5D_5E,
        64'h60_60_61_5F_60_5F_5E_5A,
        64'h58_57_54_52_52_80_00_00};


    
    //plain_text_s = 181'h5A_5B_5B_5A_5A_5A_5A_5A_59_55_4E_4A_4C_4F_54_55_53_51_53_54_56_57_58_57_5A_5A_59_57_56_59_5B_5A_55_54_54_52_52_50_4F_4F_4C_4C_4D_4D_4A_49_44_44_47_47_46_44_42_43_41_40_3B_36_38_3E_44_49_49_47_47_46_46_44_43_42_43_45_47_45_44_45_46_47_4A_49_47_45_48_4F_58_69_7C_92_AE_CE_ED_FF_FF_E3_B4_7C_47_16_00_04_17_29_36_3C_3F_3E_40_41_41_41_40_3F_3F_40_3F_3E_3B_3A_3B_3E_3D_3E_3C_39_3C_41_46_46_46_45_44_47_46_4A_4C_4F_4C_50_55_55_52_4F_51_55_59_5C_5A_59_5A_5C_5C_5B_59_59_57_53_51_50_4F_4F_53_57_5A_5C_5A_5B_5D_5E_60_60_61_5F_60_5F_5E_5A_58_57_54_52_52;
    
    associate_data_s = 1'b0;
    finalisation_s = 1'b0;
    data_valid_s = 1'b0;
    data_s = 64'h4120746F20428000; // padding
    
    // phase de reset 
    #40;
    reset_s = 1'b1; 
    #100;
    reset_s = 1'b0; 
    #20;
    
    // phase de démarrage de ascon (init_i = 1'b1) - Initialisation
    init_s = 1'b1;
    #20; 
    init_s = 1'b0;
    #20;
    wait(end_initialisation_s == 1'b1);
    $display("end of initialistion phase \n");
       
    #20; 
    //gestion de la donnée associée - Associated data
    data_valid_s = 1'b1; 
    associate_data_s = 1'b1; 
    #20; 
    data_valid_s = 1'b0; 
    associate_data_s = 1'b0;
    #20; 
    wait(end_associate_s == 1'b1);
    $display("end of associate phase \n");
    #20; 
    // plain text
    //on parcours le plain text pour le donner à ASCON par blocs de 64
    for( int i = 0; i < 22 ;  i++)
    begin 
        data_s = trame_c[i]; 
        data_valid_s = 1'b1;
        #20;
        data_valid_s = 1'b0;
       // wait(cipher_valid_s == 1'b1); 
        
        wait(end_cipher_s == 1'b1); 
         #20; 
        $display("Cipher %d  = %x", i, cipher_s);
    end 
    $display("end of plain text phase \n");
    
    // Finalisation
    
    data_valid_s = 1'b1;
    finalisation_s = 1'b1;
    data_s = trame_c[22];
    #20;
    data_valid_s = 1'b0;
    finalisation_s = 1'b0;
    wait(end_tag_s == 1'b1);
     
    $display("Cipher = %x", cipher_s);
    $display("Tag = %x", tag_s);
    $display("end of finalisation phase \n");
    $stop;  
    end
endmodule : ascon_tb
