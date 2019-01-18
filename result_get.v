module result_get(
	//
	input       clk_result,
	input		rst_n_result,
	input [7:0] ram_data,
	input 		data_en,

	output [11:0] data_vff
);

wire   [7:0] 	addr;
reg   [7:0]		max_data;
reg   [7:0]    	max_data_r;
reg   [7:0]		min_data;
reg   [7:0]     min_data_r;
wire  [15:0] 	data_rom;

//++++++++++++++++++++++++++++++++++++++++
//Vff
//++++++++++++++++++++++++++++++++++++++++
always @(posedge clk_result or negedge rst_n_result) begin
	if (!rst_n_result) begin
		max_data_r <= 8'b0;
		max_data <= 8'b0;
	end
	else if (data_en == 1'b0 && max_data_r > 8'b0) begin 
		max_data <= max_data_r;
		max_data_r <= 8'b0;
	end
	else if (data_en == 1'b1 && ram_data > max_data_r) begin
		max_data_r <= ram_data;
		max_data <= max_data;
	end
	else begin
		max_data_r <= max_data_r;
		max_data <= max_data;
	end
end

always @(posedge clk_result or negedge rst_n_result) begin
	if (!rst_n_result) begin
		min_data_r <= 8'b0;
		min_data <= 8'b0;
	end
	else if (data_en == 1'b0 && min_data_r < 8'd255) begin
		min_data <= min_data_r;
		min_data_r <= 8'd255;
	end
	else if (data_en == 1'b1 && ram_data < min_data_r) begin
		min_data_r <= ram_data;
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
	.clock(clk_result),
	.q(data_rom)
);
*/

bin2BCD bB_u1(
	.in_bin({8'd0,data_rom[15:4]}),

	.ten_thou(),
	.thou(),
	.hun (data_vff[11:8]),
	.ten (data_vff[7:4]) ,
	.unit(data_vff[3:0]) 
);
endmodule 