module driver_vga (
    input         clk_vga_driver,    //VGA像素时钟
    input         rst_n_driver,     //异步复位信号，低电平有效
    input [15:0]  data_vga_driver,  //RGB565格式
    
    output [15:0] rgb_vga_driver,   //接收要显示的色彩
    output reg    hs_vga_driver,    //VGA管脚 行同步
    output reg    vs_vga_driver,    //VGA管脚 场同步
    output [11:0] xpos_vga_driver,  //像素横坐标位置 
    output [11:0] ypos_vga_driver   //像素纵坐标位置 
);

//+++++++++++++++++++++++++++++++++
//标准参数
//+++++++++++++++++++++++++++++++++
//640*480 60Hz 25.125MHz
/*parameter   H_DISP  = 12'd640; 
            H_FRONT = 12'd16 ;      
            H_SYNC  = 12'd96 ;    
            H_BACK  = 12'd48 ;      
            H_TOTAL = 12'd800;

            V_DISP  = 12'd480; 
            V_FRONT = 12'd10 ;    
            V_SYNC  = 12'd2  ;     
            V_BACK  = 12'd33 ;    
            H_TOTAL = 12'd525;*/ 
//800*600 60Hz 40MHz
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

//+++++++++++++++++++++++++++++++++
//行 场 同步信号
//+++++++++++++++++++++++++++++++++
reg [11:0] hcnt;    //定义行计数器
always @(posedge clk_vga_driver or negedge rst_n_driver)
begin
   if (!rst_n_driver) begin
		hcnt <= 12'd0;
	end
    else begin
		if (hcnt <= H_TOTAL - 12'd1)   
			hcnt <= hcnt + 12'd1;
		else
			 hcnt <= 12'd0;
	end 
end

always @(posedge clk_vga_driver or negedge rst_n_driver)
begin
    if (!rst_n_driver)
        hs_vga_driver <= 1'b0;
    else
        begin
            if (hcnt >= H_DISP + H_FRONT - 12'd1 && hcnt < H_DISP +H_FRONT + H_SYNC - 12'd1)
                hs_vga_driver <= 1'b1;
            else
                hs_vga_driver <= 1'b0;
        end 
end 

reg [11:0] vcnt;
always @(posedge clk_vga_driver or negedge rst_n_driver)
begin
    if (!rst_n_driver)
        vcnt <= 12'd0;
    else if (hcnt == H_DISP - 12'd1) //周期性 无论哪个位置都可以
        begin
            if (vcnt < V_TOTAL - 12'd1)
                vcnt <= vcnt + 12'd1;
            else 
                vcnt <= 12'd0;
        end 
    else 
        vcnt <= vcnt;
end

always @ (posedge clk_vga_driver or negedge rst_n_driver)
begin
    if (!rst_n_driver)
        vs_vga_driver <= 1'b0;
    else
        begin
            if (vcnt >= V_DISP + V_FRONT - 12'd1 && vcnt < V_DISP + V_FRONT + V_SYNC - 12'd1)
                vs_vga_driver <= 1'b1;
            else 
                vs_vga_driver <= 1'b0;
        end 
end 

//+++++++++++++++++++++++++++++++++
//行列坐标
//+++++++++++++++++++++++++++++++++
assign xpos_vga_driver = (hcnt < H_DISP) ? hcnt : 12'd0;   
assign ypos_vga_driver = (vcnt < V_DISP) ? vcnt : 12'd0;   
assign rgb_vga_driver  = (hcnt < H_DISP && vcnt < H_DISP) ? data_vga_driver : 16'd0; 

endmodule