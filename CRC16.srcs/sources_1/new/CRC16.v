module crc16 #(
        parameter [15:0] G = 16'h1021,
        parameter [15:0] INIT = 16'hFFFF)
 (
    input clk, rst, en, din,
    output reg [15:0] crc
 );

 wire fb = din ^ crc[15];

 always @(posedge clk) begin
    if(rst)
        crc <= INIT;
    else if(en)                                          // FIX 3: was unconditional.
        crc <= {crc[14:0], 1'b0} ^ (fb ? G : 16'h0000);  // Without `en` the LFSR
 end                                                     // advanced every clock.

endmodule
