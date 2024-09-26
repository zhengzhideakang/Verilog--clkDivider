/*
 * @Author       : Xu Xiaokang
 * @Email        :
 * @Date         : 2021-04-29 22:55:32
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-26 16:33:58
 * @Filename     : clkDivider_tb.sv
 * @Description  : testbench of clkDivider
*/

module clkDivider_tb ();

timeunit 1ns;
timeprecision 1ps;


//++ 时钟分频模块实例化 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
logic [31:0] div;
logic div_valid;
logic div_clk_en;
logic div_clk;
logic clk;
logic rstn;

clkDivider  clkDivider_u0 (.*);
//-- 时钟分频模块实例化 ------------------------------------------------------------


// 生成时钟
localparam CLKT = 2;
initial begin
  clk = 0;
  forever #(CLKT / 2) clk = ~clk;
end


initial begin
  div_clk_en = 0;
  rstn = 0;

  #(CLKT*3);
  rstn = 1;

  #(div*CLKT*3);
  div_clk_en = 1;

  // div变化测试
  #(CLKT*5);
  for (int i = 1; i < 10; i++) begin
    div = i;
    div_valid = 1;
    #(CLKT);
    div_valid = 0;
    #(div*CLKT*5);
  end

  $stop;
end


endmodule