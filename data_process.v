module data_process(
	input 				clk_dp,
	input				clk_ad,
	input 				rst_dp_n,
	input 		 [7:0]	ad_data,	
	input		 [11:0] xpos_dp,	

	output		 [7:0]	ad_vga_data, //max:256 
	output 	reg			data_en,
	output		 [11:0] data_vff,
    output  	 [19:0] data_freq	
);

parameter IDLE  = 2'b00, 
		  WR_RD = 2'b10,
//		  TEST  = 2'b11,

		  TRIGGER    = 8'd128,	//trigger 0V
		  DATA_WIDTH = 10'd512, 

		  BORDER_WIDTH  = 12'd44 ,
		  SCREEN_WIDTH  = 12'd512,
		  SCREEN_LENGTH = 12'd640,
		  WORD_AREA     = 12'd72 ,	
		  UNIT_WIDTH    = 12'd64 ,

		  H_DISP  = 12'd800 ,     
          V_DISP  = 12'd600 ;

//++++++++++++++++++++++++++++++
//Verse_state
//++++++++++++++++++++++++++++++
reg [1:0] state;
wire posedge_ad_data;

reg [7:0] ad_data_r;
always @(posedge clk_ad or negedge rst_dp_n) begin
	if (!rst_dp_n) begin
		ad_data_r <= 0;
	end
	else begin
		ad_data_r <= ad_data;
	end
end

assign posedge_ad_data = (ad_data_r < ad_data) ? 1'b1 : 1'b0;

always @(posedge clk_ad or negedge rst_dp_n) begin
	if (!rst_dp_n) begin
		state <= 0;
		data_en <= 1'b0;
	end
	else begin
		case(state)
			IDLE: if (ad_data == TRIGGER && posedge_ad_data) begin
				state <= WR_RD;
				data_en <= 1'b1;
			end
			WR_RD:	if (ad_vga_addr == DATA_WIDTH - 1) begin
				state <= IDLE;
				data_en <= 1'b0;
			end
		endcase
	end
end

//++++++++++++++++++++++++++++++
//freq
//++++++++++++++++++++++++++++++
reg [8:0]	pos  ;
reg [1:0]	state_freq;

always @(posedge clk_ad or negedge rst_dp_n) begin
	if (!rst_dp_n) begin
		pos   <= 9'd0; 
		state_freq <= 2'b00;
	end
	else begin
		case(state_freq)
			2'b00:	if (ad_data == TRIGGER && posedge_ad_data && state == IDLE) begin
				pos <= pos;
				state_freq <= 2'b01;
			end
			2'b01:	if (!posedge_ad_data) begin
				pos <= pos;
				state_freq <= 2'b11;
			end	
			2'b11:	if (ad_data >= TRIGGER && posedge_ad_data) begin
				pos <= ad_vga_addr;
				state_freq <= 2'b00;
			end
			default: state_freq <= 2'b00;
		endcase
	end
end

wire [19:0] freq_result;
//assign freq_result = 32000 * cnt / pos; 
assign freq_result = ad_data ? 32000 / pos : 20'd0;

bin2BCD bB_u1(
//	.in_bin(data_div[23:4]) ,
	.in_bin(freq_result),

	.ten_thou(data_freq[19:16]),
	.thou(data_freq[15:12]),
	.hun (data_freq[11:8]),
	.ten (data_freq[7:4]),
	.unit(data_freq[3:0]) 
);

//+++++++++++++++++++++++++++++
//Vff
//+++++++++++++++++++++++++++++
wire   [7:0] 	addr;
reg   [7:0]		max_data;
reg   [7:0]    	max_data_r;
reg   [7:0]		min_data;
reg   [7:0]     min_data_r;
wire  [15:0] 	data_rom;

always @(posedge clk_ad or negedge rst_dp_n) begin
	if (!rst_dp_n) begin
		max_data_r <= 8'b0;
		max_data <= 8'b0;
	end
	else if (data_en == 1'b0 && max_data_r > 8'b0) begin 
		max_data <= max_data_r;
		max_data_r <= 8'b0;
	end
	else if (data_en == 1'b1 && ad_data > max_data_r) begin
		max_data_r <= ad_data;
		max_data <= max_data;
	end
	else begin
		max_data_r <= max_data_r;
		max_data <= max_data;
	end
end

always @(posedge clk_ad or negedge rst_dp_n) begin
	if (!rst_dp_n) begin
		min_data_r <= 8'b0;
		min_data <= 8'b0;
	end
	else if (data_en == 1'b0 && min_data_r < 8'd255) begin
		min_data <= min_data_r;
		min_data_r <= 8'd255;
	end
	else if (data_en == 1'b1 && ad_data < min_data_r) begin
		min_data_r <= ad_data;
		min_data <= min_data;
	end
	else begin
		min_data_r <= min_data_r;
		min_data <= min_data;
	end
end

assign addr = max_data - min_data;

assign data_rom = addr * 13 / 2;
/*
rom_256to10 u1(
	.address(addr),
	.clock(clk_ad),
	.q(data_rom)
);
*/

bin2BCD bB_u2(
	.in_bin({8'd0,data_rom[15:4]}),

	.ten_thou(),
	.thou(),
	.hun (data_vff[11:8]),
	.ten (data_vff[7:4]) ,
	.unit(data_vff[3:0]) 
);

//++++++++++++++++++
//ad_vag_addr
//++++++++++++++++++
wire wr_en;

reg [8:0] ad_vga_addr;
reg [8:0] ad_vga_addr_n;

always @(posedge clk_ad or negedge rst_dp_n)
begin 
	if(!rst_dp_n) begin
		ad_vga_addr <= 9'd0; 
	end
	else if(state == WR_RD && ad_vga_addr < DATA_WIDTH) begin
		ad_vga_addr <= ad_vga_addr + 1'b1;
	end
	else begin
//		ad_vga_addr <= ad_vga_addr;
		ad_vga_addr <= 9'd0;
	end
end

assign wr_en   = (state == WR_RD) ? 1'b1 : 1'b0;

//512*8
data_ram  data_ram_u0(
	.data(ad_data),
	.rdaddress(xpos_dp[8:0] - BORDER_WIDTH[8:0]),
	.rdclock(clk_dp),
	.rden(data_en),

	.wraddress(ad_vga_addr),
	.wrclock(clk_ad),
	.wren(wr_en),

	.q(ad_vga_data)
);

endmodule 
