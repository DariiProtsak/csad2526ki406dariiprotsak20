module i2c_tb;

    // Параметри тестування
    parameter CLK_PERIOD = 20;  // 50 МГц (20 нс період)
    parameter TEST_ADDR  = 7'b1010101;  // Тестова адреса slave
    parameter TEST_DATA  = 8'hA5;       // Тестові дані

    // Сигнали
    reg         clk;
    reg         rst_n;
    reg         start_cmd;
    reg  [6:0]  slave_addr;
    reg         rw_bit;
    reg  [7:0]  data_in;
    wire [7:0]  data_out_master;
    wire        busy;
    wire        scl;
    wire        sda;
    wire        done;
    wire [7:0]  data_received;
    wire        data_valid;

    // Pull-up резистори для SDA (імітація)
    pullup(sda);

    // Екземпляр Master
    i2c_master master (
        .clk(clk),
        .rst_n(rst_n),
        .start_cmd(start_cmd),
        .slave_addr(slave_addr),
        .rw_bit(rw_bit),
        .data_in(data_in),
        .data_out(data_out_master),
        .busy(busy),
        .scl(scl),
        .sda(sda),
        .done(done)
    );

    // Екземпляр Slave
    i2c_slave slave (
        .clk(clk),
        .rst_n(rst_n),
        .my_addr(TEST_ADDR),
        .scl(scl),
        .sda(sda),
        .data_received(data_received),
        .data_valid(data_valid)
    );

    // Генерація тактового сигналу
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Тестовий сценарій
    initial begin
        // Ініціалізація
        rst_n = 0;
        start_cmd = 0;
        slave_addr = 7'd0;
        rw_bit = 0;
        data_in = 8'd0;

        // Генерація VCD файлу для аналізу
        $dumpfile("i2c_test.vcd");
        $dumpvars(0, i2c_tb);

        // Скид системи
        #100;
        rst_n = 1;
        #100;

        $display("=== Початок тестування I2C протоколу ===");
        $display("Час: %0t ns", $time);

        // Тест 1: Передача даних 0xA5 на адресу 0x55
        #200;
        slave_addr = TEST_ADDR;
        rw_bit = 0;  // Write
        data_in = TEST_DATA;
        start_cmd = 1;
        #40;
        start_cmd = 0;

        $display("Тест 1: Передача 0x%h на адресу 0x%h", TEST_DATA, TEST_ADDR);

        // Очікування завершення
        wait(done);
        #100;
        
        if (data_valid && data_received == TEST_DATA) begin
            $display("✓ УСПІХ: Дані прийняті коректно: 0x%h", data_received);
        end else begin
            $display("✗ ПОМИЛКА: Очікувалось 0x%h, отримано 0x%h", TEST_DATA, data_received);
        end

        // Тест 2: Передача даних 0x3C на ту ж адресу
        #500;
        data_in = 8'h3C;
        start_cmd = 1;
        #40;
        start_cmd = 0;

        $display("Тест 2: Передача 0x3C на адресу 0x%h", TEST_ADDR);

        wait(done);
        #100;
        
        if (data_valid && data_received == 8'h3C) begin
            $display("✓ УСПІХ: Дані прийняті коректно: 0x%h", data_received);
        end else begin
            $display("✗ ПОМИЛКА: Очікувалось 0x3C, отримано 0x%h", data_received);
        end

        // Тест 3: Передача на невірну адресу (має бути NACK)
        #500;
        slave_addr = 7'b0001111;  // Інша адреса
        data_in = 8'hFF;
        start_cmd = 1;
        #40;
        start_cmd = 0;

        $display("Тест 3: Передача на невірну адресу 0x%h", 7'b0001111);

        wait(done);
        #100;
        
        if (!data_valid) begin
            $display("✓ УСПІХ: Slave ігнорує пакет (адреса не співпадає)");
        end else begin
            $display("✗ ПОМИЛКА: Slave не повинен був приймати дані");
        end

        #1000;
        $display("=== Тестування завершено ===");
        $finish;
    end

    // Моніторинг сигналів
    always @(posedge data_valid) begin
        $display("Час: %0t ns - Slave отримав дані: 0x%h", $time, data_received);
    end

endmodule
