`default_nettype none
`timescale 1ns/1ns

/*****************************************************************************/
/**                                                                         **/
/** File: MatrixMath.v                                                      **/
/**                                                                         **/
/** Project: For Tiny Tapout shake out                                      **/
/**                                                                         **/
/** Produced by: James Buchanan                                             **/
/**                                                                         **/
/** Date of creation: 2//2026                                            **/
/**                                                                         **/
/** Dependent Files:  MatrixOps.v                                           **/
/**                                                                         **/
/*****************************************************************************/

/* Things to consider:                                                      **/
/*  1) Loading Matrix collisions                                            **/
/*                                           **/

module MatrixMath (
    
    
    input clk,
    input rst_n,
    input [7:0] ui_in,
    input [7:0] uio_in,
    output [7:0] uo_out 
    );
    //Register Operations and states


    localparam       RESET_REG           =   8'hAA;
    localparam       IDLE_REG            =   8'hBB;
    localparam       LOAD_REGA_00        =   8'h11;
    localparam       LOAD_REGA_01        =   8'h12;
    localparam       LOAD_REGA_02        =   8'h13;
    localparam       LOAD_REGA_10        =   8'h21;
    localparam       LOAD_REGA_11        =   8'h22;
    localparam       LOAD_REGA_12        =   8'h23;
    localparam       LOAD_REGA_20        =   8'h31;
    localparam       LOAD_REGA_21        =   8'h32;
    localparam       LOAD_REGA_22        =   8'h33;
    localparam       LOAD_REGB_00        =   8'h41;
    localparam       LOAD_REGB_01        =   8'h42;
    localparam       LOAD_REGB_02        =   8'h43;
    localparam       LOAD_REGB_10        =   8'h51;
    localparam       LOAD_REGB_11        =   8'h52;
    localparam       LOAD_REGB_12        =   8'h53;
    localparam       LOAD_REGB_20        =   8'h61;
    localparam       LOAD_REGB_21        =   8'h62;
    localparam       LOAD_REGB_22        =   8'h63;
    localparam       OPERATE_REG_ADD_C00 =   8'hD0;
    localparam       OPERATE_REG_ADD_C01 =   8'hD1;
    localparam       OPERATE_REG_ADD_C02 =   8'hD2;
    localparam       OPERATE_REG_ADD_C10 =   8'hD3;
    localparam       OPERATE_REG_ADD_C11 =   8'hD4;
    localparam       OPERATE_REG_ADD_C12 =   8'hD5;
    localparam       OPERATE_REG_ADD_C20 =   8'hD6;
    localparam       OPERATE_REG_ADD_C21 =   8'hD7;
    localparam       OPERATE_REG_ADD_C22 =   8'hD8;
    localparam       READ_RESULT_MATC00  =   8'hE0;
    localparam       READ_RESULT_MATC01  =   8'hE1;
    localparam       READ_RESULT_MATC02  =   8'hE2;
    localparam       READ_RESULT_MATC10  =   8'hE3;
    localparam       READ_RESULT_MATC11  =   8'hE4;
    localparam       READ_RESULT_MATC12  =   8'hE5;
    localparam       READ_RESULT_MATC20  =   8'hE6;
    localparam       READ_RESULT_MATC21  =   8'hE7;
    localparam       READ_RESULT_MATC22  =   8'hE8;
    localparam       READ_ERROR          =   8'hEE;
    localparam       ERROR               =   8'hFF;

    reg [7:0] OP_REGS;

    localparam       NO_ERROR            = 8'h00;
    localparam       CARRY_OVER_C00      = 8'h11;
    localparam       CARRY_OVER_C01      = 8'h12;
    localparam       CARRY_OVER_C02      = 8'h13;
    localparam       CARRY_OVER_C10      = 8'h21;
    localparam       CARRY_OVER_C11      = 8'h22;
    localparam       CARRY_OVER_C12      = 8'h23;
    localparam       CARRY_OVER_C20      = 8'h31;
    localparam       CARRY_OVER_C21      = 8'h32;
    localparam       CARRY_OVER_C22      = 8'h33;
    localparam       ERROR_MATC          = 8'hFF;
    
    reg [7:0] MATC_ERROR;


    // Registers for the internals
    reg [7:0] Ain;
    reg [7:0] Bin;
    reg [7:0] State_out; 
    reg [7:0] OP_ERROR;
    reg [7:0] state_op;


    reg [7:0] MatrixA[2:0][2:0];
    reg [7:0] MatrixB[2:0][2:0];
    reg [7:0] MatrixC[2:0][2:0];
    reg [7:0] Mat_Ouput;
    wire reset = ! rst_n;
    
    assign uo_out = State_out;
    

    // Operations Module
    MatrixOps MatrixOps(.clk(clk), .rst_n(rst_n), .State_in(State_out), .MatrixA(MatrixA[2:0][2:0]), .MatrixB(MatrixB[2:0][2:0]), .MatrixC(MatrixC[2:0][2:0]), .OutOfBounds(OP_ERROR));
    
always @(posedge clk ) begin



   
    if (reset) begin
            State_out <= OP_REGS;
            // I did it this way to avoid adding clock cycles to zero out one part
            // of the matrix. Boy, this looks like crap!
            MatrixA[0][0] <= 0;
            MatrixA[0][1] <= 0;
            MatrixA[0][2] <= 0;
            MatrixA[1][0] <= 0;
            MatrixA[1][1] <= 0;
            MatrixA[1][2] <= 0;
            MatrixA[2][0] <= 0;
            MatrixA[2][1] <= 0;
            MatrixA[2][2] <= 0;
           
            MatrixB[0][0] <= 0;
            MatrixB[0][1] <= 0;
            MatrixB[0][2] <= 0;
            MatrixB[1][0] <= 0;
            MatrixB[1][1] <= 0;
            MatrixB[1][2] <= 0;
            MatrixB[2][0] <= 0;
            MatrixB[2][1] <= 0;
            MatrixB[2][2] <= 0;
        
            MatrixC[0][0] <= 0;
            MatrixC[0][1] <= 0;
            MatrixC[0][2] <= 0;
            MatrixC[1][0] <= 0;
            MatrixC[1][1] <= 0;
            MatrixC[1][2] <= 0;
            MatrixC[2][0] <= 0;
            MatrixC[2][1] <= 0;
            MatrixC[2][2] <= 0;
                   
        // Direct state machine to start its cycle
      
        case(state_op)
            RESET_REG : begin
                OP_REGS <= RESET_REG;
            end
            IDLE_REG : begin
                OP_REGS <= IDLE_REG;
            end
            LOAD_REGA_00 : begin
                OP_REGS <= LOAD_REGA_00;
            end
            LOAD_REGA_01 : begin
                OP_REGS <= LOAD_REGA_01;
            end
            LOAD_REGA_02 : begin
                OP_REGS <= LOAD_REGA_02;
            end
            LOAD_REGA_10 : begin
                OP_REGS <= LOAD_REGA_10;
            end
            LOAD_REGA_11 : begin
                OP_REGS <= LOAD_REGA_11;
            end
            LOAD_REGA_12 : begin
                OP_REGS <= LOAD_REGA_12;
            end
            LOAD_REGA_20 : begin
                OP_REGS <= LOAD_REGA_20;
            end
            LOAD_REGA_21 : begin
                OP_REGS <= LOAD_REGA_21;
            end
            LOAD_REGA_22 : begin
                OP_REGS <= LOAD_REGA_22;
            end
            LOAD_REGB_00 : begin
                OP_REGS <= LOAD_REGB_00;
            end
            LOAD_REGB_01 : begin
                OP_REGS <= LOAD_REGB_01;
            end
            LOAD_REGB_02 : begin
                OP_REGS <= LOAD_REGB_02;
            end
            LOAD_REGB_10 : begin
                OP_REGS <= LOAD_REGB_10;
            end
            LOAD_REGB_11 : begin
                OP_REGS <= LOAD_REGB_11;
            end
            LOAD_REGB_12 : begin
                OP_REGS <= LOAD_REGB_12;
            end
            LOAD_REGB_20 : begin
                OP_REGS <= LOAD_REGB_20;
            end
            LOAD_REGB_21 : begin
                OP_REGS <= LOAD_REGB_21;
            end
            LOAD_REGB_22 : begin
                OP_REGS <= LOAD_REGB_22;
            end
            OPERATE_REG_ADD_C00 : begin
                OP_REGS <= OPERATE_REG_ADD_C00;
            end
            OPERATE_REG_ADD_C01 : begin
                OP_REGS <= OPERATE_REG_ADD_C01;
            end
            OPERATE_REG_ADD_C02 : begin
                OP_REGS <= OPERATE_REG_ADD_C02;
            end
            OPERATE_REG_ADD_C10 : begin
                OP_REGS <= OPERATE_REG_ADD_C10;
            end
            OPERATE_REG_ADD_C11 : begin
                OP_REGS <= OPERATE_REG_ADD_C11;
            end
            OPERATE_REG_ADD_C12 : begin
                OP_REGS <= OPERATE_REG_ADD_C12;
            end
            OPERATE_REG_ADD_C20 : begin
                OP_REGS <= OPERATE_REG_ADD_C20;
            end
            OPERATE_REG_ADD_C21 : begin
                OP_REGS <= OPERATE_REG_ADD_C21;
            end
            OPERATE_REG_ADD_C22 : begin
                OP_REGS <= OPERATE_REG_ADD_C22;
            end
            READ_RESULT_MATC00 : begin
                OP_REGS <= READ_RESULT_MATC00;
            end
            READ_RESULT_MATC01 : begin
                OP_REGS <= READ_RESULT_MATC01;
            end
            READ_RESULT_MATC02 : begin
                OP_REGS <= READ_RESULT_MATC02;
            end
            READ_RESULT_MATC10 : begin
                OP_REGS <= READ_RESULT_MATC10;
            end
            READ_RESULT_MATC11 : begin
                OP_REGS <= READ_RESULT_MATC11;
            end
            READ_RESULT_MATC12 : begin
                OP_REGS <= READ_RESULT_MATC12;
            end
            READ_RESULT_MATC20 : begin
                OP_REGS <= READ_RESULT_MATC20;
            end
            READ_RESULT_MATC21 : begin
                OP_REGS <= READ_RESULT_MATC21;
            end
            READ_RESULT_MATC22 : begin
                OP_REGS <= READ_RESULT_MATC22;
            end
            READ_ERROR : begin
                OP_REGS <= READ_ERROR;
            end
            ERROR : begin
                OP_REGS <= ERROR;
            end
            default: begin
                OP_REGS <= RESET_REG;
            end
        endcase
       
    end else begin
            if(OP_ERROR != 0) begin 
                state_op <= ERROR;
                OP_REGS <= RESET_REG; 
            end else begin
                state_op <= uio_in;
            end
            if((MATC_ERROR != 0) & state_op == ERROR) begin
                State_out <= MATC_ERROR; 
                OP_REGS <= RESET_REG;
            end
            if(uio_in == RESET_REG) begin
                OP_REGS <= RESET_REG;
                State_out <= OP_REGS;
                state_op <= OP_REGS;
                MATC_ERROR <= NO_ERROR;
            end
        
        case(state_op) 
            RESET_REG : begin // must last all clock cycles to zero out the matrix
                Ain <= 0;
                Bin <= 0;
                State_out <= OP_REGS;
                // I did it this way to avoid adding clock cycles to zero out one part
                // of the matrix. Boy, this looks like crap!
                MatrixA[0][0] <= 0;
                MatrixA[0][1] <= 0;
                MatrixA[0][2] <= 0;
                MatrixA[1][0] <= 0;
                MatrixA[1][1] <= 0;
                MatrixA[1][2] <= 0;
                MatrixA[2][0] <= 0;
                MatrixA[2][1] <= 0;
                MatrixA[2][2] <= 0;
           
                MatrixB[0][0] <= 0;
                MatrixB[0][1] <= 0;
                MatrixB[0][2] <= 0;
                MatrixB[1][0] <= 0;
                MatrixB[1][1] <= 0;
                MatrixB[1][2] <= 0;
                MatrixB[2][0] <= 0;
                MatrixB[2][1] <= 0;
                MatrixB[2][2] <= 0;
        
                MatrixC[0][0] <= 0;
                MatrixC[0][1] <= 0;
                MatrixC[0][2] <= 0;
                MatrixC[1][0] <= 0;
                MatrixC[1][1] <= 0;
                MatrixC[1][2] <= 0;
                MatrixC[2][0] <= 0;
                MatrixC[2][1] <= 0;
                MatrixC[2][2] <= 0;   
                
            // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            IDLE_REG : begin
                State_out <= OP_REGS;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGA_00 : begin

                State_out <= OP_REGS;
                Ain  <= ui_in;
                // I did it this way to avoid adding clock cycles to zero out one part
                // of the matrix. Boy, this looks like crap!
                MatrixA[0][0][0] <= Ain[0];
                MatrixA[0][0][1] <= Ain[1];
                MatrixA[0][0][2] <= Ain[2];
                MatrixA[0][0][3] <= Ain[3];
                MatrixA[0][0][4] <= Ain[4];
                MatrixA[0][0][5] <= Ain[5];
                MatrixA[0][0][6] <= Ain[6];
                MatrixA[0][0][7] <= Ain[7];

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGA_01 : begin
                State_out <= OP_REGS;
                Ain  <= ui_in;

                MatrixA[0][1][0] <= Ain[0];
                MatrixA[0][1][1] <= Ain[1];
                MatrixA[0][1][2] <= Ain[2];
                MatrixA[0][1][3] <= Ain[3];
                MatrixA[0][1][4] <= Ain[4];
                MatrixA[0][1][5] <= Ain[5];
                MatrixA[0][1][6] <= Ain[6];
                MatrixA[0][1][7] <= Ain[7];

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end    
            LOAD_REGA_02 : begin
                State_out <= OP_REGS;
                Ain  <= ui_in;

                MatrixA[0][2][0] <= Ain[0];
                MatrixA[0][2][1] <= Ain[1];
                MatrixA[0][2][2] <= Ain[2];
                MatrixA[0][2][3] <= Ain[3];
                MatrixA[0][2][4] <= Ain[4];
                MatrixA[0][2][5] <= Ain[5];
                MatrixA[0][2][6] <= Ain[6];
                MatrixA[0][2][7] <= Ain[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGA_10 : begin
                State_out <= OP_REGS;
                Ain  <= ui_in;

                MatrixA[1][0][0] <= Ain[0];
                MatrixA[1][0][1] <= Ain[1];
                MatrixA[1][0][2] <= Ain[2];
                MatrixA[1][0][3] <= Ain[3];
                MatrixA[1][0][4] <= Ain[4];
                MatrixA[1][0][5] <= Ain[5];
                MatrixA[1][0][6] <= Ain[6];
                MatrixA[1][0][7] <= Ain[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end    
            LOAD_REGA_11 : begin
                State_out <= OP_REGS;
                Ain  <= ui_in;

                MatrixA[1][1][0] <= Ain[0];
                MatrixA[1][1][1] <= Ain[1];
                MatrixA[1][1][2] <= Ain[2];
                MatrixA[1][1][3] <= Ain[3];
                MatrixA[1][1][4] <= Ain[4];
                MatrixA[1][1][5] <= Ain[5];
                MatrixA[1][1][6] <= Ain[6];
                MatrixA[1][1][7] <= Ain[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGA_12 : begin
                State_out <= OP_REGS;
                Ain  <= ui_in;
            
                MatrixA[1][2][0] <= Ain[0];
                MatrixA[1][2][1] <= Ain[1];
                MatrixA[1][2][2] <= Ain[2];
                MatrixA[1][2][3] <= Ain[3];
                MatrixA[1][2][4] <= Ain[4];
                MatrixA[1][2][5] <= Ain[5];
                MatrixA[1][2][6] <= Ain[6];
                MatrixA[1][2][7] <= Ain[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGA_20 : begin
                State_out <= OP_REGS;
                Ain  <= ui_in;

                MatrixA[2][0][0] <= Ain[0];
                MatrixA[2][0][1] <= Ain[1];
                MatrixA[2][0][2] <= Ain[2];
                MatrixA[2][0][3] <= Ain[3];
                MatrixA[2][0][4] <= Ain[4];
                MatrixA[2][0][5] <= Ain[5];
                MatrixA[2][0][6] <= Ain[6];
                MatrixA[2][0][7] <= Ain[7];

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGA_21 : begin
                State_out <= OP_REGS;
                Ain  <= ui_in;

                MatrixA[2][1][0] <= Ain[0];
                MatrixA[2][1][1] <= Ain[1];
                MatrixA[2][1][2] <= Ain[2];
                MatrixA[2][1][3] <= Ain[3];
                MatrixA[2][1][4] <= Ain[4];
                MatrixA[2][1][5] <= Ain[5];
                MatrixA[2][1][6] <= Ain[6];
                MatrixA[2][1][7] <= Ain[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGA_22 : begin
                State_out <= OP_REGS;
                Ain  <= ui_in;

                MatrixA[2][2][0] <= Ain[0];
                MatrixA[2][2][1] <= Ain[1];
                MatrixA[2][2][2] <= Ain[2];
                MatrixA[2][2][3] <= Ain[3];
                MatrixA[2][2][4] <= Ain[4];
                MatrixA[2][2][5] <= Ain[5];
                MatrixA[2][2][6] <= Ain[6];
                MatrixA[2][2][7] <= Ain[7];
                                                   
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_00 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                // I did it this way to avoid adding clock cycles to zero out one part
                // of the matrix. Boy, this looks like crap!
                MatrixB[0][0][0] <= Bin[0];
                MatrixB[0][0][1] <= Bin[1];
                MatrixB[0][0][2] <= Bin[2];
                MatrixB[0][0][3] <= Bin[3];
                MatrixB[0][0][4] <= Bin[4];
                MatrixB[0][0][5] <= Bin[5];
                MatrixB[0][0][6] <= Bin[6];
                MatrixB[0][0][7] <= Bin[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_01 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                MatrixB[0][1][0] <= Bin[0];
                MatrixB[0][1][1] <= Bin[1];
                MatrixB[0][1][2] <= Bin[2];
                MatrixB[0][1][3] <= Bin[3];
                MatrixB[0][1][4] <= Bin[4];
                MatrixB[0][1][5] <= Bin[5];
                MatrixB[0][1][6] <= Bin[6];
                MatrixB[0][1][7] <= Bin[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_02 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                MatrixB[0][2][0] <= Bin[0];
                MatrixB[0][2][1] <= Bin[1];
                MatrixB[0][2][2] <= Bin[2];
                MatrixB[0][2][3] <= Bin[3];
                MatrixB[0][2][4] <= Bin[4];
                MatrixB[0][2][5] <= Bin[5];
                MatrixB[0][2][6] <= Bin[6];
                MatrixB[0][2][7] <= Bin[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_10 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                MatrixB[1][0][0] <= Bin[0];
                MatrixB[1][0][1] <= Bin[1];
                MatrixB[1][0][2] <= Bin[2];
                MatrixB[1][0][3] <= Bin[3];
                MatrixB[1][0][4] <= Bin[4];
                MatrixB[1][0][5] <= Bin[5];
                MatrixB[1][0][6] <= Bin[6];
                MatrixB[1][0][7] <= Bin[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_11 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                MatrixB[1][1][0] <= Bin[0];
                MatrixB[1][1][1] <= Bin[1];
                MatrixB[1][1][2] <= Bin[2];
                MatrixB[1][1][3] <= Bin[3];
                MatrixB[1][1][4] <= Bin[4];
                MatrixB[1][1][5] <= Bin[5];
                MatrixB[1][1][6] <= Bin[6];
                MatrixB[1][1][7] <= Bin[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_12 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                MatrixB[1][2][0] <= Bin[0];
                MatrixB[1][2][1] <= Bin[1];
                MatrixB[1][2][2] <= Bin[2];
                MatrixB[1][2][3] <= Bin[3];
                MatrixB[1][2][4] <= Bin[4];
                MatrixB[1][2][5] <= Bin[5];
                MatrixB[1][2][6] <= Bin[6];
                MatrixB[1][2][7] <= Bin[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_20 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                MatrixB[2][0][0] <= Bin[0];
                MatrixB[2][0][1] <= Bin[1];
                MatrixB[2][0][2] <= Bin[2];
                MatrixB[2][0][3] <= Bin[3];
                MatrixB[2][0][4] <= Bin[4];
                MatrixB[2][0][5] <= Bin[5];
                MatrixB[2][0][6] <= Bin[6];
                MatrixB[2][0][7] <= Bin[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_21 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                MatrixB[2][1][0] <= Bin[0];
                MatrixB[2][1][1] <= Bin[1];
                MatrixB[2][1][2] <= Bin[2];
                MatrixB[2][1][3] <= Bin[3];
                MatrixB[2][1][4] <= Bin[4];
                MatrixB[2][1][5] <= Bin[5];
                MatrixB[2][1][6] <= Bin[6];
                MatrixB[2][1][7] <= Bin[7];
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            LOAD_REGB_22 : begin
                State_out <= OP_REGS;
                Bin  <= ui_in;
                MatrixB[2][2][0] <= Bin[0];
                MatrixB[2][2][1] <= Bin[1];
                MatrixB[2][2][2] <= Bin[2];
                MatrixB[2][2][3] <= Bin[3];
                MatrixB[2][2][4] <= Bin[4];
                MatrixB[2][2][5] <= Bin[5];
                MatrixB[2][2][6] <= Bin[6];
                MatrixB[2][2][7] <= Bin[7];
               
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C00 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;

                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C01 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;

                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C02 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;

                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C10 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;

                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C11 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;

                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C12 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;

                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C20 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;

                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C21 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;

                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            OPERATE_REG_ADD_C22 : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;
                // Description here

                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC00 : begin
                Mat_Ouput <= MatrixC[0][0];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC01 : begin
                Mat_Ouput <= MatrixC[0][1];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC02 : begin
                Mat_Ouput <= MatrixC[0][2];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC10 : begin
                Mat_Ouput <= MatrixC[1][0];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC11 : begin
                Mat_Ouput <= MatrixC[1][1];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC12 : begin
                Mat_Ouput <= MatrixC[1][2];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC20 : begin
                Mat_Ouput <= MatrixC[2][0];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC21 : begin
                Mat_Ouput <= MatrixC[2][1];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_RESULT_MATC22 : begin
                Mat_Ouput <= MatrixC[2][2];
                State_out <= Mat_Ouput;
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            READ_ERROR : begin
                OP_REGS <= READ_ERROR;
                State_out <= MATC_ERROR; 
                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            ERROR : begin
                
                State_out <= OP_REGS;
                OP_REGS <= RESET_REG;
                state_op <= uio_in; 
                //Error Bank

                case(OP_ERROR)
                    NO_ERROR : begin
                        MATC_ERROR <= NO_ERROR;
                    end
                    CARRY_OVER_C00 : begin
                        MATC_ERROR <= CARRY_OVER_C00;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    CARRY_OVER_C01 : begin
                        MATC_ERROR <= CARRY_OVER_C01;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    CARRY_OVER_C02 : begin
                        MATC_ERROR <= CARRY_OVER_C02;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    CARRY_OVER_C10 : begin
                        MATC_ERROR <= CARRY_OVER_C10;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    CARRY_OVER_C11 : begin
                        MATC_ERROR <= CARRY_OVER_C11;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    CARRY_OVER_C12 : begin 
                        MATC_ERROR <= CARRY_OVER_C12;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    CARRY_OVER_C20 : begin
                        MATC_ERROR <= CARRY_OVER_C20;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    CARRY_OVER_C21 : begin
                        MATC_ERROR <= CARRY_OVER_C21;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    CARRY_OVER_C22 : begin
                        MATC_ERROR <= CARRY_OVER_C22;
                        state_op <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                    default : begin
                        MATC_ERROR <= ERROR_MATC;
                        OP_REGS <= RESET_REG;
                        State_out<= OP_REGS;
                    end
                endcase


                // Direct state machine
                case(state_op)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA_00 : begin
                        OP_REGS <= LOAD_REGA_00;
                    end
                    LOAD_REGA_01 : begin
                        OP_REGS <= LOAD_REGA_01;
                    end
                    LOAD_REGA_02 : begin
                        OP_REGS <= LOAD_REGA_02;
                    end
                    LOAD_REGA_10 : begin
                        OP_REGS <= LOAD_REGA_10;
                    end
                    LOAD_REGA_11 : begin
                        OP_REGS <= LOAD_REGA_11;
                    end
                    LOAD_REGA_12 : begin
                        OP_REGS <= LOAD_REGA_12;
                    end
                    LOAD_REGA_20 : begin
                        OP_REGS <= LOAD_REGA_20;
                    end
                    LOAD_REGA_21 : begin
                        OP_REGS <= LOAD_REGA_21;
                    end
                    LOAD_REGA_22 : begin
                        OP_REGS <= LOAD_REGA_22;
                    end
                    LOAD_REGB_00 : begin
                        OP_REGS <= LOAD_REGB_00;
                    end
                    LOAD_REGB_01 : begin
                        OP_REGS <= LOAD_REGB_01;
                    end
                    LOAD_REGB_02 : begin
                        OP_REGS <= LOAD_REGB_02;
                    end
                    LOAD_REGB_10 : begin
                        OP_REGS <= LOAD_REGB_10;
                    end
                    LOAD_REGB_11 : begin
                        OP_REGS <= LOAD_REGB_11;
                    end
                    LOAD_REGB_12 : begin
                        OP_REGS <= LOAD_REGB_12;
                    end
                    LOAD_REGB_20 : begin
                        OP_REGS <= LOAD_REGB_20;
                    end
                    LOAD_REGB_21 : begin
                        OP_REGS <= LOAD_REGB_21;
                    end
                    LOAD_REGB_22 : begin
                        OP_REGS <= LOAD_REGB_22;
                    end
                    OPERATE_REG_ADD_C00 : begin
                        OP_REGS <= OPERATE_REG_ADD_C00;
                    end
                    OPERATE_REG_ADD_C01 : begin
                        OP_REGS <= OPERATE_REG_ADD_C01;
                    end
                    OPERATE_REG_ADD_C02 : begin
                        OP_REGS <= OPERATE_REG_ADD_C02;
                    end
                    OPERATE_REG_ADD_C10 : begin
                        OP_REGS <= OPERATE_REG_ADD_C10;
                    end
                    OPERATE_REG_ADD_C11 : begin
                        OP_REGS <= OPERATE_REG_ADD_C11;
                    end
                    OPERATE_REG_ADD_C12 : begin
                        OP_REGS <= OPERATE_REG_ADD_C12;
                    end
                    OPERATE_REG_ADD_C20 : begin
                        OP_REGS <= OPERATE_REG_ADD_C20;
                    end
                    OPERATE_REG_ADD_C21 : begin
                        OP_REGS <= OPERATE_REG_ADD_C21;
                    end
                    OPERATE_REG_ADD_C22 : begin
                        OP_REGS <= OPERATE_REG_ADD_C22;
                    end
                    READ_RESULT_MATC00 : begin
                        OP_REGS <= READ_RESULT_MATC00;
                    end
                    READ_RESULT_MATC01 : begin
                        OP_REGS <= READ_RESULT_MATC01;
                    end
                    READ_RESULT_MATC02 : begin
                        OP_REGS <= READ_RESULT_MATC02;
                    end
                    READ_RESULT_MATC10 : begin
                        OP_REGS <= READ_RESULT_MATC10;
                    end
                    READ_RESULT_MATC11 : begin
                        OP_REGS <= READ_RESULT_MATC11;
                    end
                    READ_RESULT_MATC12 : begin
                        OP_REGS <= READ_RESULT_MATC12;
                    end
                    READ_RESULT_MATC20 : begin
                        OP_REGS <= READ_RESULT_MATC20;
                    end
                    READ_RESULT_MATC21 : begin
                        OP_REGS <= READ_RESULT_MATC21;
                    end
                    READ_RESULT_MATC22 : begin
                        OP_REGS <= READ_RESULT_MATC22;
                    end
                    READ_ERROR : begin
                        OP_REGS <= READ_ERROR;
                    end
                    ERROR :begin
                        OP_REGS <= ERROR;
                    end
                    default: begin
                        OP_REGS <= RESET_REG;
                    end
                endcase
            end
            default:
                OP_REGS <= IDLE_REG;
        endcase
    end
end

endmodule
