module div(
    input[31:0] a, 
    input[31:0] b,   //若b==0，则quo=0, rem=a;

    output reg [31:0] quo,
    output reg [31:0] rem
);

reg[31:0] tempa;
reg[31:0] tempb;
reg[63:0] temp_a;
reg[63:0] temp_b;

integer i;
always @(a or b)
begin
    tempa <= a;
    tempb <= b;
end

always @(tempa or tempb)
begin
    temp_a = {32'h00000000,tempa};
    temp_b = {tempb,32'h00000000}; 
    for(i = 0;i < 32;i = i + 1)
        begin
            temp_a = {temp_a[62:0],1'b0};
            if(temp_a[63:32] >= tempb)
                temp_a = temp_a - temp_b + 1'b1;
            else
				temp_a = temp_a;
        end
    quo = temp_a[31:0];
    rem = temp_a[63:32];
end

endmodule

 

