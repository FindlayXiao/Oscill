module result_display(
	input 		 clk_rd,
	input 		 rst_n_rd,
	input [11:0] data_vff,
	input [19:0] data_freq,
	input [11:0] xpos_rd,  
    input [11:0] ypos_rd,  
	input [15:0] color_rd,
	input [15:0]  data_V,
	input [15:0]  data_T,

	output reg [15:0] data_rd
);

localparam 	BORDER_WIDTH  = 12'd44 ,
			SCREEN_WIDTH  = 12'd512,
			SCREEN_LENGTH = 12'd512,
			WORD_AREA     = 12'd200,	
			UNIT_WIDTH    = 12'd64 ,

			WORD_WIDTH    = 12'd7  ,
			WORD_HIGH	  = 12'd7  ,

			MINUS = 4'b1111,
			NO    = 4'b1110,
			DOT   = 4'b1100;

reg [19:0] word;
wire [7:0] p[34:0];

digit_set u1(
	.clk(clk_rd),
	.rst_n(rst_n_rd),
	.data(word[19:16]),
	.col0(p[0]),
	.col1(p[1]),
	.col2(p[2]),
	.col3(p[3]),
	.col4(p[4]),
	.col5(p[5]),
	.col6(p[6])
);
digit_set u2(
	.clk(clk_rd),
	.rst_n(rst_n_rd),
	.data(word[15:12]),
	.col0(p[7]),
	.col1(p[8]),
	.col2(p[9]),
	.col3(p[10]),
	.col4(p[11]),
	.col5(p[12]),
	.col6(p[13])
);
digit_set u3(
	.clk(clk_rd),
	.rst_n(rst_n_rd),
	.data(word[11:8]),
	.col0(p[14]),
	.col1(p[15]),
	.col2(p[16]),
	.col3(p[17]),
	.col4(p[18]),
	.col5(p[19]),
	.col6(p[20])
);
digit_set u4(
	.clk(clk_rd),
	.rst_n(rst_n_rd),
	.data(word[7:4]),
	.col0(p[21]),
	.col1(p[22]),
	.col2(p[23]),
	.col3(p[24]),
	.col4(p[25]),
	.col5(p[26]),
	.col6(p[27])
);
digit_set u5(
	.clk(clk_rd),
	.rst_n(rst_n_rd),
	.data(word[3:0]),
	.col0(p[28]),
	.col1(p[29]),
	.col2(p[30]),
	.col3(p[31]),
	.col4(p[32]),
	.col5(p[33]),
	.col6(p[34])
);

//++++++++++++++++++++++++++++++
//VFF:
//++++++++++++++++++++++++++++++
localparam	UP_vff   = BORDER_WIDTH + UNIT_WIDTH,
			DOWN_vff = UP_vff + WORD_HIGH,
			LEFT_vff = BORDER_WIDTH + SCREEN_LENGTH + 11 * WORD_WIDTH,			
			RIGHT_vff= LEFT_vff + 4 * WORD_WIDTH;

//++++++++++++++++++++++++++++++
//FQ:
//++++++++++++++++++++++++++++++
localparam	UP_fq   = BORDER_WIDTH + UNIT_WIDTH * 2,
			DOWN_fq = UP_fq + WORD_HIGH,
			LEFT_fq = BORDER_WIDTH + SCREEN_LENGTH + 11 * WORD_WIDTH,			
			RIGHT_fq= LEFT_fq + 5 * WORD_WIDTH;

//++++++++++++++++++++++++++++++
//T:
//++++++++++++++++++++++++++++++
localparam	UP_t   = BORDER_WIDTH + UNIT_WIDTH * 3,
			DOWN_t = UP_t + WORD_HIGH,
			LEFT_t = BORDER_WIDTH + SCREEN_LENGTH + 11 * WORD_WIDTH,			
			RIGHT_t= LEFT_t + 4 * WORD_WIDTH;

//++++++++++++++++++++++++++++++
//V:
//++++++++++++++++++++++++++++++
localparam	UP_v   = BORDER_WIDTH + UNIT_WIDTH * 4,
			DOWN_v = UP_v + WORD_HIGH,
			LEFT_v = BORDER_WIDTH + SCREEN_LENGTH + 11 * WORD_WIDTH,			
			RIGHT_v= LEFT_v + 4 * WORD_WIDTH;


always @ (posedge clk_rd or negedge rst_n_rd)
	begin
		if (!rst_n_rd) begin
			data_rd <= 15'b0;
			word <= {NO, NO, NO, NO, NO};
		end
		else if (ypos_rd >= UP_vff && ypos_rd <= DOWN_vff && xpos_rd >= LEFT_vff && xpos_rd <= RIGHT_vff) begin
				word <= {data_vff[11:4], DOT, data_vff[3:0], NO};
				if (p[xpos_rd - LEFT_vff][ypos_rd - UP_vff]) begin
					data_rd <= color_rd;
				end
				else begin
					data_rd <= 15'b0;
				end
		end
		else if (ypos_rd >= UP_fq && ypos_rd <= DOWN_fq && xpos_rd >= LEFT_fq && xpos_rd <= RIGHT_fq) begin
				word <= {data_freq};
				if (p[xpos_rd - LEFT_fq][ypos_rd - UP_fq]) begin
					data_rd <= color_rd;
				end
				else begin
					data_rd <= 15'b0;
				end
		end
		else if (ypos_rd >= UP_t && ypos_rd <= DOWN_t && xpos_rd >= LEFT_t && xpos_rd <= RIGHT_t) begin
				word <= {data_T[15:8], DOT, data_T[7:0]};
				if (p[xpos_rd - LEFT_t][ypos_rd - UP_t]) begin
					data_rd <= color_rd;
				end
				else begin
					data_rd <= 15'b0;
				end
		end
		else if (ypos_rd >= UP_v && ypos_rd <= DOWN_v && xpos_rd >= LEFT_v && xpos_rd <= RIGHT_v) begin
				word <= {data_V[15:8], DOT, data_V[7:0]};
				if (p[xpos_rd - LEFT_v][ypos_rd - UP_v]) begin
					data_rd <= color_rd;
				end
				else begin
					data_rd <= 15'b0;
				end
		end
		else begin
			data_rd <= 15'b0;
		end
	end

endmodule