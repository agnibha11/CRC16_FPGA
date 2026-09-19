module crc_top (
    input clk,            //Y9   100 MHz
    input btn_rst,        //BTND R16
    input sw_override,    //SW0  F22
    input sw_load_sel,    //SW1  G22
    input btn_start_tx,   //BTNR R18
    input btn_par_load,   //BTNL N15
    output [5:0] led      //LD0..5
);

//2 flop synchronizer as slide switches are asynchronous to clk
reg [1:0] sync_rst, sync_ovr, sync_lsel, sync_parld, sync_start;

always @(posedge clk) begin
    sync_rst   <= {sync_rst  [0], btn_rst};
    sync_ovr   <= {sync_ovr  [0], sw_override};
    sync_lsel  <= {sync_lsel [0], sw_load_sel};
    sync_parld <= {sync_parld[0], btn_par_load};
    sync_start <= {sync_start[0], btn_start_tx};
end

wire rst_s   = sync_rst  [1];
wire ovr_s   = sync_ovr  [1];
wire lsel_s  = sync_lsel [1];
wire parld_s = sync_parld[1];
wire start_s = sync_start[1];

//VIO Nets
wire vio_clr, vio_err_en;          
wire [5:0]  vio_err_idx;
wire [47:0] vio_par_data;
wire [5:0]  vio_par_len;

wire [47:0] codeword;
wire [15:0] crc_out, residue;   
wire [5:0] cw_len, msg_len, cust_len;   
wire received, corrupted, tx_ready, rx_done, ser_busy;
wire [2:0] tx_state;           
                                
crc_core u_core(
    .clk(clk),
    .rst(rst_s),               
    .par_data(vio_par_data),   
    .par_len (vio_par_len),
    .par_load(parld_s),
    .load_sel(lsel_s),
    .start_tx(start_s),
    .clr(vio_clr),
    .override(ovr_s),
    .err_en(vio_err_en),
    .err_index(vio_err_idx),
    .codeword(codeword),
    .cw_len(cw_len),
    .msg_len(msg_len),
    .cust_len(cust_len),
    .crc_out(crc_out),
    .residue(residue),
    .received(received),
    .corrupted(corrupted),
    .tx_ready(tx_ready),       
    .rx_done(rx_done),
    .tx_state(tx_state),
    .stream_bit(),
    .stream_valid(),
    .ser_busy(ser_busy)
);

//wire [5:0] status = {received, corrupted, tx_ready, rx_done, override_i, load_sel_i};

assign led[0] = received;
assign led[1] = corrupted;
assign led[2] = tx_ready;
assign led[3] = rx_done;
assign led[4] = ovr_s;
assign led[5] = lsel_s;


//VIO
vio_0 u_vio (
    .clk        (clk),
    .probe_in0  (codeword),
    .probe_in1  (crc_out),
    .probe_in2  (residue),
    .probe_in3  (cw_len),
    .probe_in4  (msg_len),
    .probe_in5  (cust_len),
    .probe_in6  (tx_state),
    .probe_out0 (vio_clr),
    .probe_out1 (vio_err_en),
    .probe_out2 (vio_err_idx),
    .probe_out3 (vio_par_data),
    .probe_out4 (vio_par_len)
);

endmodule
