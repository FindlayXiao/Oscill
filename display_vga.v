module display_vga 
#(
/***********************************************
    1280 x 1024 @ 60 Hz
***********************************************/
    parameter 
    H_DISP          = 12'd1280,
    V_DISP          = 12'd1024,
    PIXEL_FREQUENCY = 28'd108_000000,
    DELAY           = 5'd3
)
(
    input             clk_vga_display,
    input             rst_n_display,
    input [11:0]      xpos_vga_display,  //输入横坐标
    input [11:0]      ypos_vga_display,  //输入纵坐标
    
    output reg [15:0] data_vga_display   //输出产生的图像数据
);

/****************************************************************
    定义本地参数颜色，RGB565
****************************************************************/
    localparam
    RED    = 16'hF800,   //11111_000000_00000 红
    GREEN  = 16'h07E0,   //00000_111111_00000 绿
    BLUE   = 16'h001F,   //00000_000000_11111 蓝
    WHITE  = 16'hFFFF,   //11111_111111_11111 白
    BLACK  = 16'h0000,   //00000_000000_00000 黑
    YELLOW = 16'hFFE0,   //11111_111111_00000 黄
    MAGENTA= 16'hF81F,   //11111_000000_11111 紫（品红、洋红）
    CYAN   = 16'h07FF;   //00000_111111_11111 青（蓝绿）
    
/****************************************************************
    延时，产生模式选择信号
****************************************************************/
    reg [27:0] cnt_display;     //在像素频率下计数，计满为1秒
    reg [2:0]  mod_display;     //显示模式
    reg [4:0]  delay_display;   //延时，秒为单位，最多31秒
    always @ (posedge clk_vga_display or negedge rst_n_display)
        begin
            if (!rst_n_display)
                begin 
                    cnt_display <= 28'd0;
                    mod_display <= 3'd0;
                end 
            else 
                begin 
                    if (cnt_display < PIXEL_FREQUENCY)  //判断是否计到1秒
                        begin 
                            cnt_display <= cnt_display + 28'd1;            
                        end 
                    else 
                        begin
                            cnt_display <= 28'd0;
                            if (delay_display < DELAY)  //延时 DELAY 秒
                                delay_display <= delay_display + 5'd1;
                            else 
                                begin
                                    delay_display <= 5'd0;
                                    if (mod_display < 3'd7)   //模式选择
                                        mod_display <= mod_display + 3'd1;
                                    else 
                                        mod_display <= 3'd0;
                                end 
                        end
                end 
        end 

/*************************************************************
    方格1   小
*************************************************************/
    reg [15:0] grid1_data_display;
    always @ (posedge clk_vga_display or negedge rst_n_display)
        if (!rst_n_display)
            grid1_data_display <= BLACK;
        else 
            if (xpos_vga_display[4] == 1 ^ ypos_vga_display[4] == 1)
                grid1_data_display <= WHITE;
            else 
                grid1_data_display <= BLACK;
    
/*************************************************************
    方格2   大
*************************************************************/
    reg [15:0] grid2_data_display;
    always @ (posedge clk_vga_display or negedge rst_n_display)
        if (!rst_n_display)
            grid2_data_display <= BLACK;
        else 
            if (xpos_vga_display[6] == 1 ^ ypos_vga_display[6] == 1)
                grid2_data_display <= WHITE;
            else 
                grid2_data_display <= BLACK;
    
/*************************************************************
    彩条1    横
*************************************************************/
    reg [15:0] color_bar1_display;
    always @ (posedge clk_vga_display or negedge rst_n_display)
        if (!rst_n_display)
            color_bar1_display <= BLACK;
        else 
            begin
                if (ypos_vga_display >= 0 && ypos_vga_display < (V_DISP >> 3))
                    color_bar1_display <= RED;
                else if (ypos_vga_display >= (V_DISP >> 3)*1 && ypos_vga_display < (V_DISP >> 3)*2)
                    color_bar1_display <= GREEN;
                else if (ypos_vga_display >= (V_DISP >> 3)*2 && ypos_vga_display < (V_DISP >> 3)*3)
                    color_bar1_display <= BLUE;
                else if (ypos_vga_display >= (V_DISP >> 3)*3 && ypos_vga_display < (V_DISP >> 3)*4)
                    color_bar1_display <= WHITE;
                else if (ypos_vga_display >= (V_DISP >> 3)*4 && ypos_vga_display < (V_DISP >> 3)*5)
                    color_bar1_display <= BLACK;
                else if (ypos_vga_display >= (V_DISP >> 3)*5 && ypos_vga_display < (V_DISP >> 3)*6)
                    color_bar1_display <= YELLOW;
                else if (ypos_vga_display >= (V_DISP >> 3)*6 && ypos_vga_display < (V_DISP >> 3)*7)
                    color_bar1_display <= MAGENTA;
                else if (ypos_vga_display >= (V_DISP >> 3)*7 && ypos_vga_display < (V_DISP >> 3)*8)
                    color_bar1_display <= CYAN;
                else 
                    color_bar1_display <= BLACK;
            end 
    
/*************************************************************
    彩条2    竖
*************************************************************/
    reg [15:0] color_bar2_display;
    always @ (posedge clk_vga_display or negedge rst_n_display)
        if (!rst_n_display)
            color_bar2_display <= BLACK;
        else 
            begin
                if (xpos_vga_display >= 0 && xpos_vga_display < (H_DISP >> 3))
                    color_bar2_display <= RED;
                else if (xpos_vga_display >= (H_DISP >> 3)*1 && xpos_vga_display < (H_DISP >> 3)*2)
                    color_bar2_display <= GREEN;
                else if (xpos_vga_display >= (H_DISP >> 3)*2 && xpos_vga_display < (H_DISP >> 3)*3)
                    color_bar2_display <= BLUE;
                else if (xpos_vga_display >= (H_DISP >> 3)*3 && xpos_vga_display < (H_DISP >> 3)*4)
                    color_bar2_display <= WHITE;
                else if (xpos_vga_display >= (H_DISP >> 3)*4 && xpos_vga_display < (H_DISP >> 3)*5)
                    color_bar2_display <= BLACK;
                else if (xpos_vga_display >= (H_DISP >> 3)*5 && xpos_vga_display < (H_DISP >> 3)*6)
                    color_bar2_display <= YELLOW;
                else if (xpos_vga_display >= (H_DISP >> 3)*6 && xpos_vga_display < (H_DISP >> 3)*7)
                    color_bar2_display <= MAGENTA;
                else if (xpos_vga_display >= (H_DISP >> 3)*7 && xpos_vga_display < (H_DISP >> 3)*8)
                    color_bar2_display <= CYAN;
                else 
                    color_bar2_display <= BLACK;
            end 
            
/*************************************************************
    花型矩阵
**************************************************************/
    reg [15:0] flower_matrix_display;
    wire [21:0] flower_result = xpos_vga_display * ypos_vga_display;
    always @ (posedge clk_vga_display or negedge rst_n_display)
        if (!rst_n_display)
            flower_matrix_display <= BLACK;
        else 
            flower_matrix_display <= flower_result[15:0];
        
/*************************************************************
    选择显示模式
*************************************************************/
    always @ (posedge clk_vga_display or negedge rst_n_display)
        if (!rst_n_display)
            data_vga_display <= 16'd0;
        else 
            case (mod_display)
                3'd0 : data_vga_display <= grid1_data_display;
                3'd1 : data_vga_display <= grid2_data_display;
                3'd2 : data_vga_display <= color_bar1_display;
                3'd3 : data_vga_display <= color_bar2_display;
                3'd4 : data_vga_display <= RED;
                3'd5 : data_vga_display <= GREEN;
                3'd6 : data_vga_display <= BLUE;
                3'd7 : data_vga_display <= flower_matrix_display;
                default : data_vga_display <= BLACK;
            endcase
            
endmodule