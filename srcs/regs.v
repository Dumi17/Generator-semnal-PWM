module regs (
    input clk,
    input rst_n,
    input read,
    input write,
    input[5:0] addr,
    input high_byte,
    output[7:0] data_read,
    input[7:0] data_write,
    input[15:0] counter_val,
    output[15:0] period,
    output en,
    output count_reset,
    output upnotdown,
    output[7:0] prescale,
    output pwm_en,
    output[7:0] functions,
    output[15:0] compare1,
    output[15:0] compare2
);

localparam ADDR_PERIOD         = 6'h00;
localparam ADDR_COUNTER_EN     = 6'h02;
localparam ADDR_COMPARE1       = 6'h03;
localparam ADDR_COMPARE2       = 6'h05;
localparam ADDR_COUNTER_RESET  = 6'h07;
localparam ADDR_COUNTER_VAL    = 6'h08;
localparam ADDR_PRESCALE       = 6'h0A;
localparam ADDR_UPNOTDOWN      = 6'h0B;
localparam ADDR_PWM_EN         = 6'h0C;
localparam ADDR_FUNCTIONS      = 6'h0D;

reg [15:0] period_reg;
reg        counter_en_reg;
reg [15:0] compare1_reg;
reg [15:0] compare2_reg;
reg        counter_reset_reg;
reg [1:0]  counter_reset_cnt; 
reg [7:0]  prescale_reg;
reg        upnotdown_reg;
reg        pwm_en_reg;
reg [7:0]  functions_reg;

reg [7:0] data_read_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        period_reg <= 16'h0000;
    end else if (write && addr == ADDR_PERIOD) begin
        if (high_byte)
            period_reg[15:8] <= data_write;
        else
            period_reg[7:0] <= data_write;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_en_reg <= 1'b0;
    end else if (write && addr == ADDR_COUNTER_EN) begin
        counter_en_reg <= data_write[0];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        compare1_reg <= 16'h0000;
    end else if (write && addr == ADDR_COMPARE1) begin
        if (high_byte)
            compare1_reg[15:8] <= data_write;
        else
            compare1_reg[7:0] <= data_write;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        compare2_reg <= 16'h0000;
    end else if (write && addr == ADDR_COMPARE2) begin
        if (high_byte)
            compare2_reg[15:8] <= data_write;
        else
            compare2_reg[7:0] <= data_write;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_reset_reg <= 1'b0;
        counter_reset_cnt <= 2'd0;
    end else begin
        if (write && addr == ADDR_COUNTER_RESET && data_write[0]) begin
            counter_reset_reg <= 1'b1;
            counter_reset_cnt <= 2'd2;
        end else if (counter_reset_cnt > 0) begin
            counter_reset_cnt <= counter_reset_cnt - 1'b1;
            if (counter_reset_cnt == 1) begin
                counter_reset_reg <= 1'b0;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prescale_reg <= 8'h00;
    end else if (write && addr == ADDR_PRESCALE) begin
        prescale_reg <= data_write;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        upnotdown_reg <= 1'b1; 
    end else if (write && addr == ADDR_UPNOTDOWN) begin
        upnotdown_reg <= data_write[0];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_en_reg <= 1'b0;
    end else if (write && addr == ADDR_PWM_EN) begin
        pwm_en_reg <= data_write[0];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        functions_reg <= 8'h00;
    end else if (write && addr == ADDR_FUNCTIONS) begin
        functions_reg <= data_write;
    end
end

always @(*) begin
    case (addr)
        ADDR_PERIOD: begin
            if (high_byte)
                data_read_reg = period_reg[15:8];
            else
                data_read_reg = period_reg[7:0];
        end
        ADDR_COUNTER_EN:    data_read_reg = {7'b0, counter_en_reg};
        ADDR_COMPARE1: begin
            if (high_byte)
                data_read_reg = compare1_reg[15:8];
            else
                data_read_reg = compare1_reg[7:0];
        end
        ADDR_COMPARE2: begin
            if (high_byte)
                data_read_reg = compare2_reg[15:8];
            else
                data_read_reg = compare2_reg[7:0];
        end
        ADDR_COUNTER_RESET: data_read_reg = 8'h00; 
        ADDR_COUNTER_VAL: begin
            if (high_byte)
                data_read_reg = counter_val[15:8];
            else
                data_read_reg = counter_val[7:0];
        end
        ADDR_PRESCALE:      data_read_reg = prescale_reg;
        ADDR_UPNOTDOWN:     data_read_reg = {7'b0, upnotdown_reg};
        ADDR_PWM_EN:        data_read_reg = {7'b0, pwm_en_reg};
        ADDR_FUNCTIONS:     data_read_reg = functions_reg;
        default:            data_read_reg = 8'h00;
    endcase
end

assign period = period_reg;
assign en = counter_en_reg;
assign count_reset = counter_reset_reg;
assign upnotdown = upnotdown_reg;
assign prescale = prescale_reg;
assign pwm_en = pwm_en_reg;
assign functions = functions_reg;
assign compare1 = compare1_reg;
assign compare2 = compare2_reg;
assign data_read = data_read_reg;

endmodule
