`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2026 10:57:27 PM
// Design Name: 
// Module Name: switch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module switch(
    input wire clk,
    input wire rst,
    input wire [7:0] in0,
    input wire [7:0] in1,
    output reg [7:0] out0,
    output reg [7:0] out1,
    output reg [7:0] out2,
    output reg [7:0] out3
    );
    
    reg [23:0] packet0 ;
    reg [23:0] packet1;
    reg [1:0] rx_count0;
    reg [1:0] rx_count1;
    
    
    reg [23:0] fifo0 [0:3];
    reg [1:0] fifo0_wr_ptr;
    reg [1:0] fifo0_rd_ptr;
    reg [2:0] fifo0_count;
    
        
    reg [23:0] fifo1 [0:3];
    reg [1:0] fifo1_wr_ptr;
    reg [1:0] fifo1_rd_ptr;
    reg [2:0] fifo1_count;
        
    reg [1:0] dest0;
    reg [1:0] dest1;
      
    
        
    reg [1:0] tx_count0;
    reg [1:0] tx_count1;
    reg [1:0] tx_count2;
    reg [1:0] tx_count3;
    
    reg [23:0] out_packet0;
    reg [23:0] out_packet1;
    reg [23:0] out_packet2;
    reg [23:0] out_packet3;
    
    reg out0_busy;
    reg out1_busy;
    reg out2_busy;
    reg out3_busy;
    
    
    initial begin
        out_packet0 <= 24'b0;
        out_packet1 <= 24'b0;
        out_packet2 <= 24'b0;
        out_packet3 <= 24'b0;
            
        fifo0_wr_ptr = 0;
        fifo0_rd_ptr = 0;
        fifo0_count  = 0;
    
        fifo1_wr_ptr = 0;
        fifo1_rd_ptr = 0;
        fifo1_count  = 0;
    
        out0_busy = 0;
        out1_busy = 0;
        out2_busy = 0;
        out3_busy = 0;
    end
    

    always@(posedge clk) begin
        if (rst) begin
            rx_count0 <= 0;
            dest0 <= 0;
            packet0 <= 24'b0;
            fifo0_wr_ptr <= 0;
            fifo0_rd_ptr <= 0;
            fifo0_count  <= 0;
        end
        else begin
            case (rx_count0)
               2'b00: begin if (in0 != 8'h00) begin
                    packet0[23:16] <= in0;
                    rx_count0 <= 2'b01;
                    dest0 <= in0[7:6];
                   // packet0_valid <= 1'b0;
                    end
                end
                
                2'b01: begin
                    packet0[15:8] <= in0;
                    rx_count0 <= 2'b10;
                end
                
                2'b10: begin
                    packet0[7:0] <= in0;
                    
                    if (fifo0_count <4) begin
                        fifo0[fifo0_wr_ptr] <= {packet0[23:8], in0};
                        fifo0_wr_ptr <= fifo0_wr_ptr + 1;
                        fifo0_count <= fifo0_count +1;
                        end
                    rx_count0 <= 2'b00;
                    //packet0_valid <= 1'b1;
                end
                
            endcase
        end
    end
    

    
    
always@(posedge clk) begin
        if (rst) begin
            rx_count1 <= 0;
            dest1 <= 0;
            packet1 <= 24'b0;
            fifo1_wr_ptr <= 0;
            fifo1_rd_ptr <= 0;
            fifo1_count  <= 0;
            
        end
        else begin
            case (rx_count1)
               2'b00: begin if (in1 != 8'h00) begin
                    packet1[23:16] <= in1;
                    rx_count1 <= 2'b01;
                    dest1 <= in1[7:6];
                    //packet1_valid <= 1'b0;
                    end
                end
                
                2'b01: begin
                    packet1[15:8] <= in1;
                    rx_count1 <= 2'b10;
                end
                
                2'b10: begin
                    packet1[7:0] <= in1;
                    if (fifo1_count <4) begin
                        fifo1[fifo1_wr_ptr] <= {packet1[23:8], in1};
                        fifo1_wr_ptr <= fifo1_wr_ptr + 1;
                        fifo1_count <= fifo1_count +1;
                        end
                    rx_count1 <= 2'b00;
                end
                

            endcase
        end
    end
    

    

    //assign dest = packet0[23:22];
 wire fifo0_empty;
 wire fifo1_empty;
 
 assign fifo0_empty = (fifo0_count ==0);
 assign fifo1_empty = (fifo1_count ==0);

wire [1:0] fifo0_dest;
wire [1:0] fifo1_dest;
    
    
assign fifo0_dest = fifo0[fifo0_rd_ptr][23:22];
assign fifo1_dest = fifo1[fifo1_rd_ptr][23:22];
    
    task route_packet0;
    begin
        case(fifo0_dest)
            2'b00: if(!out0_busy)begin
                    out_packet0 <= fifo0[fifo0_rd_ptr];
                    out0_busy <= 1'b1;
                    fifo0_rd_ptr <= fifo0_rd_ptr + 1;
                    fifo0_count  <= fifo0_count - 1;
                end
                
                2'b01:if(!out1_busy)begin
                    out_packet1 <= fifo0[fifo0_rd_ptr];
                    out1_busy <= 1'b1;
                    fifo0_rd_ptr <= fifo0_rd_ptr + 1;
                    fifo0_count  <= fifo0_count - 1;
                end
                
                2'b10:if(!out2_busy)begin
                    out_packet2 <= fifo0[fifo0_rd_ptr];
                    out2_busy <= 1'b1;
                    fifo0_rd_ptr <= fifo0_rd_ptr + 1;
                    fifo0_count  <= fifo0_count - 1;
                end
                
                2'b11: if(!out3_busy)begin
                    out_packet3 <= fifo0[fifo0_rd_ptr];
                    out3_busy <= 1'b1;
                    fifo0_rd_ptr <= fifo0_rd_ptr + 1;
                    fifo0_count  <= fifo0_count - 1;
                end

    endcase
    end
    endtask
    
    
    task route_packet1;
    begin
    case(fifo1_dest)
            2'b00: if(!out0_busy)begin
                    out_packet0 <= fifo1[fifo1_rd_ptr];
                    out0_busy <= 1'b1;
                    fifo1_rd_ptr <= fifo1_rd_ptr + 1;
                    fifo1_count  <= fifo1_count - 1;
                end
                
                2'b01:if(!out1_busy)begin
                    out_packet1 <= fifo1[fifo1_rd_ptr];
                    out1_busy <= 1'b1;
                    fifo1_rd_ptr <= fifo1_rd_ptr + 1;
                    fifo1_count  <= fifo1_count - 1;
                end
                
                2'b10:if(!out2_busy)begin
                    out_packet2 <= fifo1[fifo1_rd_ptr];
                    out2_busy <= 1'b1;
                    fifo1_rd_ptr <= fifo1_rd_ptr + 1;
                    fifo1_count  <= fifo1_count - 1;
                end
                
                2'b11: if(!out3_busy)begin
                    out_packet3 <= fifo1[fifo1_rd_ptr];
                    out3_busy <= 1'b1;
                    fifo1_rd_ptr <= fifo1_rd_ptr + 1;
                    fifo1_count  <= fifo1_count - 1;
                end

    endcase
    end
    endtask
    
always @(posedge  clk) begin
    if (rst) begin
        out0_busy <= 0;
        out1_busy <= 0;
        out2_busy <= 0;
        out3_busy <= 0;
    end else begin
    if(!fifo0_empty && fifo1_empty)
        route_packet0;
    else if (!fifo1_empty && fifo0_empty)
        route_packet1;
    else if (!fifo0_empty && !fifo1_empty) begin
        if (fifo0_dest!= fifo1_dest) begin
             route_packet0;
             route_packet1;
             end
    else begin
            route_packet0;
    end
    end
    end
    end
    

    
    
    ////////////////////////////////
    
    always@(posedge clk) begin
    if (rst) begin
        tx_count0 <=0;
        out0<= 8'h00;
    end else
    if (out0_busy) begin
    case(tx_count0) 
        2'b00: begin
            out0 <= out_packet0[23:16]; 
            tx_count0 <= 2'b01;
        end
        
        2'b01: begin
            out0 <= out_packet0[15:8];
            tx_count0 <= 2'b10;
        end
        
        2'b10: begin
            out0 <= out_packet0[7:0];
            tx_count0 <= 2'b11;
        end
        
        2'b11: begin
            out0 <= 8'b00;
            tx_count0 <= 2'b00;
            out0_busy <= 1'b0;
        end
        
    endcase
    end
    end
    
    
    ///////////////////////////////////////
    always@(posedge clk) begin
        if (rst) begin
        tx_count1 <=0;
        out1<= 8'h00;
    end else
    if (out1_busy) begin
    case(tx_count1) 
        2'b00: begin
            out1 <= out_packet1[23:16];
            tx_count1 <= 2'b01;
        end
        
        2'b01: begin
            out1 <= out_packet1[15:8];
            tx_count1 <= 2'b10;
        end
        
        2'b10: begin
            out1 <= out_packet1[7:0];
            tx_count1 <= 2'b11;
            
        end
        
        2'b11: begin
            out1 <= 8'b00;
            tx_count1 <= 2'b00;
            out1_busy <= 1'b0;
        end
    endcase
    end
    end
    
    ///////////////////////////////////    
    always@(posedge clk) begin
    if (rst) begin
        tx_count2 <=0;
        out2<= 8'h00;
    end else
    if (out2_busy) begin
    case(tx_count2) 
        2'b00: begin
            out2 <= out_packet2[23:16];
            tx_count2 <= 2'b01;
        end
        
        2'b01: begin
            out2 <= out_packet2[15:8];
            tx_count2 <= 2'b10;
        end
        
        2'b10: begin
            out2 <= out_packet2[7:0];
            tx_count2 <= 2'b11;
            
        end
        
        2'b11: begin
            out2 <= 8'b00;
            tx_count2 <= 2'b00;
            out2_busy <= 1'b0;
        end
    endcase
    end
    end
    
    
    /////////////////////////////////
    always@(posedge clk) begin
    if (rst) begin
        tx_count3 <= 2'b00;
        out3<= 8'h00;
    end else
    if (out3_busy) begin
    case(tx_count3) 
        2'b00: begin
            out3 <= out_packet3[23:16];
            tx_count3 <= 2'b01;
        end
        
        2'b01: begin
            out3 <= out_packet3[15:8];
            tx_count3 <= 2'b10;
        end
        
        2'b10: begin
            out3 <= out_packet3[7:0];
            tx_count3 <= 2'b11;
            
        end
        
        2'b11: begin
            out3 <= 8'b00;
            tx_count3 <= 2'b00;
            out3_busy <= 1'b0;
        end
    endcase
    end
    end
    
endmodule
