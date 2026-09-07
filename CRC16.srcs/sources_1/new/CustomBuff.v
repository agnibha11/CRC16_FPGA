module custom_buff #(
    parameter integer DEPTH = 48
)(
    input clk, rst,

    //serial write port
    input bit_in,
    input bit_push,

    //serail read port
    input rd_start,
    output rd_bit,
    output rd_valid,
    output rd_last,
    output [5:0] rd_index,

    //observations
    output reg [47:0] stored_word,
    output reg [5:0] stored_len
);

reg [5:0] rd_ptr;
reg reading;

always @(posedge clk) begin
    if(rst) begin
        stored_word <= 48'd0;
        stored_len <= 6'd0;
    end else if(bit_push && (stored_len < DEPTH)) begin
        stored_word <= {stored_word[46:0], bit_in};
        stored_len <= stored_len + 6'd1;
    end
end

//read port
always @(posedge clk) begin
    if(rst) begin
        rd_ptr <= 6'd0;
        reading <= 1'b0;
    end else if(rd_start && (stored_len != 6'd0)) begin
        rd_ptr <= stored_len - 6'd1;
        reading <= 1'b1;
    end else if(reading) begin
        if(rd_ptr == 6'd0) reading <= 1'b0;
        else rd_ptr <= rd_ptr - 6'd1;
    end
end

assign rd_valid = reading;
assign rd_bit = stored_word[rd_ptr];
assign rd_index = rd_ptr;
assign rd_last = reading & (rd_ptr == 6'd0);   // FIX 6: was `rd_ast` -- a typo that
                                               // Verilog silently turned into a new
                                               // implicit wire, leaving rd_last
                                               // undriven. In OVERRIDE mode the
                                               // receiver never saw the end of the
                                               // stream and hung forever.
endmodule
