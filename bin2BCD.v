module bin2BCD (
	output reg [3:0]  ten_thou,
	output reg [3:0]  thou,
	output reg [3:0]  hun ,
	output reg [3:0]  ten ,
	output reg [3:0]  unit,

	input  [19:0] in_bin
);

integer i;
always @(in_bin) begin
	ten_thou = 4'd0;
	thou= 4'd0;
	hun = 4'd0;
	ten = 4'd0;
	unit= 4'd0;
	for(i=19; i>=0; i=i-1)begin
		if(ten_thou>=4'd5)
			ten_thou  = ten_thou  + 4'd3;		
		if(thou>=4'd5)
			thou  = thou  + 4'd3;
		if(hun>=4'd5)
			hun  = hun  + 4'd3;		
		if(ten>=4'd5)
			ten  = ten  + 4'd3;
		if(unit>=4'd5)
			unit = unit + 4'd3;
		ten_thou = ten_thou << 1;
		ten_thou[0] = thou[3];
		thou = thou << 1;
		thou[0] = hun[3];
		hun = hun << 1;
		hun[0] = ten[3];
		ten = ten << 1;
		ten[0] = unit[3];
		unit = unit << 1;
		unit[0] = in_bin[i];
	end
end

endmodule 