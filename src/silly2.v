`default_nettype none
`timescale 1ns/1ns


/*****************************************************************************/
/**                                                                         **/
/** File: silly2.v                                                          **/
/**                                                                         **/
/** Project: For Tiny Tapout shake out                                      **/
/**                                                                         **/
/** Produced by: James Buchanan                                             **/
/**                                                                         **/
/** Date of creation: 2/6/2026                                              **/
/**                                                                         **/
/** Dependent Files:  silly1.v                                              **/
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


// Generate clock signals

module silly2 (
    
    
    input clk,
    input rst_n,
    output [7:0] signal_gen_out
    );

// Registers for signals

    reg clk_div2;
    reg clk_div4;
    reg clk_div8;
    reg clk_div16;
    reg clk_div32;
    reg clk_div64;
    reg clk_div128;
    reg clk_div256;

    wire reset = ! rst_n;

    assign signal_gen_out[0] = clk_div2;
    assign signal_gen_out[1] = clk_div4;
    assign signal_gen_out[2] = clk_div8;
    assign signal_gen_out[3] = clk_div16;
    assign signal_gen_out[4] = clk_div32;
    assign signal_gen_out[5] = clk_div64;
    assign signal_gen_out[6] = clk_div128;
    assign signal_gen_out[7] = clk_div256;


always @(posedge clk ) begin
    if (reset) begin
        clk_div2 <= 0;
    end else begin
        clk_div2 <= ~clk_div2;
    end
end
always @(posedge clk_div2 ) begin
    if (reset) begin
        clk_div4 <= 0;
    end else begin
        clk_div4 <= ~clk_div4;
    end
end
always @(posedge clk_div4 ) begin
    if (reset) begin
        clk_div8 <= 0;
    end else begin
        clk_div8 <= ~clk_div8;
    end
end
always @(posedge clk_div8 ) begin
    if (reset) begin
        clk_div16 <= 0;
    end else begin
        clk_div16 <= ~clk_div16;
    end
end
always @(posedge clk_div16 ) begin
    if (reset) begin
        clk_div32 <= 0;
    end else begin
        clk_div32 <= ~clk_div32;
    end
end
always @(posedge clk_div32 ) begin
    if (reset) begin
        clk_div64 <= 0;
    end else begin
        clk_div64 <= ~clk_div64;
    end
end
always @(posedge clk_div64 ) begin
    if (reset) begin
        clk_div128 <= 0;
    end else begin
        clk_div128 <= ~clk_div128;
    end
end
always @(posedge clk_div128 ) begin
    if (reset) begin
        clk_div256 <= 0;
    end else begin
        clk_div256 <= ~clk_div256;
    end
end

endmodule
