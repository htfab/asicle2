`default_nettype none

module fpga_top (
    input wire clk,
    input wire btnC,
    input wire btnU,
    input wire btnL,
    input wire btnR,
    input wire btnD,
    input wire [15:0] sw,
    input wire [7:0] JA,
    inout wire [7:0] JC,
    output wire [15:0] led,
    output wire [7:0] JB,
    output wire [7:0] JXADC,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire hsync,
    output wire vsync
);

reg rst_n;
wire clk_proj;
wire pll_locked;

pll #(
    // 25 MHz
    /*.PREDIV(1),
    .MULT(8),
    .DIV(32)*/
    // 25.17 MHz
    .PREDIV(3),
    .MULT(37),
    .DIV(49)
) i_pll (
    .clk_in(clk),
    .clk_out(clk_proj),
    .reset(sw[15]),
    .locked(pll_locked)
);

initial begin
    rst_n <= 0;
end

always @(posedge clk_proj) begin
    rst_n <= ~sw[14];
end

wire [7:0] direct_io = {sw[2:0], btnC, btnR, btnL, btnD, btnU};
wire [7:0] gamepad_io = {1'b0, JA[6:4], 4'b0};
wire [7:0] ui_in = direct_io | gamepad_io;

wire [7:0] uio_in;
wire [7:0] uio_out;
wire [7:0] uio_oe;

wire [7:0] ui_in_delayed;
wire [7:0] uio_in_delayed;

delay delay_inst (
    .clk(clk_proj),
    .cycles(sw[11:8]),
    .original({uio_in, ui_in}),
    .delayed({uio_in_delayed, ui_in_delayed})
);

tt_um_htfab_asicle2 proj (
    .ui_in(ui_in_delayed),
    .uo_out(JB),
    .uio_in(uio_in_delayed),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(1'b1),
    .clk(clk_proj),
    .rst_n(rst_n)
);

generate genvar i;
for (i=0; i<8; i=i+1) begin
    assign JC[i] = uio_oe[i] ? uio_out[i] : 1'bz;
    assign uio_in[i] = JC[i];
end
endgenerate

assign vgaRed = {JB[0], JB[4], JB[0], JB[4]};
assign vgaGreen = {JB[1], JB[5], JB[1], JB[5]};
assign vgaBlue = {JB[2], JB[6], JB[2], JB[6]};
assign hsync = JB[7];
assign vsync = JB[3];
assign led = sw;
assign JXADC = JC;

endmodule
