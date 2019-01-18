module char_vga(
	input             clk_char,
    input             rst_n_char,
    input      [11:0] xpos_char,  
    input      [11:0] ypos_char,  
	input 	   [15:0] color_char,
	    
    output reg [15:0] data_char   
);

localparam 	BORDER_WIDTH  = 12'd44 ,
			SCREEN_WIDTH  = 12'd512,
			SCREEN_LENGTH = 12'd512,
			WORD_AREA     = 12'd200,	
			UNIT_WIDTH    = 12'd64 ,

			WORD_WIDTH    = 12'd7  ,
			WORD_HIGH	  = 12'd7  ,

			F = 4'd1, H = 4'd2, I = 4'd3,
			K = 4'd4, U = 4'd5, Q = 4'd6,
			TR= 4'd7, T = 4'd8, V = 4'd9,
			X = 4'd10,Y = 4'd11,Z = 4'd12,
			NO= 4'd13,qq= 4'd14,S = 4'd15;



//++++++++++++++++++++++++++++++
//display settled
//++++++++++++++++++++++++++++++
reg [15:0] word;
wire [7:0] p[27:0];

char_set u1(
	.clk(clk_char),
	.rst_n(rst_n_char),
	.data(word[15:12]),
	.col0(p[0]),
	.col1(p[1]),
	.col2(p[2]),
	.col3(p[3]),
	.col4(p[4]),
	.col5(p[5]),
	.col6(p[6])
);
char_set u2(
	.clk(clk_char),
	.rst_n(rst_n_char),
	.data(word[11:8]),
	.col0(p[7]),
	.col1(p[8]),
	.col2(p[9]),
	.col3(p[10]),
	.col4(p[11]),
	.col5(p[12]),
	.col6(p[13])
);
char_set u3(
	.clk(clk_char),
	.rst_n(rst_n_char),
	.data(word[7:4]),
	.col0(p[14]),
	.col1(p[15]),
	.col2(p[16]),
	.col3(p[17]),
	.col4(p[18]),
	.col5(p[19]),
	.col6(p[20])
);
char_set u4(
	.clk(clk_char),
	.rst_n(rst_n_char),
	.data(word[3:0]),
	.col0(p[21]),
	.col1(p[22]),
	.col2(p[23]),
	.col3(p[24]),
	.col4(p[25]),
	.col5(p[26]),
	.col6(p[27])
);

//++++++++++++++++++++++++++++++
//Location
//++++++++++++++++++++++++++++++
//VFF
localparam	UP_vff   = BORDER_WIDTH + UNIT_WIDTH,
			DOWN_vff = UP_vff + WORD_HIGH,
			LEFT_vff = BORDER_WIDTH + SCREEN_LENGTH + 5 * WORD_WIDTH,			
			RIGHT_vff= LEFT_vff + 4 * WORD_WIDTH,

			UNIT_vff_l = RIGHT_vff + 7 * WORD_WIDTH,
			UNIT_vff_r = UNIT_vff_l + 4 * WORD_WIDTH;

//FQ:
localparam	UP_fq   = BORDER_WIDTH + UNIT_WIDTH * 2,
			DOWN_fq = UP_fq + WORD_HIGH,
			LEFT_fq = BORDER_WIDTH + SCREEN_LENGTH + 5 * WORD_WIDTH,			
			RIGHT_fq= LEFT_fq + 4 * WORD_WIDTH,

			UNIT_fq_l = RIGHT_fq + 7 * WORD_WIDTH,
			UNIT_fq_r = UNIT_fq_l + 4 * WORD_WIDTH;

//T:
localparam	UP_t   = BORDER_WIDTH + UNIT_WIDTH * 3,
			DOWN_t = UP_t + WORD_HIGH,
			LEFT_t = BORDER_WIDTH + SCREEN_LENGTH + 5 * WORD_WIDTH,			
			RIGHT_t= LEFT_t + 4 * WORD_WIDTH,

			UNIT_t_l = RIGHT_t + 7 * WORD_WIDTH,
			UNIT_t_r = UNIT_t_l + 4 * WORD_WIDTH;

//V:
localparam	UP_v   = BORDER_WIDTH + UNIT_WIDTH * 4,
			DOWN_v = UP_v + WORD_HIGH,
			LEFT_v = BORDER_WIDTH + SCREEN_LENGTH + 5 * WORD_WIDTH,			
			RIGHT_v= LEFT_v + 4 * WORD_WIDTH,

			UNIT_v_l = RIGHT_v + 7 * WORD_WIDTH,
			UNIT_v_r = UNIT_v_l + 4 * WORD_WIDTH;

//NAME
localparam 	UP_xyf    = BORDER_WIDTH + SCREEN_WIDTH - 2 * WORD_HIGH,
			DOWN_xyf  = UP_xyf + WORD_HIGH,
			LEFT_xyf  = BORDER_WIDTH + SCREEN_LENGTH + WORD_AREA - 5 * WORD_WIDTH,
			RIGHT_xyf = LEFT_xyf + 4 * WORD_WIDTH;

//++++++++++++++++++++++++++++++
//Display
//++++++++++++++++++++++++++++++
always @ (posedge clk_char or negedge rst_n_char)
	begin
		if (!rst_n_char) begin
			data_char <= 15'b0;
			word <= NO;
		end
		else if (ypos_char >= UP_vff && ypos_char <= DOWN_vff && xpos_char >= LEFT_vff && xpos_char <= RIGHT_vff) begin
				word <= {NO, V, F, qq};
				if (p[xpos_char - LEFT_vff][ypos_char - UP_vff]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		else if (ypos_char >= UP_fq && ypos_char <= DOWN_fq && xpos_char >= LEFT_fq && xpos_char <= RIGHT_fq) begin
				word <= {NO, F, Q, qq};
				if (p[xpos_char - LEFT_fq][ypos_char - UP_fq]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		else if (ypos_char >= UP_t && ypos_char <= DOWN_t && xpos_char >= LEFT_t && xpos_char <= RIGHT_t) begin
				word <= {NO, TR, T, qq};
				if (p[xpos_char - LEFT_t][ypos_char - UP_t]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		else if (ypos_char >= UP_v && ypos_char <= DOWN_v && xpos_char >= LEFT_v && xpos_char <= RIGHT_v) begin
				word <= {NO, TR, V, qq};
				if (p[xpos_char - LEFT_v][ypos_char - UP_v]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		//UNIT Display
		else if (ypos_char >= UP_vff && ypos_char <= DOWN_vff && xpos_char >= UNIT_vff_l && xpos_char <= UNIT_vff_r) begin
				word <= {NO, V, NO, NO};
				if (p[xpos_char - UNIT_vff_l][ypos_char - UP_vff]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		else if (ypos_char >= UP_fq && ypos_char <= DOWN_fq && xpos_char >= UNIT_fq_l && xpos_char <= UNIT_fq_r) begin
				word <= {NO, K, H, Z};
				if (p[xpos_char - UNIT_fq_l][ypos_char - UP_fq]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		else if (ypos_char >= UP_t && ypos_char <= DOWN_t && xpos_char >= UNIT_t_l && xpos_char <= UNIT_t_r) begin
				word <= {NO, U, S, NO};
				if (p[xpos_char - UNIT_t_l][ypos_char - UP_t]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		else if (ypos_char >= UP_v && ypos_char <= DOWN_v && xpos_char >= UNIT_v_l && xpos_char <= UNIT_v_r) begin
				word <= {NO, V, NO, NO};
				if (p[xpos_char - UNIT_v_l][ypos_char - UP_v]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		//NAME
		else if (ypos_char >= UP_xyf && ypos_char <= DOWN_xyf && xpos_char >= LEFT_xyf && xpos_char <= RIGHT_xyf) begin
				word <= {NO, X, Y, F};
				if (p[xpos_char - LEFT_xyf][ypos_char - RIGHT_xyf - 1'b1]) begin
					data_char <= color_char;
				end
				else begin
					data_char <= 15'b0;
				end
		end
		else begin
			data_char <= 15'b0;
		end
	end

endmodule