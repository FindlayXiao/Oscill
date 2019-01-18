module Oscill_top(
	input clk,
	input rst_n,
	input [7:0] ad_data_in,
	input [1:0] size_cg,
	input 		cs_cursor,
	input		move_cursor,
	
	output hs_o,
	output vs_o,
	output [15:0] rgb_o,
	output clk_125M,
	output clk_32M,
	output [7:0] da_data_o,

	output flag
);

parameter   H_DISP  = 12'd800 , 
            H_FRONT = 12'd40  ,      
            H_SYNC  = 12'd128 ,    
            H_BACK  = 12'd88  ,      
            H_TOTAL = 12'd1056,

            V_DISP  = 12'd600, 
            V_FRONT = 12'd1  ,    
            V_SYNC  = 12'd4  ,     
            V_BACK  = 12'd23 ,    
            V_TOTAL = 12'd628;

parameter	RED    = 16'hF800,   //11111_000000_00000 
			GREEN  = 16'h07E0,   //00000_111111_00000 
			BLUE   = 16'h001F,   //00000_000000_11111 
			WHITE  = 16'hFFFF,   //11111_111111_11111 
			BLACK  = 16'h0000,   //00000_000000_00000 
			YELLOW = 16'hFFE0,   //11111_111111_00000 
			MAGENTA= 16'hF81F,   //11111_000000_11111 
			CYAN   = 16'h07FF,   //00000_111111_11111 
			
			DATA_WIDTH = 10'd512;

wire [11:0] xpos;
wire [11:0] ypos;
wire [15:0] rgb_data;
wire clk_40M;

wire [15:0] data_wave;
wire [15:0] data_grid;
wire [15:0] data_char;
wire [15:0] data_rd;
wire wave_valid;

assign flag = da_data_o ? 1'b0 : 1'b1 ;

assign rgb_data = wave_valid ? data_wave : (data_grid | data_char | data_rd);

pll_display pd_u1(
	.inclk0(clk),
	.c0(clk_40M)
);

pll_adda pa_u1(
	.inclk0(clk),
	.c0(clk_32M),
	.c1(clk_125M)
);

grid_vga gv_u1(
	.clk_grid(clk_40M),
	.rst_n_grid(rst_n),
	.xpos_grid(xpos),
	.ypos_grid(ypos),
	.color_grid(WHITE),
	.color_back(BLUE),

	.data_grid(data_grid)
);

driver_vga dv_u1(
	.clk_vga_driver(clk_40M),
	.rst_n_driver(rst_n),
	.data_vga_driver(rgb_data),

	.rgb_vga_driver(rgb_o),
	.hs_vga_driver(hs_o),
	.vs_vga_driver(vs_o),
	.xpos_vga_driver(xpos),
	.ypos_vga_driver(ypos)
);

wire [7:0] ad_vga_data;
wire 	   data_en;

data_process dp_u1(
	.clk_dp(clk_40M),
	.clk_ad(clk_32M),
	.rst_dp_n(rst_n),
	.ad_data(ad_data_in),	
	.xpos_dp(xpos),	

	.ad_vga_data(ad_vga_data), //max:256 
	.data_en(data_en),
	.data_vff(data_vff),
	.data_freq(data_freq)
);

wave_vga wv_u1(
	.clk_wave(clk_40M),
	.rst_n_wave(rst_n),
	.xpos_wave(xpos),
	.ypos_wave(ypos),
	.color_wave(YELLOW),
	.color_cursor(RED),
	.data(ad_vga_data),
	.data_en(data_en),
	.size_cg(size_cg),
	.cs_cursor(cs_cursor),
	.move_cursor(move_cursor),	

	.data_wave(data_wave),
	.data_T(data_T),
	.data_V(data_V),
	.wave_valid(wave_valid)
);

//++++++++++++++++++++++++++
//D2A
//++++++++++++++++++++++++++
reg [8:0] rom_da_addr;
always @(posedge clk_125M)
begin 
	rom_da_addr <= rom_da_addr + 1'b1;
end

rom_sin rs_u1(
	.address(rom_da_addr),
	.clock(clk_125M),
	.q(da_data_o)
);

//++++++++++++++++++++++++++++
//char
//++++++++++++++++++++++++++++

char_vga cv_u1(
	.clk_char(clk_40M),
    .rst_n_char(rst_n),
    .xpos_char(xpos),  
    .ypos_char(ypos),  
	.color_char(YELLOW),    
    .data_char(data_char)  
);

wire [11:0] data_vff;
wire [19:0] data_freq;
wire [15:0] data_T;
wire [15:0] data_V;

result_display rd_u1(
	.clk_rd(clk_40M),
	.rst_n_rd(rst_n),

	.data_vff(data_vff),
	.data_freq(data_freq),
	.data_T(data_T),
	.data_V(data_V),

	.xpos_rd(xpos),  
    .ypos_rd(ypos),  
	.color_rd(YELLOW),

	.data_rd(data_rd)
);

endmodule 