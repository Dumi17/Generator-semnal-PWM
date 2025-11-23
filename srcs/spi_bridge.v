module spi_bridge (
    // peripheral clock signals
    input clk,
    input rst_n,
    // SPI master facing signals
    input sclk,
    input cs_n,
    input miso,   
    output mosi    
);

    reg [1:0] sclk_sync;
    reg [1:0] cs_sync;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_sync <= 2'b00;
            cs_sync <= 2'b11;   
        end else begin
            sclk_sync <= {sclk_sync[0], sclk};
            cs_sync <= {cs_sync[0], cs_n};
        end
    end

    wire sclk_rise = (sclk_sync[1] == 1'b0) && (sclk_sync[0] == 1'b1);
    wire sclk_fall = (sclk_sync[1] == 1'b1) && (sclk_sync[0] == 1'b0);
    wire cs_active = (cs_sync[0] == 1'b0);

    reg [7:0] shift_reg;
    reg mosi_reg;

    assign mosi = mosi_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'h00;
            mosi_reg <= 1'b0;
        end else begin
            if (!cs_active) begin
                shift_reg <= 8'h00;
                mosi_reg <= 1'b0;
            end else begin
                if (sclk_rise) begin
                    shift_reg <= {shift_reg[6:0], miso};
                end
                if (sclk_fall) begin
                    mosi_reg <= shift_reg[7];
                end
            end
        end
    end

endmodule
