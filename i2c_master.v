    module i2c_master (
    input  wire        clk,          // Системний тактовий сигнал (наприклад, 50 МГц)
    input  wire        rst_n,        // Асинхронний скид (активний низький)
    input  wire        start_cmd,    // Команда на початок передачі
    input  wire [6:0]  slave_addr,   // 7-бітна адреса slave-пристрою
    input  wire        rw_bit,       // 0 = Write, 1 = Read
    input  wire [7:0]  data_in,      // Дані для передачі
    output reg  [7:0]  data_out,     // Прийняті дані (для режиму read)
    output reg         busy,         // Прапорець зайнятості
    output reg         scl,          // I2C Clock Line
    inout  wire        sda,          // I2C Data Line (bidirectional)
    output reg         done          // Прапорець завершення транзакції
);

    // Параметри FSM
    localparam IDLE        = 4'd0;
    localparam START       = 4'd1;
    localparam ADDRESS     = 4'd2;
    localparam RW_BIT      = 4'd3;
    localparam ACK_ADDR    = 4'd4;
    localparam DATA        = 4'd5;
    localparam ACK_DATA    = 4'd6;
    localparam STOP        = 4'd7;

    // Генерація I2C clock (100 кГц з 50 МГц системного clock)
    localparam DIVIDER = 250;  // 50 МГц / (2 * 100 кГц) = 250
    
    reg [8:0] clk_divider;
    reg       i2c_clk;
    
    // Генератор I2C clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_divider <= 0;
            i2c_clk <= 1'b1;
        end else begin
            if (clk_divider == DIVIDER - 1) begin
                clk_divider <= 0;
                i2c_clk <= ~i2c_clk;
            end else begin
                clk_divider <= clk_divider + 1;
            end
        end
    end

    // Внутрішні регістри
    reg [3:0]  state;
    reg [3:0]  bit_counter;
    reg [7:0]  shift_reg;
    reg        sda_out;
    reg        sda_enable;  // Керування напрямком SDA (0 = input, 1 = output)
    
    // Керування двонаправленою лінією SDA
    assign sda = sda_enable ? sda_out : 1'bz;

    // Основна FSM
    always @(posedge i2c_clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            scl         <= 1'b1;
            sda_out     <= 1'b1;
            sda_enable  <= 1'b0;
            busy        <= 1'b0;
            done        <= 1'b0;
            bit_counter <= 0;
            shift_reg   <= 8'd0;
            data_out    <= 8'd0;
        end else begin
            case (state)
                // Стан очікування
                IDLE: begin
                    scl        <= 1'b1;
                    sda_out    <= 1'b1;
                    sda_enable <= 1'b0;
                    done       <= 1'b0;
                    
                    if (start_cmd) begin
                        busy       <= 1'b1;
                        state      <= START;
                        shift_reg  <= {slave_addr, rw_bit};
                    end else begin
                        busy <= 1'b0;
                    end
                end

                // Генерація умови START
                START: begin
                    sda_enable <= 1'b1;
                    sda_out    <= 1'b0;  // SDA: 1→0 при SCL=1
                    scl        <= 1'b1;
                    bit_counter <= 7;
                    state      <= ADDRESS;
                end

                // Передача 7 біт адреси + 1 біт R/W
                ADDRESS: begin
                    scl        <= 1'b0;
                    sda_out    <= shift_reg[7];
                    shift_reg  <= shift_reg << 1;
                    
                    if (bit_counter == 0) begin
                        state <= ACK_ADDR;
                    end else begin
                        bit_counter <= bit_counter - 1;
                    end
                end

                // Очікування ACK від slave
                ACK_ADDR: begin
                    scl        <= 1'b1;
                    sda_enable <= 1'b0;  // Slave керує SDA
                    
                    // Перевірка ACK (SDA повинна бути 0)
                    if (sda == 1'b0) begin
                        shift_reg   <= data_in;
                        bit_counter <= 7;
                        state       <= DATA;
                    end else begin
                        // NACK - повернутися до IDLE
                        state <= STOP;
                    end
                end

                // Передача 8 біт даних
                DATA: begin
                    scl        <= 1'b0;
                    sda_enable <= 1'b1;
                    sda_out    <= shift_reg[7];
                    shift_reg  <= shift_reg << 1;
                    
                    if (bit_counter == 0) begin
                        state <= ACK_DATA;
                    end else begin
                        bit_counter <= bit_counter - 1;
                    end
                end

                // Очікування ACK після даних
                ACK_DATA: begin
                    scl        <= 1'b1;
                    sda_enable <= 1'b0;  // Slave керує SDA
                    
                    if (sda == 1'b0) begin
                        state <= STOP;
                    end else begin
                        // NACK
                        state <= STOP;
                    end
                end

                // Генерація умови STOP
                STOP: begin
                    scl        <= 1'b1;
                    sda_enable <= 1'b1;
                    sda_out    <= 1'b0;
                    
                    // Наступний такт: SDA: 0→1 при SCL=1
                    done  <= 1'b1;
                    busy  <= 1'b0;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
    
end Behavioral;
