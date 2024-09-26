/*
 * @Author       : Xu Xiaokang
 * @Email        : xuxiaokang_up@qq.com
 * @Date         : 2024-09-14 11:40:11
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-26 21:38:37
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: clkDivider实例化参考
*/

clkDivider clkDivider_u0 (
  .div        (div       ),
  .div_valid  (div_valid ),
  .div_clk_en (div_clk_en),
  .div_clk    (div_clk   ),
  .clk        (clk       ),
  .rstn       (rstn      )
);