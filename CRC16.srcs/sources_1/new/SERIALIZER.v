module serializer #(
    parameter integer WIDTH = 48
)(
    input clk, rst,
    input [WIDTH-1:0] par_data,
    input [5:0] par_len,
    input par_load,
    
    output reg bit_out,
    output reg bit_valid,
    output busy
);

reg [WIDTH-1:0] sr;
reg [5:0] count;
reg running;

assign busy = running | bit_valid;

always @(posedge clk) begin
    if(rst) begin 
        sr <= {WIDTH{1'b0}};
        count <= 6'd0;
        running <= 1'b0;
        bit_out <= 1'b0;
        bit_valid <= 1'b0;
    end 
    else begin
        bit_valid <= 1'b0; //1 cycle only
        if(par_load && !running && (par_len != 6'd0)) begin
            sr <= par_data << (WIDTH - par_len);
            count <= par_len;
            running <= 1'b1;                      
        end
        else if (running) begin
            bit_out <= sr[WIDTH-1];
            bit_valid <= 1'b1;
            sr <= {sr[WIDTH-2:0], 1'b0};
            count <= count - 6'd1; 
            if (count == 6'd1) running <= 1'b0;
        end
    end
end

endmodule