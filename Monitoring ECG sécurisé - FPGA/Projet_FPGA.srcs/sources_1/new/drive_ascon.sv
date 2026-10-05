`timescale 1ns / 1ps

import ascon_pack::*;
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 13:18:27
// Design Name: 
// Module Name: drive_ascon
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


module drive_ascon(
input  logic        clock_i,
input  logic        resetb_i,
input logic         start_i,

input logic         end_initialisation_i, 
input logic         end_associate_i,
input logic         end_cipher_i,
input logic         end_tag_i,

input  logic [4:0]  cpt_i, //

output logic        init_o,
output logic        data_valid_o,
output logic        associate_data_o,
output logic        finalisation_o,
output logic        en_cpt_o,
output logic        init_cpt_o,
output logic        end_o,

// Ecriture RAM - CIPHER/TAG - port b

output logic we_cipher_o,  
output logic [5:0] addr_cipher_o, 
output logic en_ram_cipher_o,

output logic [1:0] selecteur_o
    );
    
typedef enum{
    Idle,
    Conf_Cpt,
    Begin_Init,
    Init,
    Init_DA,
    DA,
    CPT,
    Init_PL,
    PL,
    End_PL, // 1er cycle d'horloge pour l'ecriture
    Write_PL, // Etat en plus car 2 cycles d'horloge pour d'ecriture
    Init_Fin, 
    Begin_Fin,
    Fin_Wait,
    Write_Tag_1_1, // Permière partie du tag 1er cycle d'horloge
    Write_Tag_1_2, // Premiere partie du tag 2eme cycle d'horloge
    Write_Tag_2_1, // 2eme partie du tag 1er cycle d'horloge
    Write_Tag_2_2, // 2eme partie du tag 2eme cycle d'h
    Fin
}state_t;

state_t state;
state_t next_state;

//logic [63:0] bloc_data_s; // Permet de sélectionner la tranche de la data qui sera donnée à ASCON
//always_comb begin
//    bloc_data_s = data_i[1471 - cpt_i*64 -: 64]; // Compteur permet de prendre à chaque fois le bloc de 64 suivant
//end

// Gestion du reset et changement d'état 
always_ff @(posedge clock_i or negedge resetb_i )begin
    if(resetb_i == 1'b0) 
        state <= Idle;
    else 
         state <= next_state; // pour ne pas mettre les else
end


// Transition entre les  différents états
// Signaux de contrôle
always_comb begin
    next_state = state;
    case (state) 
        Idle : 
            if (start_i == 1'b1) next_state = Conf_Cpt; 
        Conf_Cpt :
             next_state = Begin_Init; 
        Begin_Init : 
            next_state = Init; 
        Init : 
            if (end_initialisation_i== 1'b1) next_state = Init_DA ;
        Init_DA : 
            next_state = DA; 
        DA :
            if (end_associate_i == 1'b1) next_state = CPT; // incrémentation du compteur
        CPT : 
            next_state = Init_PL;
        Init_PL : 
            next_state = PL; 
        PL : 
            if(end_cipher_i == 1'b1) next_state = End_PL; 
        End_PL : next_state = Write_PL;
        Write_PL : if(cpt_i == 22) next_state = Init_Fin; //22
            else next_state = CPT; 
        Init_Fin :
            next_state = Begin_Fin;
        Begin_Fin :
            next_state = Fin_Wait;
       Fin_Wait : 
           if(end_tag_i == 1'b1) next_state = Write_Tag_1_1;  else next_state = Fin_Wait ;  
        
        Write_Tag_1_1 :  next_state = Write_Tag_1_2;
        Write_Tag_1_2 : next_state = Write_Tag_2_1;
        Write_Tag_2_1 : next_state = Write_Tag_2_2;
        Write_Tag_2_2 : next_state = Fin;
        Fin : 
            if(start_i == 1'b0) next_state = Idle; 
        default : next_state = Idle;
    endcase
end

// Ce qui se passe dans les différents états pour les signaux de travail
always_comb begin
// On assigne aux variables leurs valeurs par défaut et on ne change que celles qui bougent dans les états 
    init_o = 1'b0;
    data_valid_o = 1'b0;
    associate_data_o = 1'b0;
    finalisation_o = 1'b0;
    en_cpt_o = 1'b0;
    init_cpt_o = 1'b0;
    end_o = 1'b0;
    we_cipher_o      = 1'b0;
    en_ram_cipher_o = 1'b1;
    //addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
 
       

    case(state)
    
    Idle: addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i}; ; // Tout est à 0
    
    Conf_Cpt : begin
        init_cpt_o = 1'b1; 
        en_cpt_o = 1'b1;
        addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
        end
        
    Begin_Init : begin 
        init_o = 1'b1; 
        addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
        end
    
    Init : addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};; 
    
    Init_DA : begin
        data_valid_o = 1'b1;
        associate_data_o = 1'b1;
        addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
        end 
    
    DA : addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};;
    
    CPT : begin
        //associate_data_o = 1'b1;
        en_cpt_o = 1'b1;
        addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
        end
        
    Init_PL : begin
        data_valid_o = 1'b1;
        addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
    end        
    
    PL : addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};;
    
    End_PL :  begin
        we_cipher_o = 1'b1;
        selecteur_o = 2'b00;
        addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
    end
    Write_PL : 
        begin
         we_cipher_o = 1'b1;
         selecteur_o = 2'b00;
         addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
        end
    Init_Fin : begin
        en_cpt_o = 1'b1;
        addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
        end
     
    Begin_Fin : begin
        addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};
        data_valid_o = 1'b1;
        finalisation_o = 1'b1;
        end
        
    Fin_Wait : addr_cipher_o = cpt_i + 6'd23; // {1'b1, cpt_i};; 
    
    Write_Tag_1_1 : begin
            we_cipher_o   = 1'b1;
            addr_cipher_o = cpt_i + 6'd24;
            selecteur_o = 2'b01;
        end
 
        
    Write_Tag_1_2 : begin
            we_cipher_o   = 1'b1;
            addr_cipher_o = cpt_i + 6'd24; 
            selecteur_o = 2'b01;
        end

    Write_Tag_2_1 : begin
            we_cipher_o   = 1'b1;
            addr_cipher_o = cpt_i + 6'd25;
            selecteur_o = 2'b10;
        end
    
    Write_Tag_2_2 : begin
            we_cipher_o   = 1'b1;
            addr_cipher_o = cpt_i + 6'd25;
            selecteur_o = 2'b10;
        end
    
    
    Fin : 
        end_o = 1'b1;
        
    default : ;
    
    endcase 
end
endmodule : drive_ascon
