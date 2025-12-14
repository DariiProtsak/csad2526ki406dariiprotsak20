    module i2c_slave (
    input  wire        clk,          // Системний тактовий сигнал
    input  wire        rst_n,        // Асинхронний скид
    input  wire [6:0]  my_addr,      // Адреса цього slave-пристрою
    input  wire        scl,          // I2C Clock від Master
    inout  wire        sda,          // I2C Data Line
    output reg  [7:0]  data_received,// Прийняті дані
    output reg         data_valid    // Прапорець валідності даних
);

    // Параметри FSM
    localparam IDLE           = 3'd0;
    localparam RCV_ADDRESS    = 3'd1;
    localparam SEND_ACK_ADDR  = 3'd2;
    localparam RCV_DATA       = 3'd3;
    localparam SEND_ACK_DATA  = 3'd4;
    localparam WAIT_STOP      = 3'd5;

    // Внутрішні регістри
    reg [2:0]  state;
    reg [3:0]  bit_counter;
    reg [7:0]  shift_reg;
    reg        sda_out;
    reg        sda_enable;
    reg        prev_scl;
    reg        prev_sda;
    
    // Керування SDA
    assign sda = sda_enable ? sda_out : 1'bz;

    // Детектування START та STOP умов
    wire start_detected = prev_sda & ~sda & scl;
    wire stop_detected  = ~prev_sda & sda & scl;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            sda_enable    <= 1'b0;
            sda_out       <= 1'b1;
            bit_counter   <= 0;
            shift_reg     <= 8'd0;
            data_received <= 8'd0;
            data_valid    <= 1'b0;
            prev_scl      <= 1'b1;
            prev_sda      <= 1'b1;
        end else begin
            prev_scl <= scl;
            prev_sda <= sda;
            
            case (state)
                IDLE: begin
                    sda_enable <= 1'b0;
                    data_valid <= 1'b0;
                    
                    if (start_detected) begin
                        state       <= RCV_ADDRESS;
                        bit_counter <= 7;
                        shift_reg   <= 8'd0;
                    end
                end

                RCV_ADDRESS: begin
                    if (prev_scl & ~scl) begin  // Спадаючий фронт SCL
                        shift_reg   <= {shift_reg[6:0], sda};
                        
                        if (bit_counter == 0) begin
                            // Перевірка адреси
                            if (shift_reg[7:1] == my_addr) begin
                                state <= SEND_ACK_ADDR;
                            end else begin
                                state <= IDLE;
                            end
                        end else begin
                            bit_counter <= bit_counter - 1;
                        end
                    end
                end

                SEND_ACK_ADDR: begin
                    sda_enable <= 1'b1;
                    sda_out    <= 1'b0;  // ACK
                    
                    if (~prev_scl & scl) begin  // Підйом SCL
                        state       <= RCV_DATA;
                        bit_counter <= 7;
                        shift_reg   <= 8'd0;
                        sda_enable  <= 1'b0;
                    end
                end

                RCV_DATA: begin
                    if (prev_scl & ~scl) begin
                        shift_reg <= {shift_reg[6:0], sda};
                        
                        if (bit_counter == 0) begin
                            state <= SEND_ACK_DATA;
                        end else begin
                            bit_counter <= bit_counter - 1;
                        end
                    end
                end

                SEND_ACK_DATA: begin
                    sda_enable    <= 1'b1;
                    sda_out       <= 1'b0;  // ACK
                    data_received <= shift_reg;
                    data_valid    <= 1'b1;
                    
                    if (~prev_scl & scl) begin
                        state      <= WAIT_STOP;
                        sda_enable <= 1'b0;
                    end
                end

                WAIT_STOP: begin
                    if (stop_detected) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
