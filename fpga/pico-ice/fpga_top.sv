module fpga_top (
    input wire clk_12mhz,
    input wire btn_sw2,
    output wire [7:0] pmod0,
    inout wire [7:0] pmod1,
    input wire [7:0] pmod2
);

wire clk_proj;
wire pll_locked;

pll pll_inst (
    .clock_in(clk_12mhz),
    .clock_out(clk_proj),
    .locked(pll_locked)
);

reg init;
reg [4:0] init_counter;
initial begin
    init <= 0;
    init_counter <= 0;
end

always @(posedge clk_proj) begin
    if (!init && pll_locked) begin
        {init, init_counter} <= {init, init_counter} + 1;
    end
end

wire rst_n = btn_sw2 && init;

wire [7:0] ui_in;
wire [7:0] uo_out;
wire [7:0] uio_in;
wire [7:0] uio_out;
wire [7:0] uio_oe;

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

assign ui_in = pmod2;
assign pmod0 = uo_out;

generate genvar i;
for (i=0; i<8; i=i+1) begin
    assign pmod1[i] = uio_oe[i] ? uio_out[i] : 1'bz;
    assign uio_in[i] = pmod1[i];
end
endgenerate

endmodule

