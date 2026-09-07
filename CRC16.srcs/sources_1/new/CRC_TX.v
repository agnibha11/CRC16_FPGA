module crc_tx #(
    parameter [15:0] G = 16'h1021,
    parameter [15:0] INIT = 16'hFFFF,
    parameter integer MAX_MSG = 32
)(
    input clk, rst,
    //serial message input
    input bit_in, bit_push, msg_end,

    //parallel write port to the memory
    output reg [47:0] cw_data, //codeword
    output reg [5:0] cw_len ,  //length = msg_len + 16
    output reg cw_we,

    output reg [5:0] msg_len,
    output [15:0] crc,
    output [1:0] tx_state
);

localparam [1:0] T_LOAD = 2'd0, //accepting message bits
                 T_APPEND = 2'd1, // one-cycle: assemble and write
                 T_DONE = 2'd2; //codeword handed to memory

reg [1:0] state;
reg [47:0] msg_buf;

assign tx_state = state;

//accept a bit only while loading and only upto MAX_MSG bits

wire ld_en = (state == T_LOAD) & bit_push & (msg_len < MAX_MSG);

crc16 #(.G(G), .INIT(INIT)) tx_crc (   // FIX 15: parameters now propagate
    .clk(clk),
    .rst(rst),
    .en(ld_en),
    .din(bit_in),
    .crc(crc)
);


always @(posedge clk) begin
    if(rst) begin
        state <= T_LOAD;
        msg_buf <= 48'b0;
        msg_len <= 6'd0;      // FIX 11: was missing. Without it msg_len is X in
        cw_data <= 48'b0;     // simulation, and clr never cleared it on hardware,
        cw_len <= 6'd0;       // so a second message appended to the first.
        cw_we <= 1'b0;
    end else begin
        cw_we <= 1'b0;

        case(state)
            T_LOAD: begin
                if(ld_en) begin
                    msg_buf <= {msg_buf[46:0], bit_in};
                    msg_len <= msg_len + 6'd1;
                end

                if(msg_end && (msg_len != 6'd0)) begin
                    state <= T_APPEND;
                end
            end

            T_APPEND: begin
                cw_data <= (msg_buf << 16) | {32'd0,crc};   // FIX 13: was `=`,
                cw_len <= msg_len + 6'd16;                  // a blocking assign
                cw_we <= 1'b1;                              // inside a clocked block
                state <= T_DONE;
            end

            T_DONE: begin

            end

            default: state <= T_LOAD;   // FIX 14: was missing; state 2'd3 would stick
        endcase

    end
end

endmodule
