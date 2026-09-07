module crc_core #(
    parameter [15:0]  G = 16'h1021,
    parameter [15:0]  INIT = 16'hFFFF,
    parameter integer MAX_MSG = 32,
    parameter integer MAX_CW  = 48
)(
    input clk, rst,
    input [47:0] par_data,
    input [5:0] par_len,
    input par_load,
    input load_sel,

    input start_tx,
    input clr,

    input override, err_en,
    input [5:0] err_index,

    //observations
    output [47:0] codeword,
    output [5:0]  cw_len,
    output [5:0]  msg_len,
    output [5:0]  cust_len,
    output [15:0] crc_out,
    output [15:0] residue,
    output received,
    output corrupted,
    output tx_ready,
    output rx_done,
    output [2:0] tx_state,
    output stream_bit,
    output stream_valid,
    output ser_busy
);

//VIO edge detection
reg start_d, clr_d, parld_d;

always @(posedge clk) begin
    start_d <= start_tx;
    clr_d <= clr;
    parld_d <= par_load;
end

wire start_pulse = start_tx & ~start_d;
wire clr_pulse = clr & ~clr_d;
wire parld_pulse = par_load & ~parld_d;

wire flush = rst | clr_pulse;

wire ser_bit, ser_valid;


serializer #(.WIDTH(MAX_CW)) u_ser(
    .clk(clk),
    .rst(flush),
    .par_data(par_data),
    .par_len(par_len),
    .par_load(parld_pulse),
    .bit_out(ser_bit),
    .bit_valid(ser_valid),
    .busy(ser_busy)
);

//destination latch
reg dest_sel;

always @(posedge clk) begin
    if(flush) dest_sel <= 1'b0;
    else if(parld_pulse) dest_sel <= load_sel;
end

//selecting which detination the serializer will load
wire ld_bit = ser_bit;
wire ld_push = ser_valid;

wire tx_push = ld_push & ~dest_sel;
wire cust_push = ld_push & dest_sel;

//end of message
reg ser_busy_d;

always @(posedge clk) begin
    if(flush) ser_busy_d <= 1'b0;
    else ser_busy_d <= ser_busy;
end

wire ser_done = ser_busy_d & ~ser_busy;
wire msg_end = ser_done & ~dest_sel;

//Transmitter
wire [47:0] tx_cw_data;
wire [5:0] tx_cw_len;
wire tx_cw_we;
wire [1:0] tx_st;

crc_tx #(.G(G), .INIT(INIT), .MAX_MSG(MAX_MSG)) u_tx(
    .clk(clk),
    .rst(flush),
    .bit_in(ld_bit),
    .bit_push(tx_push),
    .msg_end(msg_end),
    .cw_data(tx_cw_data),
    .cw_len(tx_cw_len),
    .cw_we(tx_cw_we),
    .msg_len(msg_len),
    .crc(crc_out),
    .tx_state(tx_st)
);

//Memory
wire mem_rd_start, cust_rd_start;
wire mem_bit_raw, mem_valid, mem_last, mem_stored;
wire [5:0] mem_index;

msg_mem #(.DEPTH(MAX_CW)) u_mem(
    .clk(clk),
    .rst(flush),
    .we(tx_cw_we),
    .wdata(tx_cw_data),      
    .wlen(tx_cw_len),
    .rd_start(mem_rd_start),
    .rd_bit(mem_bit_raw),
    .rd_valid(mem_valid),
    .rd_last(mem_last),
    .rd_index(mem_index),
    .stored_word (codeword), 
    .stored_len (cw_len),    
    .stored_valid (mem_stored)
);

//Custom Input Buffer
wire cust_bit, cust_valid, cust_last;
wire [5:0] cust_index;
wire [47:0] cust_word;

custom_buff #(.DEPTH(MAX_CW)) u_cust(   
    .clk(clk),                          
    .rst(flush),
    .bit_in(ld_bit),
    .bit_push(cust_push),
    .rd_start(cust_rd_start),
    .rd_bit(cust_bit),
    .rd_valid(cust_valid),
    .rd_last(cust_last),
    .rd_index(cust_index),
    .stored_word(cust_word),
    .stored_len(cust_len)
);

//Launch
wire busy = mem_valid | cust_valid; //channel busy
wire [5:0] ser_len = override ? cust_len : cw_len;

wire go = start_pulse & ~busy & (ser_len != 6'd0);

assign mem_rd_start = go & ~override;
assign cust_rd_start = go & override;

assign tx_ready = mem_stored & ~busy;

//Signal Error
wire err_bit  = err_en & mem_valid & (mem_index == err_index);
wire mem_bit  = mem_bit_raw ^ err_bit;

assign stream_bit   = override ? cust_bit   : mem_bit;
assign stream_valid = override ? cust_valid : mem_valid;

wire stream_last = override ? cust_last : mem_last;


//Receiver
wire [1:0] rx_st;

crc_rx #(.G(G), .INIT(INIT)) u_rx (
   .clk(clk),
   .rst(flush),
   .rx_start(go),               // one cycle before the first bit
   .rx_bit(stream_bit),
   .rx_valid(stream_valid),
   .rx_last(stream_last),
   .received(received),
   .corrupted(corrupted),
   .rx_done(rx_done),
   .residue(residue),
   .rx_state(rx_st)
);

//For LEDs
assign tx_state = {busy, tx_st};

endmodule
