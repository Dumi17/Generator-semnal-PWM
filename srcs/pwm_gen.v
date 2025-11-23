module pwm_gen (
    // peripheral clock signals
    input clk,
    input rst_n,
    // PWM signal register configuration
    input pwm_en,
    input [15:0] period,
    input [7:0] functions,
    input [15:0] compare1,
    input [15:0] compare2,
    input [15:0] count_val,
    // top facing signals
    output pwm_out
);

    reg pwm_reg;
    assign pwm_out = pwm_reg;
    
    wire align_mode = (functions[1] == 1'b0);
    wire right_align = (functions[0] == 1'b1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_reg <= 1'b0;
        end else begin
            if (!pwm_en) begin
                pwm_reg <= pwm_reg;
            end else begin
                if (align_mode) begin
                    if (!right_align) begin
                        pwm_reg <= (count_val < compare1) ? 1'b1 : 1'b0;
                    end else begin
                        pwm_reg <= (count_val >= (period - compare1)) ? 1'b1 : 1'b0;
                    end
                end else begin
                    pwm_reg <= (count_val >= compare1 && count_val < compare2) ? 1'b1 : 1'b0;
                end
            end
        end
    end

endmodule
