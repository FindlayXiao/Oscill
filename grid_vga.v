module grid_vga(
    input             clk_grid,
    input             rst_n_grid,
    input      [11:0] xpos_grid,  //输入横坐标
    input      [11:0] ypos_grid,  //输入纵坐标
	input 	   [15:0] color_grid,  
	input	   [15:0] color_back,  

    output reg [15:0] data_grid   //输出产生的图像数据
);
parameter   H_DISP  = 12'd800 ,     
            V_DISP  = 12'd600 ;     

localparam 	BORDER_WIDTH  = 12'd44 ,
			SCREEN_WIDTH  = 12'd512,
			SCREEN_LENGTH = 12'd512,
			WORD_AREA     = 12'd200,	
			UNIT_WIDTH    = 12'd64 ;

reg [11:0] x_flag; 

always @(posedge clk_grid or negedge rst_n_grid) begin
	if (!rst_n_grid) begin
		x_flag <= 12'd0;
	end
	else if (xpos_grid >= BORDER_WIDTH && xpos_grid < BORDER_WIDTH + SCREEN_LENGTH) begin
		x_flag <= (x_flag == UNIT_WIDTH - 1) ? 12'd0 : x_flag + 12'd1;
	end
	else begin
		x_flag <= 12'd0;
	end
end


always @(posedge clk_grid or negedge rst_n_grid) 
begin
	if (!rst_n_grid) begin
		data_grid <= 16'd0;
	end
	else if ((ypos_grid == BORDER_WIDTH && xpos_grid >= BORDER_WIDTH && xpos_grid < BORDER_WIDTH + SCREEN_LENGTH + WORD_AREA && xpos_grid[2] == 1'b1) || 
			 (ypos_grid == BORDER_WIDTH + SCREEN_WIDTH && xpos_grid >= BORDER_WIDTH && xpos_grid < BORDER_WIDTH + SCREEN_LENGTH + WORD_AREA && xpos_grid[2] == 1'b1)) begin
		data_grid <= color_grid;
	end
	else if ((x_flag == UNIT_WIDTH - 1 || xpos_grid == BORDER_WIDTH || xpos_grid == BORDER_WIDTH + SCREEN_LENGTH + WORD_AREA) && 
			  ypos_grid >= BORDER_WIDTH && ypos_grid < BORDER_WIDTH + SCREEN_WIDTH && ypos_grid[2] == 1'b1) begin
		data_grid <= color_grid;
	end
	else if ((ypos_grid == BORDER_WIDTH + UNIT_WIDTH * 1 ||
			  ypos_grid == BORDER_WIDTH + UNIT_WIDTH * 2 ||
			  ypos_grid == BORDER_WIDTH + UNIT_WIDTH * 3 ||
			  ypos_grid == BORDER_WIDTH + UNIT_WIDTH * 4 ||
			  ypos_grid == BORDER_WIDTH + UNIT_WIDTH * 5 ||
			  ypos_grid == BORDER_WIDTH + UNIT_WIDTH * 6 ||
			  ypos_grid == BORDER_WIDTH + UNIT_WIDTH * 7)  && xpos_grid >= BORDER_WIDTH && xpos_grid < BORDER_WIDTH + SCREEN_LENGTH && xpos_grid[2] == 1'b1) begin
		data_grid <= color_grid;
	end
	else if(xpos_grid < BORDER_WIDTH || xpos_grid >= BORDER_WIDTH + SCREEN_LENGTH + WORD_AREA || ypos_grid < BORDER_WIDTH || ypos_grid >= BORDER_WIDTH + SCREEN_WIDTH) begin
		data_grid <= color_back;
	end
	else begin
		data_grid <= 16'd0;
	end
end

endmodule