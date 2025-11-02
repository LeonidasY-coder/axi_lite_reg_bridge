`timescale 1ns / 1ps
module tb_axi_lite_reg_bridge;
    reg clk = 0, rst = 0;
    always #5 clk = ~clk;

    // DUT signals
    reg [7:0] awaddr, araddr;
    reg awvalid, wvalid, arvalid, bready, rready;
    reg [31:0] wdata;
    wire [31:0] rdata;
    wire awready, wready, arready, rvalid, bvalid;
    wire [1:0] bresp, rresp;

    axi_lite_reg_bridge dut (
        .clk(clk), .rst(rst),
        .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
        .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready)
    );

    initial begin
        $dumpfile("tb_axi_lite_reg_bridge.vcd");
        $dumpvars(0, tb_axi_lite_reg_bridge);
        rst = 1; #20; rst = 0;
        
        // Write 0xDEADBEEF to reg 1
        awaddr = 8'h04; wdata = 32'hDEADBEEF;
        awvalid = 1; wvalid = 1; bready = 1;
        #20; awvalid = 0; wvalid = 0;
        #20;

        // Read back reg 1
        araddr = 8'h04; arvalid = 1; rready = 1;
        #20; arvalid = 0;
        if (rvalid && rdata == 32'hDEADBEEF)
            $display("✅ PASS: reg[1] = 0x%h", rdata);
        else
            $fatal(1, "❌ FAIL: read mismatch");
        #20;
        $finish;
    end
endmodule
