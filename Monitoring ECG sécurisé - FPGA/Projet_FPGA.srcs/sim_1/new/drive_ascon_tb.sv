`timescale 1ns / 1ps

import ascon_pack::*;

module drive_ascon_tb();

    // Horloge & Reset 
    logic        clock_s;
    logic        resetb_s;

    // Key / Nonce
    logic [127:0] key_s;
    logic [127:0] nonce_s;
    logic         en_key_s   = 1'b0;
    logic [4:0]   en_nonce_s = 1'b0;
    logic [4:0]   entree_key_s   = '0;
    logic         entree_nonce_s = '0;

    // Contrôle top-level 
    logic        start_s;

    // Signaux de fin ASCON vers drive_ascon 
    logic        end_initialisation_s;
    logic        end_associate_s;
    logic        end_cipher_s;
    logic        end_tag_s;
 
    logic [4:0]  cpt_s;

    // Sorties drive_ascon 
    logic        init_s;
    logic        data_valid_s;
    logic        associate_data_s;
    logic        finalisation_s;
    logic        en_cpt_s;
    logic        init_cpt_s;
    logic        end_s;

    // Sorties ASCON 
    logic [63:0]  cipher_s;
    logic         cipher_valid_s;
    logic [127:0] tag_s;

    // RAM écriture UART / lecture vers ASCON - côté A
    logic        en_ram_uart_s  = 1'b1;   // port A toujours actif
    logic        we_uart_s      = 1'b0;
    // on sépare les adresses d'écriture et de lecture 
    logic [5:0]  addr_uart_write_s = '0;
    logic [5:0]  addr_uart_s;             
    logic [63:0] data_s         = '0;
    logic [63:0] data_out_uart_s;

    // RAM écriture cipher/tag par ASCON - côté B
    // en_ram_cipher_s toujours actif
    // we_en_cipher_s piloté par cipher_valid_s
    logic en_ram_cipher_s;
    logic [0:0]  we_en_cipher_s;
    logic [5:0]  addr_cipher_s  = '0;     // non utilisé ici, addr_cipher_s  = cpt_s
    logic [63:0] data_in_cipher_s;
    logic [63:0] data_out_cipher_s;
    logic [1:0]  selecteur_s;
    // Donnée envoyée à ASCON 
    logic [63:0] data_in_ascon;
    // Donnée en sortie de la mémoire est toujours en entrée d'ascon
    assign data_in_ascon = data_out_uart_s;

    // pendant l'écriture UART on choisit addr_uart_write_s, sinon on suit cpt_s pour que la lecture soit synchrone
    assign addr_uart_s = we_uart_s ? addr_uart_write_s : {1'b0, cpt_s};

    
    assign en_ram_cipher_s = 1'b1;// en_ram_cipher_s toujours actif

    assign we_en_cipher_s = cipher_valid_s; // on autorise l'écriture lorsque on a la confirmation que le cipher est valide 

    const logic [0:23][63:0] trame_c = '{
        64'h41_20_74_6F_20_42_80_00,
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
        64'h58_57_54_52_52_80_00_00
    };


    ascon DUT (
        .clock_i            (clock_s),
        .reset_i            (~resetb_s),
        .init_i             (init_s),
        .associate_data_i   (associate_data_s),
        .finalisation_i     (finalisation_s),
        .data_i             (data_in_ascon),
        .data_valid_i       (data_valid_s),
        .key_i              (key_s),
        .nonce_i            (nonce_s),
        .end_associate_o    (end_associate_s),
        .cipher_o           (cipher_s),
        .cipher_valid_o     (cipher_valid_s),
        .tag_o              (tag_s),
        .end_tag_o          (end_tag_s),
        .end_initialisation_o(end_initialisation_s),
        .end_cipher_o       (end_cipher_s)
    );

    compteur dut_cpt (
        .clock_i    (clock_s),
        .resetb_i   (resetb_s),
        .en_cpt_i   (en_cpt_s),
        .init_cpt_i (init_cpt_s),
        .cpt_o      (cpt_s)
    );

   drive_ascon dut_drive_ascon (
        .clock_i             (clock_s),
        .resetb_i            (resetb_s),
        .start_i             (start_s),

        .end_initialisation_i(end_initialisation_s),
        .end_associate_i     (end_associate_s),
        .end_cipher_i        (end_cipher_s),
        .end_tag_i           (end_tag_s),

        .cpt_i               (cpt_s),

        .init_o              (init_s),
        .data_valid_o        (data_valid_s),
        .associate_data_o    (associate_data_s),
        .finalisation_o      (finalisation_s),
        .en_cpt_o            (en_cpt_s),
        .init_cpt_o          (init_cpt_s),
        .end_o               (end_s),

        .we_cipher_o(we_cipher_s),
        .addr_cipher_o(addr_cipher_s), 
        .selecteur_o(selecteur_s),
        .en_ram_cipher_o(en_ram_cipher_s)
    );

    // KEY  (choix_i=1 - Key)
    data_reg reg_key (
        .clock_i  (clock_s),
        .resetb_i (resetb_s),
        .data_i   (entree_key_s),
        .en_i     (en_key_s),
        .choix_i  (1'b1),
        .data_o   (key_s)
    );

    // NONCE (choix_i=0 - Nonce)
    data_reg reg_nonce (
        .clock_i  (clock_s),
        .resetb_i (resetb_s),
        .data_i   (entree_nonce_s),
        .en_i     (en_nonce_s),
        .choix_i  (1'b0),
        .data_o   (nonce_s)
    );

    // RAM True Dual-Port :
    //   Port A = écriture trame (UART) + lecture vers ASCON
    //   Port B = écriture cipher/tag depius par ASCON
 blk_mem_gen_0 ram (
        .clka  (clock_s),
        .ena   (en_ram_uart_s),
        .wea   (we_uart_s),
        .addra (addr_uart_s),      
        .dina  (data_s),
        .douta (data_out_uart_s),

        .clkb  (clock_s),
        .enb   (en_ram_cipher_s),  
        .web   (we_en_cipher_s),   
        .addrb (addr_cipher_s),
        .dinb  (data_in_cipher_s),
        .doutb (data_out_cipher_s)
    );

    // Mux : envoie cipher ou tag selon la valeur du compteur
    mux_3_branch mux_cipher (
        .selecteur_i (selecteur_s),
        .cipher_i    (cipher_s),
        .tag_i       (tag_s),
        .sortie_o    (data_in_cipher_s)
    );

    
    // Horloge 50 MHz (période 20 ns)
    initial begin
        clock_s = 1'b0;
        forever #10 clock_s = ~clock_s;
    end

  
    // Chargement de la trame dans la mémoire

    initial begin
        we_uart_s        = 1'b0;
        addr_uart_write_s = '0;
        data_s           = '0;
        en_ram_cipher_s = 1'b1;
        // Attendre la fin du reset (40 ns)
        #40;
        $display("Reset terminé, chargement de la trame en RAM");

        for (int i = 0; i < 24; i++) begin
            @(posedge clock_s);
            data_s            = trame_c[i];
            we_uart_s         = 1'b1;
            addr_uart_write_s = 6'(i);
            @(posedge clock_s);
        end
        we_uart_s         = 1'b0;
        addr_uart_write_s = '0;
        $display("Trame chargée en RAM. \n");
    end

    // Reset + démarrage ASCON

    initial begin
        resetb_s = 1'b0;
        start_s  = 1'b0;
        #20;
        resetb_s = 1'b1;

        // Délai attente fin chargement chargement RAM (24*2 cycles + marge)
        #1000 ; //* 20 * 2 + 40);

        $display("Démarrage ASCON...");
        @(posedge clock_s);
        start_s = 1'b1;
        @(posedge clock_s);
        start_s = 1'b0;

        // Attente fin de chiffrement
        @(posedge clock_s iff (end_s == 1'b1));
        $display("Chiffrement terminé.");
        $display(" Tag = %h", tag_s);

        // Lire les blocs cipher en RAM 
        $display("Lecture des blocs cipher en RAM :");
        for (int j = 25; j <= 48; j++) begin
            addr_cipher_s = j;
            @(posedge clock_s);
            $display("  Bloc[%d] = %h", j, data_out_cipher_s);
        end

        $finish;
    end

endmodule : drive_ascon_tb
