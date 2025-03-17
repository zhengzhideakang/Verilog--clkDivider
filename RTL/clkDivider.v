/*
 * @Author   : Xu Xiaokang
 * @Email:
 * @Date : 2021-04-30 08:22:46
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-26 21:01:49
 * @Filename : clkDivider.v
 * @Description  : 时钟整数分频模块
*/

/*
! 模块功能: 将输入时钟根据输入信号div分频. div为正整数, 得到div_clk = clk / div
* 思路:
  1.当div为0或1时，时钟原样输出
  1.当div为偶数时, 直接生成占空比50%的方波即可
  2.当div为奇数时, 需要用到下降沿触发, 生成两个占空比不是50%的方波, 然后做或运算
~ 使用
  1.通过输入信号div控制分频系数，输出div_clk = clk / DIV，可实现时钟在线分频。
  2.如果仅需要固定倍数的分频, 只需要固定div的值, div_valid一直为1即可。
  3.div应不等于0, 如果div=0, 那么div会被忽略, 输出div_clk = clk。
  4.div_valid高电平有效, 指示div有效。
  5.div_clk_en控制分频时钟输出, div_clk_en=1时正常输出, div_clk_en=0时输出0。
  6.任意频率的输出时钟占空比固定为50%。
*/

`default_nettype none

module clkDivider
(
  input  wire [31:0] div, // 分频系数, 正整数
  input  wire        div_valid, // 分频系数更新指示, 高电平有效

  input  wire div_clk_en, // 控制分频时钟输出, div_clk_en=1时正常输出, div_clk_en=0时输出0
  output wire div_clk,

  input  wire clk,
  input  wire rstn
);


//++ 锁存分频系数 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg [31:0] div_locked;
always @(posedge clk) begin
  if (~rstn)
    div_locked <= 'd1;
  else if (div_valid && div != 'd0)
    div_locked <= div;
  else
    div_locked <= div_locked;
end
//-- 锁存分频系数 ------------------------------------------------------------


//++ 时钟计数 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg [31 : 0] div_cnt;
reg [31:0] div_cnt_max; // 计数最大值
always @(posedge clk) begin
  if (~rstn)
    div_cnt_max <= 'd0;
  else if (~(|div_cnt)) // 全0时更改计数最大值
    div_cnt_max <= div_locked - 1'b1;
  else
    div_cnt_max <= div_cnt_max;
end

always @(posedge clk) begin
  if (div_clk_en && div_cnt < div_cnt_max) // 计数最大值：div-1
    div_cnt <= div_cnt + 1'b1;
  else
    div_cnt <= 'd0;
end
//-- 时钟计数 ------------------------------------------------------------


//++ 利用上升沿与下降沿生成时钟 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg div_clk_a;
always @(posedge clk) begin
  if (div_clk_en && div_cnt > (div_cnt_max >> 1))
    div_clk_a <= 1'b1;
  else
    div_clk_a <= 1'b0;
end

reg div_clk_b;
always @(negedge clk) begin // 下降沿触发
  if (div_clk_en && div_cnt > (div_cnt_max >> 1))
    div_clk_b <= 1'b1;
  else
    div_clk_b <= 1'b0;
end
//-- 利用上升沿与下降沿生成时钟 ------------------------------------------------------------


//++ 最终分频时钟输出 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg div_clk_reg;
always @(*) begin
  if (~div_clk_en)
    div_clk_reg = 1'b0;
  else if (div_cnt_max == 'd0)
    div_clk_reg = clk;
  else if (div_cnt_max[0])
    div_clk_reg = div_clk_a;
  else
    div_clk_reg = div_clk_a | div_clk_b;
end

assign div_clk = div_clk_reg;
//-- 最终分频时钟输出 ------------------------------------------------------------


endmodule
`resetall