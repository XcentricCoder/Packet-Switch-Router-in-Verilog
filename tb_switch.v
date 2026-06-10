`timescale 1ns/1ps

module tb_switch;

reg clk;
reg rst;

reg [7:0] in0;
reg [7:0] in1;

wire [7:0] out0;
wire [7:0] out1;
wire [7:0] out2;
wire [7:0] out3;

switch dut(
    .clk(clk),
    .rst(rst),
    .in0(in0),
    .in1(in1),
    .out0(out0),
    .out1(out1),
    .out2(out2),
    .out3(out3)
);

//////////////////////////////////////////////////
// Clock
//////////////////////////////////////////////////

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//////////////////////////////////////////////////
// Task : Send packet on input0
//////////////////////////////////////////////////

task send_packet_in0;
input [7:0] header;
input [7:0] p1;
input [7:0] p2;
begin
    @(negedge clk);
    in0 = header;

    @(negedge clk);
    in0 = p1;

    @(negedge clk);
    in0 = p2;

    @(negedge clk);
    in0 = 8'h00;     // gap
end
endtask

//////////////////////////////////////////////////
// Task : Send packet on input1
//////////////////////////////////////////////////

task send_packet_in1;
input [7:0] header;
input [7:0] p1;
input [7:0] p2;
begin
    @(negedge clk);
    in1 = header;

    @(negedge clk);
    in1 = p1;

    @(negedge clk);
    in1 = p2;

    @(negedge clk);
    in1 = 8'h00;     // gap
end
endtask

initial begin

    rst = 1;
    in0 = 8'h00;
    in1 = 8'h00;

    repeat(5) @(posedge clk);
    rst = 0;

////////////////////////////////////////////////////////////
// TEST1
// Single packet on IN0
////////////////////////////////////////////////////////////

$display("\n======================");
$display("TEST1 : IN0 -> OUT0");
$display("======================");

send_packet_in0(8'b00_101010,8'h11,8'h22);

repeat(15) @(posedge clk);

////////////////////////////////////////////////////////////
// TEST2
// Single packet on IN1
////////////////////////////////////////////////////////////

$display("\n======================");
$display("TEST2 : IN1 -> OUT3");
$display("======================");

send_packet_in1(8'b11_111111,8'h33,8'h44);

repeat(15) @(posedge clk);

////////////////////////////////////////////////////////////
// TEST3
// Destination coverage
////////////////////////////////////////////////////////////

$display("\n======================");
$display("TEST3 : DESTINATION COVERAGE");
$display("======================");

send_packet_in0(8'b00_000001,8'h01,8'h02);
repeat(10) @(posedge clk);

send_packet_in0(8'b01_000001,8'h03,8'h04);
repeat(10) @(posedge clk);

send_packet_in0(8'b10_000001,8'h05,8'h06);
repeat(10) @(posedge clk);

send_packet_in0(8'b11_000001,8'h07,8'h08);
repeat(15) @(posedge clk);

////////////////////////////////////////////////////////////
// TEST4
// Back-to-back packets
////////////////////////////////////////////////////////////

$display("\n======================");
$display("TEST4 : BACK TO BACK");
$display("======================");

send_packet_in0(8'b00_111111,8'hA1,8'hA2);

send_packet_in0(8'b01_111111,8'hB1,8'hB2);

repeat(20) @(posedge clk);

////////////////////////////////////////////////////////////
// TEST5
// Simultaneous inputs
// different outputs
////////////////////////////////////////////////////////////

$display("\n======================");
$display("TEST5 : SIMULTANEOUS DIFFERENT DEST");
$display("======================");

fork

    send_packet_in0(8'b00_000001,8'hC1,8'hC2);

    send_packet_in1(8'b10_000001,8'hD1,8'hD2
    );

join

repeat(20) @(posedge clk);

////////////////////////////////////////////////////////////
// TEST6
// Arbitration
////////////////////////////////////////////////////////////

$display("\n======================");
$display("TEST6 : OUTPUT CONFLICT");
$display("======================");

fork

    send_packet_in0(
        8'b10_000001,
        8'hE1,
        8'hE2
    );

    send_packet_in1(
        8'b10_000010,
        8'hF1,
        8'hF2
    );

join

repeat(30) @(posedge clk);

////////////////////////////////////////////////////////////
// TEST7
// Random packets
////////////////////////////////////////////////////////////

$display("\n======================");
$display("TEST7 : RANDOM TRAFFIC");
$display("======================");

repeat(20)
begin

    if($random % 2)
    begin
        send_packet_in0(
            {$random} & 8'hFF,
            {$random} & 8'hFF,
            {$random} & 8'hFF
        );
    end
    else
    begin
        send_packet_in1(
            {$random} & 8'hFF,
            {$random} & 8'hFF,
            {$random} & 8'hFF
        );
    end

    repeat($random % 5) @(posedge clk);

end

repeat(40) @(posedge clk);

////////////////////////////////////////////////////////////
// TEST8
// Reset during traffic
////////////////////////////////////////////////////////////

$display("\n======================");
$display("TEST8 : RESET DURING TRAFFIC");
$display("======================");

fork

    send_packet_in0(
        8'b01_111111,
        8'hAA,
        8'hBB
    );

    //repeat(6) @(posedge clk);
    begin
        repeat(6) @(posedge clk);
        rst = 1;

        repeat(3) @(posedge clk);

        rst = 0;
    end

join

repeat(20) @(posedge clk);

$display("\nALL TESTS COMPLETED\n");

$finish;

end


//////////////////////////////////////////////////
// INPUT MONITOR
//////////////////////////////////////////////////

always @(posedge clk)
begin
    $strobe(
    "T=%0t | in0=%h in1=%h",
    $time,
    in0,
    in1
    );
end


//////////////////////////////////////////////////
// FIFO STATUS
//////////////////////////////////////////////////

always @(posedge clk)
begin
    $strobe(
    "FIFO0 cnt=%0d wr=%0d rd=%0d | FIFO1 cnt=%0d wr=%0d rd=%0d",
    dut.fifo0_count,
    dut.fifo0_wr_ptr,
    dut.fifo0_rd_ptr,
    dut.fifo1_count,
    dut.fifo1_wr_ptr,
    dut.fifo1_rd_ptr
    );
end

//////////////////////////////////////////////////
// FIFO PUSH
//////////////////////////////////////////////////

always @(posedge clk)
begin
    if(dut.rx_count0 == 2'b10)
        $display(
        "FIFO0_PUSH @%0t packet=%h",
        $time,
        {dut.packet0[23:8], in0}
        );

    if(dut.rx_count1 == 2'b10)
        $display(
        "FIFO1_PUSH @%0t packet=%h",
        $time,
        {dut.packet1[23:8], in1}
        );
end


//////////////////////////////////////////////////
// OUTPUT ACTIVITY
//////////////////////////////////////////////////

always @(posedge clk)
begin
        $strobe(
        "OUT0=%h OUT1=%h OUT2=%h OUT3=%h | busy=%b%b%b%b",
        out0,
        out1,
        out2,
        out3,
        dut.out3_busy,
        dut.out2_busy,
        dut.out1_busy,
        dut.out0_busy
        );

end






endmodule