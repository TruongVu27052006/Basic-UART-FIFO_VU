📌 **Key Features**

*   **Core Architecture:** Modular RTL design consisting of independent blocks: Transmitter (`uart_tx`), Receiver (`uart_rx`), and Baud Rate Generator (`baud_gen`).
*   **Data Buffering:** Integrated zero-latency FWFT (First-Word Fall-Through) FIFOs, enabling high-performance RX/TX data streams without throughput bottlenecks.
*   **Hardware Auto-Loopback:** Integrated at the hardware level within the Top module with a seamless handshake mechanism (`en_transfer = ~rx_empty & ~tx_full`), allowing for immediate echo testing.
*   **Highly Configurable:** Fully parameterized data width (`DATA_WIDTH`), baud sampling ticks (`BAUDTICK`), and FIFO depth (`ADDR_WIDTH`), facilitating flexible system integration.
*   **Verification:** Provides a comprehensive SystemVerilog testbench (`tb_top_module.sv`) running on Questa/ModelSim, utilizing a Python-generated Golden Model (`golden_vectors.hex`) for self-checking and burst-read scenarios.

📁 **Directory Structure**

*   `SRC/` : Contains SystemVerilog RTL source code (`top_module.sv`, `uart_rx.sv`, `uart_tx.sv`, `baud_gen.sv`, `fifo.sv`) and the Testbench environment (`tb_top_module.sv`, `golden_vectors.hex`).
*   `REPORT/` : Contains detailed project documentation, architectural block diagrams, and waveform results.

📖 **Documentation**

Detailed technical specifications, parameter configurations, and simulation verification reports are available in the `REPORT/` directory.

# PROJECT UART

* UART_TOP module block

<!-- Drag and drop your UART_TOP block diagram image into the line below to replace the link -->
<img width="976" height="623" alt="UART-UART_TOP drawio" src="https://github.com/user-attachments/assets/6b42033e-4607-4656-964e-cb000370f5c2" />

---

I/O Signal List by Module

## Table of Contents

* [UART_TOP](#uart_top)
* [UART_RX](#uart_rx)
* [UART_TX](#uart_tx)
* [BAUD_GEN](#baud_gen)
* [FIFO](#fifo)

---

### UART_TOP

File: `UART_TOP.sv`

| Signal | Direction | Type/Width | Description |
| :--- | :--- | :--- | :--- |
| uartrx_i | input | logic | RX data receiving pin |
| uarttx_o | output | logic | TX data transmitting pin |
| clk | input | logic | System clock |
| rst_n | input | logic | Active-low reset |

<br>

### UART_RX

File: `UART_RX.sv`

| Signal | Direction | Type/Width | Description |
| :--- | :--- | :--- | :--- |
| uartrx_i | input | logic | Serial input data |
| s_tick_i | input | logic | Baud sampling tick |
| rxdone_o | output | logic | Flag indicating 1 byte received |
| uartrx_o | output | logic [7:0] | Parallel output data |

<br>

### UART_TX

File: `UART_TX.sv`

| Signal | Direction | Type/Width | Description |
| :--- | :--- | :--- | :--- |
| uarttx_i | input | logic [7:0] | Parallel data to transmit |
| txstart_i | input | logic | Start transmission pulse |
| s_tick_i | input | logic | Baud sampling tick |
| txdone_o | output | logic | Flag indicating 1 byte transmitted |
| uarttx_o
