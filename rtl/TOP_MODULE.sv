module TOP_MODULE #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter BAUD_RATE  = 115200,   
    parameter CLK_FREQ   = 50_000_000,
    parameter BAUDTICK   = CLK_FREQ / (BAUD_RATE * 16)
) (
    input  logic clk,
    input  logic rst_n,
    input  logic uartrx_i,
    output logic uarttx_o
);

    // ======================================================
    //1. Khai bao cac tin hieu noi bo 
    // ======================================================

    // Module Baud_gen 
    logic s_tick;

    // Module UART_RX --> FIFO_RX
    logic [DATA_WIDTH-1 : 0] rx_data;
    logic                    rx_done;

    // Module FIFO_RX --> FIFO_TX
    logic [DATA_WIDTH-1 : 0] transfer_data;
    logic                    rx_empty;  // Handshake
    logic                    en_transfer;

    // Module FIFO_TX --> UART_TX
    logic [DATA_WIDTH-1 : 0] tx_data;
    logic                    tx_empty;
    logic                    tx_start;
    logic                    tx_done;
    logic                    tx_full;  // Handshake

    // ==================================================
    //2. Mach logic dieu khien Handshake
    // ==================================================

    //A. Tin hieu Handshake
    assign en_transfer = (~rx_empty) & (~tx_full);

    //B. Tin hieu co du lieu ben trong khoi FIFO_TX
    assign tx_start = (~tx_empty);

    // ===================================================
    //3. Khoi tao cac Module 
    // ===================================================

    //A. Baud_gen
    uart_baud_gen #(
        .BAUDTICK  (BAUDTICK)
    ) u_uart_baud_gen (
        .clk       (clk),
        .rst_n     (rst_n),
        .s_tick_o  (s_tick)
    );

    //B. UART_RX
    uart_rx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_uart_rx (
        .clk       (clk),
        .rst_n     (rst_n),
        .uartrx_i  (uartrx_i),
        .s_tick_i  (s_tick),
        .rxdone_o  (rx_done),
        .uartrx_o  (rx_data)
    );

    //C. FIFO_RX
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_fifo_rx (
        .clk       (clk),
        .rst_n     (rst_n),
        .wr_en     (rx_done),
        .wr_data_i (rx_data),
        .rd_en     (en_transfer),
        .empty_o   (rx_empty),
        .full_o    (), // Bo trong, mach khong dung tin hieu nay 
        .rd_data_o (transfer_data)
    );

    //D. FIFO_TX
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_fifo_tx (
        .clk       (clk),
        .rst_n     (rst_n),
        .wr_data_i (transfer_data),
        .full_o    (tx_full),
        .wr_en     (en_transfer),
        .rd_en     (tx_done),
        .empty_o   (tx_empty),
        .rd_data_o (tx_data)
    );

    //E. UART_TX
    uart_tx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .txdone_o(tx_done),
        .txstart_i(tx_start),
        .uarttx_i(tx_data),
        .uarttx_o(uarttx_o),
        .s_tick_i(s_tick)
    );
    
endmodule
