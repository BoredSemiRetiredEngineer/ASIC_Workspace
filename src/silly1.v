`default_nettype none
`timescale 1ns/1ns

/*****************************************************************************/
/**                                                                         **/
/** File: silly1.v                                                          **/
/**                                                                         **/
/** Project: For Tiny Tapout shake out                                      **/
/**                                                                         **/
/** Produced by: James Buchanan                                             **/
/**                                                                         **/
/** Date of creation: 2/6/2026                                              **/
/**                                                                         **/
/** Dependent Files:  silly2.v                                              **/
/**                                                                         **/
/*****************************************************************************/

// Description:
/* 	This project uses modules silly1 and silly2 to output signals that have been 'AND'ed to clock signals of different frequencies. 

	The silly2 module uses the systems' clk to generate divide by 2 clock signals that are sent to the silly1 module. 
	
	The silly1 module uses the input lines from outside the ASIC to decide
which signal is to be sent to the output lines by way of a logic AND operation.

	Signals generated in this fashion can be used for externally applications
that might be viewed as ...silly.

*/

// Control generated signals from silly2.

module silly1 ( 
    input clk,
    input rst_n,
    input [7:0] ui_in,
    output [7:0] uo_out 
    );

// Registers for signals

    reg [7:0] signal_gen_in;
    reg [7:0] signal_mask;
    reg [7:0] output_signal;
    wire reset = ! rst_n;

assign uo_out = output_signal;

   // Operations Module
    silly2 silly2(.clk(clk), .rst_n(rst_n), .signal_gen_out(signal_gen_in));

always @(posedge clk ) begin
    if (reset) begin
        signal_mask <= 0;
    end else begin
        signal_mask <= ui_in;
        output_signal <= signal_mask & signal_gen_in;

    end
end

endmodule
