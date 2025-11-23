module counter (
    // peripheral clock signals
    input clk,
    input rst_n,
    // register facing signals
    output [15:0] count_val,
    input [15:0] period,
    input en,
    input count_reset,
    input upnotdown,
    input [7:0]  prescale
);

    reg [15:0] count_val_reg;
    reg [15:0] presc_cnt;

    assign count_val = count_val_reg;

    wire [15:0] prescale_limit =
        (prescale[3:0] == 4'd0) ? 16'd0 :
        ((16'd1 << prescale[3:0]) - 16'd1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_val_reg <= 16'h0000;
            presc_cnt <= 16'h0000;
        end else begin
            if (count_reset) begin
                count_val_reg <= 16'h0000;
                presc_cnt <= 16'h0000;
            end else if (en) begin
                if (presc_cnt >= prescale_limit) begin
                    presc_cnt <= 16'h0000;

                    if (upnotdown) begin
                        if (count_val_reg >= period)
                            count_val_reg <= 16'h0000;
                        else
                            count_val_reg <= count_val_reg + 16'h0001;
                    end else begin
                        if (count_val_reg == 16'h0000)
                            count_val_reg <= period;
                        else
                            count_val_reg <= count_val_reg - 16'h0001;
                    end
                end else begin
                    presc_cnt <= presc_cnt + 16'h0001;
                end
            end
        end
    end

endmodule
