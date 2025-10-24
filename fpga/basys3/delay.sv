`default_nettype none

module delay (
    input wire clk,
    input wire [3:0] cycles,
    input wire [15:0] original,
    output wire [15:0] delayed
);

reg [15:0] chain[15:0];

always_comb chain[0] = original;

generate genvar i;
for (i=0; i<15; i=i+1) begin
    always @(posedge clk) chain[i+1] <= chain[i];
end
endgenerate

assign delayed = chain[cycles];

endmodule
