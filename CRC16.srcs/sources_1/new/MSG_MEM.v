module msg_mem #(
    parameter integer DEPTH = 48
)(
    input clk, rst,
    
    //parallel write from transmitter
    input we,
    input [47:0] wdata,
    input [5:0] wlen,
    
    //serail read port for MUX
    input rd_start,
    output rd_bit,
    output rd_valid,
    output rd_last,
    output [5:0] rd_index, //for the channel to inject an error
    
    //observations
    output reg [47:0] stored_word,
    output reg [5:0] stored_len,
    output reg stored_valid
);

reg [5:0] read_ptr;
reg reading;

//Write port
always @(posedge clk) begin
    if(rst) begin
        stored_word <= 48'd0;
        stored_len <= 6'd0;
        stored_valid <= 1'b0; 
    end else if (we) begin
        stored_word <= wdata;
        stored_len <= wlen;
        stored_valid <= 1'b1; 
    end
end

//read port
always @(posedge clk) begin
    if(rst) begin
        read_ptr <= 6'd0;
        reading <= 1'b0; 
    end else if (rd_start && (stored_len != 6'd0)) begin
        read_ptr <= stored_len - 6'd1;
        reading <= 1'b1;
    end else if (reading) begin
        if(read_ptr == 6'd0) reading <= 1'b0;
        else read_ptr <= read_ptr - 6'd1; 
    end
end


assign rd_valid = reading;
assign rd_bit = stored_word[read_ptr];
assign rd_index = read_ptr;
assign rd_last = reading & (read_ptr == 6'd0);

endmodule