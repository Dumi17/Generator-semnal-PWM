module spi_bridge (
    input clk,
    input rst_n,
    input sclk,
    input cs_n,
    input mosi,
    output miso,
    output byte_sync,
    output[7:0] data_in,
    input[7:0] data_out
);

reg [2:0] bit_cnt;

reg [7:0] rx_shift;

reg [7:0] tx_shift;

reg miso_reg;

reg [7:0] rx_data_sclk;
reg byte_done_sclk;

reg byte_done_sync1, byte_done_sync2, byte_done_sync3;
reg [7:0] rx_data_latched;
reg byte_sync_reg; 

always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
        bit_cnt <= 3'd0;
        rx_shift <= 8'd0;
        rx_data_sclk <= 8'd0;
        byte_done_sclk <= 1'b0;
    end else if (cs_n) begin
        bit_cnt <= 3'd0;
    end else begin
        rx_shift <= {rx_shift[6:0], mosi};
        
        if (bit_cnt == 3'd7) begin
            rx_data_sclk <= {rx_shift[6:0], mosi};
            byte_done_sclk <= ~byte_done_sclk; 
            bit_cnt <= 3'd0;
        end else begin
            bit_cnt <= bit_cnt + 1'b1;
        end
    end
end

always @(negedge sclk or negedge rst_n) begin
    if (!rst_n) begin
        tx_shift <= 8'd0;
        miso_reg <= 1'b0;
    end else if (cs_n) begin
        miso_reg <= 1'b0;
    end else begin
        if (bit_cnt == 3'd0) begin
            tx_shift <= data_out;
            miso_reg <= data_out[7];
        end else begin
            miso_reg <= tx_shift[7];
            tx_shift <= {tx_shift[6:0], 1'b0};
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        byte_done_sync1 <= 1'b0;
        byte_done_sync2 <= 1'b0;
        byte_done_sync3 <= 1'b0;
        rx_data_latched <= 8'd0;
        byte_sync_reg <= 1'b0;
    end else begin
        byte_done_sync1 <= byte_done_sclk;
        byte_done_sync2 <= byte_done_sync1;
        byte_done_sync3 <= byte_done_sync2;
        
        if (byte_done_sync2 != byte_done_sync3) begin
            rx_data_latched <= rx_data_sclk;
        end
        
        byte_sync_reg <= (byte_done_sync2 != byte_done_sync3);
    end
end

assign byte_sync = byte_sync_reg;
assign data_in = rx_data_latched;
assign miso = miso_reg;

endmodule
