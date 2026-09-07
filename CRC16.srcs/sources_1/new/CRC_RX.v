module crc_rx #(
    parameter [15:0] G = 16'h1021,
    parameter [15:0] INIT = 16'hFFFF
)(
    input clk, rst,
    
    //incoming stream
    input rx_start,
    input rx_bit,
    input rx_valid,
    input rx_last,
    
    //output verdict
    output reg received,
    output reg corrupted,
    output reg rx_done,
    output [15:0] residue,
    output [1:0] rx_state
);

    localparam [1:0] R_IDLE = 2'd0,
                     R_RECV = 2'd1,
                     R_CHECK = 2'd2,
                     R_DONE = 2'd3;
                     
    reg [1:0] state;
    
    assign rx_state = state;
    
    crc16 #(.G(G), .INIT(INIT)) rx_crc (   // FIX 15: parameters now propagate
        .clk (clk),
        .rst (rst | rx_start),
        .en  (rx_valid),
        .din (rx_bit),
        .crc (residue)
    );
    
    always @(posedge clk) begin
        if(rst) begin
             state <= R_IDLE;
             received <= 1'b0;
             corrupted <= 1'b0;
             rx_done <= 1'b0;
        end else begin
            case (state)
                R_IDLE, R_DONE:
                    if(rx_start) begin
                        received <= 1'b0;
                        corrupted <= 1'b0;
                        rx_done <= 1'b0;
                        state <= R_RECV;
                    end
                R_RECV:
                    if(rx_last) state <= R_CHECK;
                R_CHECK: begin
                    received <= (residue == 16'h0000);
                    corrupted <= (residue != 16'h0000);
                    rx_done <= 1'b1;
                    state <= R_DONE; 
                end
                default:
                    state <= R_IDLE;
            endcase 
        end
    end
    
endmodule