module crc_top (
    input clk, //Y9, 100 MHz
    input sw_rst, // SW7 M15
    input sw_override, // SW0 F22
    input sw_load_sel, // SW1 G22
    output [7:0] led //LD0..7
);

//2 flop synchronizer as slide switches are asynchronous to clk
reg [1:0] sync_rst, sync_ovr, sync_lsel;

always @(posedge clk) begin
    sync_rst <= {sync_rst[0], sw_rst};
    sync_ovr <= {sync_ovr[0], sw_override};
    sync_lsel <= {sync_lsel[0], sw_load_sel};
end

wire rst_s  = sync_rst [1];
wire ovr_s  = sync_ovr [1];
wire lsel_s = sync_lsel[1];

//VIO Nets
wire vio_rst, vio_start_tx, vio_clr;
wire vio_override, vio_load_sel, vio_err_en;
wire [5:0] vio_err_idx;
wire [47:0] vio_par_data;
wire [5:0] vio_par_len;
wire vio_par_load;

wire [47:0] codeword;
wire [15:0] crc_out, residue;   // FIX 8: was `reside`, so every use of `residue`
wire [5:0] cw_len, msg_len, cust_len;   // became an implicit 1-bit wire.
wire received, corrupted, tx_ready, rx_done, ser_busy;
wire [2:0] tx_state;            // FIX 9: was never declared -- implicit 1 bit,
                                // but led[7:5] needs 3.
wire override_i = ovr_s | vio_override;
wire load_sel_i = lsel_s | vio_load_sel;
wire rst_i = rst_s | vio_rst;

crc_core u_core(
    .clk(clk),
    .rst(rst_i),               // FIX 10: was `rst`, which does not exist here.
    .par_data(vio_par_data),   // Reset never reached the design.
    .par_len (vio_par_len),
    .par_load(vio_par_load),
    .load_sel(load_sel_i),
    .start_tx(vio_start_tx),
    .clr(vio_clr),
    .override(override_i),
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
    .tx_ready(tx_ready),       // FIX 1: was `.tx_read(tx_read)` -- not a port.
    .rx_done(rx_done),
    .tx_state(tx_state),
    .stream_bit(),
    .stream_valid(),
    .ser_busy(ser_busy)
);

wire [5:0] status = {received, corrupted, tx_ready, rx_done, override_i, load_sel_i};

assign led[0] = received;
assign led[1] = corrupted;
assign led[2] = tx_ready;
assign led[3] = rx_done;
assign led[4] = override_i;
assign led[7:5] = tx_state;

//VIO
    vio_0 u_vio (
        .clk        (clk),
        .probe_in0  (codeword),
        .probe_in1  (crc_out),
        .probe_in2  (residue),
        .probe_in3  (cw_len),
        .probe_in4  (msg_len),
        .probe_in5  (cust_len),
        .probe_in6  (status),
        .probe_in7  (tx_state),
        .probe_out0 (vio_rst),
        .probe_out1 (vio_start_tx),
        .probe_out2 (vio_clr),
        .probe_out3 (vio_override),
        .probe_out4 (vio_load_sel),
        .probe_out5 (vio_err_en),
        .probe_out6 (vio_err_idx),
        .probe_out7 (vio_par_data),
        .probe_out8 (vio_par_len),
        .probe_out9 (vio_par_load)
    );

endmodule
