`timescale 1ns / 1ps
// Simple AXI-Lite to Register File Bridge
module axi_lite_reg_bridge #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter REG_COUNT  = 8
)(
    input  wire                     clk,
    input  wire                     rst,

    // AXI-Lite Write Address Channel
    input  wire [ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire                     s_axi_awvalid,
    output reg                      s_axi_awready,

    // AXI-Lite Write Data Channel
    input  wire [DATA_WIDTH-1:0]    s_axi_wdata,
    input  wire                     s_axi_wvalid,
    output reg                      s_axi_wready,

    // AXI-Lite Write Response Channel
    output reg [1:0]                s_axi_bresp,
    output reg                      s_axi_bvalid,
    input  wire                     s_axi_bready,

    // AXI-Lite Read Address Channel
    input  wire [ADDR_WIDTH-1:0]    s_axi_araddr,
    input  wire                     s_axi_arvalid,
    output reg                      s_axi_arready,

    // AXI-Lite Read Data Channel
    output reg [DATA_WIDTH-1:0]     s_axi_rdata,
    output reg [1:0]                s_axi_rresp,
    output reg                      s_axi_rvalid,
    input  wire                     s_axi_rready
);

    // Simple register file
    reg [DATA_WIDTH-1:0] regfile [0:REG_COUNT-1];

    integer i;
    initial begin
        for (i = 0; i < REG_COUNT; i = i + 1)
            regfile[i] = 0;
    end

    // Write logic
    always @(posedge clk) begin
        if (rst) begin
            s_axi_awready <= 0;
            s_axi_wready  <= 0;
            s_axi_bvalid  <= 0;
        end else begin
            s_axi_awready <= s_axi_awvalid;
            s_axi_wready  <= s_axi_wvalid;

            if (s_axi_awvalid && s_axi_wvalid) begin
                regfile[s_axi_awaddr[ADDR_WIDTH-1:2]] <= s_axi_wdata;
                s_axi_bresp  <= 2'b00; // OKAY
                s_axi_bvalid <= 1;
            end else if (s_axi_bready) begin
                s_axi_bvalid <= 0;
            end
        end
    end

    // Read logic
    always @(posedge clk) begin
        if (rst) begin
            s_axi_arready <= 0;
            s_axi_rvalid  <= 0;
        end else begin
            s_axi_arready <= s_axi_arvalid;
            if (s_axi_arvalid) begin
                s_axi_rdata  <= regfile[s_axi_araddr[ADDR_WIDTH-1:2]];
                s_axi_rresp  <= 2'b00;
                s_axi_rvalid <= 1;
            end else if (s_axi_rready) begin
                s_axi_rvalid <= 0;
            end
        end
    end
endmodule
