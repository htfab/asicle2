`default_nettype none

module fpga_top (
    input wire clk_25mhz,
    input wire [6:0] btn,
    output wire [7:0] led,
    input wire [7:0] ja,
    output wire [7:0] jb,
    inout wire [7:0] jc,
    output wire [7:0] jd,
    output wire keep_alive
);

assign led = {^btn, btn[6:1], !btn[0]};
assign keep_alive = 1'b1;

wire rst_n = btn[0];
wire clk_proj = clk_25mhz;

// button 2 acts as a "shift" key for new/peek/roll
wire btn_up = btn[3] && !btn[2];
wire btn_down = btn[4] && !btn[2];
wire btn_left = btn[5] && !btn[2];
wire btn_right = btn[6] && !btn[2];
wire btn_guess = btn[1] && !btn[2];
wire btn_new = btn[1] && btn[2];
wire btn_peek = btn[5] && btn[2];
wire btn_roll = btn[6] && btn[2];

wire [7:0] direct_io = {btn_roll, btn_peek, btn_new, btn_guess,
                        btn_right, btn_left, btn_down, btn_up};
wire [7:0] gamepad_io = {1'b0, ja[6:4], 4'b0};
wire [7:0] ui_in = direct_io | gamepad_io;
wire [7:0] uio_in;
wire [7:0] uio_out;
wire [7:0] uio_oe;
wire [7:0] uo_out;

// add input delay here if needed
wire [7:0] ui_in_delayed = ui_in;
wire [7:0] uio_in_delayed = uio_in;

tt_um_htfab_asicle2 proj (
    .ui_in(ui_in_delayed),
    .uo_out(uo_out),
    .uio_in(uio_in_delayed),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(1'b1),
    .clk(clk_proj),
    .rst_n(rst_n)
);

assign jd = uo_out;

generate genvar i;
for (i=0; i<8; i=i+1) begin
    assign jc[i] = uio_oe[i] ? uio_out[i] : 1'bz;
    assign uio_in[i] = jc[i];
end
endgenerate

assign jb = jc;

endmodule

