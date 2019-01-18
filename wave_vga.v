module wave_vga(
	input 				clk_wave,
	input				rst_n_wave,
	input		[11:0]	xpos_wave,
	input		[11:0]	ypos_wave,
	input		[15:0]  color_wave,
	input 		[15:0]  color_cursor,
	input		[7:0]	data,
	input				data_en,
	input		[1:0]	size_cg,	//1:h 0:v
	input 			  	cs_cursor,
	input			  	move_cursor,  

	output reg	[15:0]	data_wave,
	output	    [15:0]   data_V,
	output      [15:0]   data_T,
	output reg			wave_valid
);
parameter   H_DISP  = 12'd800 ,     
            V_DISP  = 12'd600 ;     

localparam 	BORDER_WIDTH  = 12'd44 ,
			SCREEN_WIDTH  = 12'd512,
			SCREEN_LENGTH = 12'd512,
			WORD_AREA     = 12'd200,	
			UNIT_WIDTH    = 12'd64 ,

			IDLE 	= 2'b00,
			JITTER1 = 2'b01,
			PRESSED = 2'b11,
			JITTER2 = 2'b10,

			T_CS_L = BORDER_WIDTH + 2 * UNIT_WIDTH, 
			T_CS_R = BORDER_WIDTH + 6 * UNIT_WIDTH,
			V_CS_U = BORDER_WIDTH + 2 * UNIT_WIDTH, 
			V_CS_D = BORDER_WIDTH + 6 * UNIT_WIDTH;

wire clk_10k;

pll_nsk pn_u1(
	.inclk0(clk_wave), //40M 
	.c0(clk_10k)
);

//+++++++++++++++++++++++++++++++++
//去抖动
//+++++++++++++++++++++++++++++++++
reg [1:0] state;
reg [7:0] cnt;        //200 * 0.0001s = 20ms
reg [1:0] size_cg_r;  
reg cs_r;
reg move_r;

always @(posedge clk_10k or negedge rst_n_wave) begin
	if (!rst_n_wave) begin
		state <= IDLE;
		cnt <= 8'd0;
		size_cg_r <= 2'b11;
		cs_r <= 1'd1;
		move_r <= 1'd1;
	end
	else begin
		case(state)
			IDLE:	
				if(size_cg != 2'b11 || cs_cursor == 1'b0 || move_cursor == 1'b0) begin
					state <= JITTER1;
				end
				else begin
					state <= IDLE;
				end
			JITTER1:
				if(cnt < 8'd200) begin
					cnt <= cnt + 8'd1;
				end
				else if(size_cg != 2'b11 || cs_cursor == 1'b0 || move_cursor == 1'b0) begin
					cnt <= 8'd0;
					state <= PRESSED;
					size_cg_r <= size_cg;
					cs_r <= cs_cursor;
					move_r <= move_cursor;
				end
				else begin
					state <= IDLE;
				end
			PRESSED:
				if(size_cg == 2'b11 && cs_cursor == 1'b1 && move_cursor == 1'b1) begin
					state <= JITTER2;
				end
				else begin
					state <= PRESSED;
				end
			JITTER2:
				if(cnt < 8'd200) begin
					cnt <= cnt + 8'd1;
				end
				else if(size_cg == 2'b11 && cs_cursor == 1'b1 && move_cursor == 1'b1) begin
					cnt <= 8'd0;
					state <= IDLE;
					size_cg_r <= size_cg;
					cs_r <= cs_cursor;
					move_r <= move_cursor;
				end
				else begin
					state <= PRESSED;
				end
		endcase
	end
end

//+++++++++++++++++++++++++++++++
//cursor
//+++++++++++++++++++++++++++++++
wire [8:0] cursor_u;
wire [8:0] cursor_d;
wire [8:0] cursor_l;
wire [8:0] cursor_r;

reg [8:0] cursor_u_r;
reg [8:0] cursor_d_r;
reg [8:0] cursor_l_r;
reg [8:0] cursor_r_r;

reg [1:0] cs;
reg [8:0] move;

//move cursor
reg [8:0] cnt_move; //0.0001 * 500 = 0.05
always @(posedge clk_10k or negedge rst_n_wave or negedge cs_r) begin
	if (!rst_n_wave || !cs_r) begin
		move <= 9'b0;
		cnt_move <= 9'b0;
	end
	else if (!move_r) begin
		if (cnt_move < 9'd500) begin
			cnt_move <= cnt_move + 1'b1;	
		end
		else begin
			cnt_move <= 9'd0;
		end
		//位置移动
		if(cnt_move == 9'd500) begin
			move <= move + 1'b1;
		end
		else begin
			move <= move;
		end
	end
end

//choose cursor
always @(negedge cs_r or negedge rst_n_wave) begin
	if (!rst_n_wave) begin
		cs <= 2'b00;
		cursor_u_r = V_CS_U;
		cursor_d_r = V_CS_D;
		cursor_l_r = T_CS_R;
		cursor_r_r = T_CS_L;
	end
	else begin
		case(cs)
			2'b00:	if (!cs_r) begin
				cs <= 2'b01;
				cursor_u_r = cursor_u;
				cursor_d_r = cursor_d;
				cursor_l_r = cursor_l;
				cursor_r_r = cursor_r;
			end	
			2'b01:	if (!cs_r) begin
				cs <= 2'b11;
				cursor_u_r = cursor_u;
				cursor_d_r = cursor_d;
				cursor_l_r = cursor_l;
				cursor_r_r = cursor_r;
			end	
			2'b11:	if (!cs_r) begin
				cs <= 2'b10;
				cursor_u_r = cursor_u;
				cursor_d_r = cursor_d;
				cursor_l_r = cursor_l;
				cursor_r_r = cursor_r;
			end	
			2'b10:	if (!cs_r) begin
				cs <= 2'b00;
				cursor_u_r = cursor_u;
				cursor_d_r = cursor_d;
				cursor_l_r = cursor_l;
				cursor_r_r = cursor_r;
			end	
		endcase
	end
end

assign cursor_u = (cs == 2'b00) ? (move + cursor_u_r) : cursor_u_r;
assign cursor_d = (cs == 2'b01) ? (move + cursor_d_r) : cursor_d_r;
assign cursor_l = (cs == 2'b11) ? (move + cursor_l_r) : cursor_l_r;
assign cursor_r = (cs == 2'b10) ? (move + cursor_r_r) : cursor_r_r;

//T
wire [31:0] vira_T;
wire [10:0] vira_T_r;

assign vira_T = 3125 * ((cursor_u > cursor_d) ? (cursor_u - cursor_d) : (cursor_d - cursor_u));
assign vira_T_r = (vira_T / 1000) >> move_h;

bin2BCD bB_u1(
	.in_bin({9'd0,vira_T_r}),

	.ten_thou(),
	.thou(data_T[15:12]),
	.hun (data_T[11:8]),
	.ten (data_T[7:4]) ,
	.unit(data_T[3:0]) 
);
//V
wire [8:0] vira_V;
wire [15:0] vira_V_r;

assign vira_V = ((cursor_r > cursor_l) ? (cursor_r - cursor_l) : (cursor_l - cursor_r));
assign vira_V_r = (vira_V * 39 / 5) >> move_v;

bin2BCD bB_u2(
	.in_bin({9'd0,vira_V_r}),

	.ten_thou(),
	.thou(data_V[15:12]),
	.hun (data_V[11:8]),
	.ten (data_V[7:4]) ,
	.unit(data_V[3:0]) 
);


//+++++++++++++++++++++++++++++++
//波形放缩
//+++++++++++++++++++++++++++++++
reg [1:0] move_h;    	 
always @(negedge size_cg_r[1] or negedge rst_n_wave) begin
	if(!rst_n_wave) begin
		move_h <= 2'b00;
	end
	else if(move_h < 2'b10) begin
		move_h <= move_h + 2'b01;
	end
	else begin
		move_h <= 2'b00;
	end
end

reg [1:0] move_v;    	 
always @(negedge size_cg_r[0] or negedge rst_n_wave) begin
	if(!rst_n_wave) begin
		move_v <= 2'b00;
	end
	else if(move_v < 2'b10) begin
		move_v <= move_v + 2'b01;
	end
	else begin
		move_v <= 2'b00;
	end
end

//+++++++++++++++++++++++++++++++++
//ram_r
//+++++++++++++++++++++++++++++++++
wire [7:0] data_ram;
reg [9:0] wr_addr;
reg db;

always @(posedge clk_wave or negedge rst_n_wave) begin
 	if (!rst_n_wave) begin
 		db <= 1'd0;
 	end
 	else if(xpos_wave == BORDER_WIDTH + SCREEN_LENGTH) begin
 		db <= ~db;
 	end
 	else begin
 		db <= db;
 	end
 end 

always @(posedge clk_wave or negedge rst_n_wave) begin
 	if (!rst_n_wave) begin
 		wr_addr <= 10'd0;
 	end
 	else if (~db && xpos_wave >= BORDER_WIDTH && xpos_wave < BORDER_WIDTH + SCREEN_LENGTH) begin
 		wr_addr <= xpos_wave[9:0] - BORDER_WIDTH[9:0];
 	end
 	else if (db && xpos_wave >= BORDER_WIDTH && xpos_wave < BORDER_WIDTH + SCREEN_LENGTH) begin
 		wr_addr <= xpos_wave[9:0] - BORDER_WIDTH[9:0] + 10'd512;
 	end
 	else begin
 		wr_addr <= wr_addr;
 	end
 end 

ram_r rr_u1(
	.clock(clk_wave),
	.data(data),
	.rdaddress((xpos_wave[9:0] - BORDER_WIDTH[9:0]) >> move_h),
	.rden(1'b1),
	.wraddress(wr_addr),
	.wren(data_en),
	.q(data_ram)
);

//+++++++++++++++++++++++++++++++++
//display
//+++++++++++++++++++++++++++++++++

always @(posedge clk_wave or negedge rst_n_wave) 
begin
	if (!rst_n_wave) begin
		data_wave  <= 16'd0;
		wave_valid <= 1'b0;
	end
	else if (data_en && xpos_wave >= BORDER_WIDTH && xpos_wave < BORDER_WIDTH + SCREEN_LENGTH && ypos_wave >= BORDER_WIDTH && ypos_wave < BORDER_WIDTH + SCREEN_WIDTH) begin
		if (xpos_wave == cursor_u || xpos_wave == cursor_d || ypos_wave == cursor_l || ypos_wave == cursor_r)begin
			data_wave <= color_cursor;
			wave_valid <= 1'b1;
		end
		else if(ypos_wave - BORDER_WIDTH == 12'd256 + (12'd64 << move_v) - ((data_ram >> 1'b1) << move_v) || ypos_wave - BORDER_WIDTH + 1'd1 == 12'd256 + (12'd64 << move_v) - ((data_ram >> 1'b1) << move_v)) begin
			data_wave  <= color_wave;
			wave_valid <= 1'b1;
		end
		else begin
			data_wave  <= 16'b0;
			wave_valid <= 1'b0; 
		end
	end
	else begin
		data_wave  <= 16'd0;
		wave_valid <= 1'b0;
	end
end

endmodule 