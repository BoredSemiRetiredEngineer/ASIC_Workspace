`default_nettype none
`timescale 1ns/1ns

/*****************************************************************************/
/**                                                                         **/
/** File: MatrixOps.v                                                       **/
/**                                                                         **/
/** Project: For Tiny Tapout shake out                                      **/
/**                                                                         **/
/** Produced by: James Buchanan                                             **/
/**                                                                         **/
/** Date of creation: 2//2026                                            **/
/**                                                                         **/
/** Dependent Files: MatrixMath.v                                           **/
/**                                                                         **/
/*****************************************************************************/

/* Things to consider:                                                      **/
/*  1) Loading Matrix collisions                                            **/

module MatrixOps (
    
    
    input clk,
    input rst_n,
    input [7:0] State_in,
    input [7:0] MatrixA[2:0][2:0],
    input [7:0] MatrixB[2:0][2:0],
    output [7:0] MatrixC[2:0][2:0],
    output [7:0] OutOfBounds
    );



    localparam    RESET_REG             =   8'hAA;
    localparam    IDLE_REG              =   8'hBB;
    localparam    OPERATE_REG_ADD_C00   =   8'hD0;
    localparam    OPERATE_REG_ADD_C01   =   8'hD1;
    localparam    OPERATE_REG_ADD_C02   =   8'hD2;
    localparam    OPERATE_REG_ADD_C10   =   8'hD3;
    localparam    OPERATE_REG_ADD_C11   =   8'hD4;
    localparam    OPERATE_REG_ADD_C12   =   8'hD5;
    localparam    OPERATE_REG_ADD_C20   =   8'hD6;
    localparam    OPERATE_REG_ADD_C21   =   8'hD7;
    localparam    OPERATE_REG_ADD_C22   =   8'hD8;
    localparam    READ_RESULT_MATC00    =   8'hE0;
    localparam    READ_RESULT_MATC01    =   8'hE1;
    localparam    READ_RESULT_MATC02    =   8'hE2;
    localparam    READ_RESULT_MATC10    =   8'hE3;
    localparam    READ_RESULT_MATC11    =   8'hE4;
    localparam    READ_RESULT_MATC12    =   8'hE5;
    localparam    READ_RESULT_MATC20    =   8'hE6;
    localparam    READ_RESULT_MATC21    =   8'hE7;
    localparam    READ_RESULT_MATC22    =   8'hE8;
    localparam    READ_ERROR            =   8'hEE;
    localparam    ERROR                 =   8'hFF;

    reg [7:0] OP_REGS;

    localparam    NO_ERROR              = 8'h00;
    localparam    CARRY_OVER_C00        = 8'h11;
    localparam    CARRY_OVER_C01        = 8'h12;
    localparam    CARRY_OVER_C02        = 8'h13;
    localparam    CARRY_OVER_C10        = 8'h21;
    localparam    CARRY_OVER_C11        = 8'h22;
    localparam    CARRY_OVER_C12        = 8'h23;
    localparam    CARRY_OVER_C20        = 8'h31;
    localparam    CARRY_OVER_C21        = 8'h32;
    localparam    CARRY_OVER_C22        = 8'h33;

    reg [7:0] ERROR_OP_REG;


// Registers for the internals
    
    reg [7:0] MatA[2:0][2:0] = MatrixA;
    reg [7:0] MatB[2:0][2:0] = MatrixB;
    reg [7:0] MatC[2:0][2:0] = MatrixC;
    reg [8:0] Resulting_Mat;
    reg Overfull_Error;
    wire reset = ! rst_n;
    
    
    assign  MatrixC = MatC;
    assign  OutOfBounds = ERROR_OP_REG;
    assign  MatA = MatrixA;
    assign  MatB = MatrixB;




    // Full Add function
    function [8:0] full_matrix_add;
            input [7:0] F1;
            input [7:0] F2;
            input E1;

        begin
            
            full_matrix_add[0] = F1[0] ^ F2[0]; 
            E1 = (F1[0] & F2[0]) | (F1[0] & E1) | (F2[0] & E1);
            full_matrix_add[1] = F1[1] ^ F2[1] ^ E1; 
            E1 = (F1[1] & F2[1]) | (F1[1] & E1) | (F2[1] & E1);
            full_matrix_add[2] = F1[2] ^ F2[2] ^ E1; 
            E1 = (F1[2] & F2[2]) | (F1[2] & E1) | (F2[2] & E1);
            full_matrix_add[3] = F1[3] ^ F2[3] ^ E1; 
            E1 = (F1[3] & F2[3]) | (F1[3] & E1) | (F2[3] & E1);
            full_matrix_add[4] = F1[4] ^ F2[4] ^ E1; 
            E1 = (F1[4] & F2[4]) | (F1[4] & E1) | (F2[4] & E1);
            full_matrix_add[5] = F1[5] ^ F2[5] ^ E1; 
            E1 = (F1[5] & F2[5]) | (F1[5] & E1) | (F2[5] & E1);
            full_matrix_add[6] = F1[6] ^ F2[6] ^ E1; 
            E1 = (F1[6] & F2[6]) | (F1[6] & E1) | (F2[6] & E1);
            full_matrix_add[7] = F1[7] ^ F2[7] ^ E1; 
            // Overflow error determination

            full_matrix_add[8] = (F1[7] & F2[7]) | (F1[7] & E1) | (F2[7] & E1);

        end
    endfunction

 
always @(posedge clk) begin

    if(reset) begin
        OP_REGS <= RESET_REG;
        MatC[0][0]<= 8'h00;
        MatC[0][1]<= 8'h00;
        MatC[0][2]<= 8'h00;
        MatC[1][0]<= 8'h00;
        MatC[1][1]<= 8'h00;
        MatC[1][2]<= 8'h00;
        MatC[2][0]<= 8'h00;
        MatC[2][1]<= 8'h00;
        MatC[2][2]<= 8'h00;
        ERROR_OP_REG <= NO_ERROR;

    end else begin
        case(State_in)
            RESET_REG : begin
                OP_REGS <= RESET_REG;
                MatC[0][0]<= 8'h00;
                MatC[0][1]<= 8'h00;
                MatC[0][2]<= 8'h00;
                MatC[1][0]<= 8'h00;
                MatC[1][1]<= 8'h00;
                MatC[1][2]<= 8'h00;
                MatC[2][0]<= 8'h00;
                MatC[2][1]<= 8'h00;
                MatC[2][2]<= 8'h00;
                ERROR_OP_REG <= NO_ERROR;
                    // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                            ERROR_OP_REG <= NO_ERROR;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            IDLE_REG : begin
                OP_REGS <= IDLE_REG;
                // Direct state machine
                case(State_in)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
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

                Resulting_Mat[8:0] = full_matrix_add( MatA[0][0][7:0], MatB[0][0][7:0], 0);
                    MatC[0][0][7:0] = Resulting_Mat[7:0];
                    Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                        ERROR_OP_REG <= CARRY_OVER_C00;
                        OP_REGS <= RESET_REG;
                    end

                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            OPERATE_REG_ADD_C01 : begin

                Resulting_Mat = full_matrix_add( MatA[0][1], MatB[0][1], 0);
                MatC[0][1][7:0] = Resulting_Mat[7:0];
                Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                    ERROR_OP_REG <= CARRY_OVER_C01;
                    OP_REGS <= RESET_REG;
                    end
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            OPERATE_REG_ADD_C02 : begin

                Resulting_Mat = full_matrix_add( MatA[0][2], MatB[0][2], 0);
                MatC[0][2][7:0] = Resulting_Mat[7:0];
                Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                    ERROR_OP_REG <= CARRY_OVER_C02;
                    OP_REGS <= RESET_REG;
                    end

                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            OPERATE_REG_ADD_C10 : begin

                Resulting_Mat = full_matrix_add( MatA[1][0], MatB[1][0], 0);
                MatC[1][0][7:0] = Resulting_Mat[7:0];
                Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                    ERROR_OP_REG <= CARRY_OVER_C10;
                    OP_REGS <= RESET_REG;
                    end
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            OPERATE_REG_ADD_C11 : begin

                Resulting_Mat = full_matrix_add( MatA[1][1], MatB[1][1], 0);
                MatC[1][1][7:0] = Resulting_Mat[7:0];
                Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                    ERROR_OP_REG <= CARRY_OVER_C11;
                    OP_REGS <= RESET_REG;
                    end
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            OPERATE_REG_ADD_C12 : begin

                Resulting_Mat = full_matrix_add( MatA[1][2], MatB[1][2], 0);
                MatC[1][2][7:0] = Resulting_Mat[7:0];
                Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                    ERROR_OP_REG <= CARRY_OVER_C12;
                    OP_REGS <= RESET_REG;
                    end
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            OPERATE_REG_ADD_C20 : begin

                Resulting_Mat = full_matrix_add( MatA[2][0], MatB[2][0], 0);
                MatC[2][0][7:0] = Resulting_Mat[7:0];
                Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                    ERROR_OP_REG <= CARRY_OVER_C20;
                    OP_REGS <= RESET_REG;
                    end

                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            OPERATE_REG_ADD_C21 : begin

                Resulting_Mat = full_matrix_add( MatA[2][1], MatB[2][1], 0);
                MatC[2][1][7:0] = Resulting_Mat[7:0];
                Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                    ERROR_OP_REG <= CARRY_OVER_C21;
                    OP_REGS <= RESET_REG;
                    end
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            OPERATE_REG_ADD_C22 : begin

                Resulting_Mat = full_matrix_add( MatA[2][2], MatB[2][2], 0);
                MatC[2][2][7:0] = Resulting_Mat[7:0];
                Overfull_Error = Resulting_Mat[8];

                    if (Overfull_Error) begin
                    ERROR_OP_REG <= CARRY_OVER_C22;
                    OP_REGS <= RESET_REG;
                    end

                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC00  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC01  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC02  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC10  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC11  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC12  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC20  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC21  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_RESULT_MATC22  : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            READ_ERROR : begin
                OP_REGS <= READ_ERROR;
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            ERROR               : begin
                // Direct State Machine
                    case(State_in)
                        RESET_REG : begin
                            OP_REGS <= RESET_REG;
                        end
                        IDLE_REG : begin
                            OP_REGS <= IDLE_REG;
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
                        READ_RESULT_MATC00  : begin
                            OP_REGS <= READ_RESULT_MATC00;
                        end
                        READ_RESULT_MATC01  : begin
                            OP_REGS <= READ_RESULT_MATC01;
                        end
                        READ_RESULT_MATC02  : begin
                            OP_REGS <= READ_RESULT_MATC02;
                        end
                        READ_RESULT_MATC10  : begin
                            OP_REGS <= READ_RESULT_MATC10;
                        end
                        READ_RESULT_MATC11  : begin
                            OP_REGS <= READ_RESULT_MATC11;
                        end
                        READ_RESULT_MATC12  : begin
                            OP_REGS <= READ_RESULT_MATC12;
                        end
                        READ_RESULT_MATC20  : begin
                            OP_REGS <= READ_RESULT_MATC20;
                        end
                        READ_RESULT_MATC21  : begin
                            OP_REGS <= READ_RESULT_MATC21;
                        end
                        READ_RESULT_MATC22  : begin
                            OP_REGS <= READ_RESULT_MATC22;
                        end
                        READ_ERROR : begin
                            OP_REGS <= READ_ERROR;
                        end
                        ERROR               : begin
                            OP_REGS <= ERROR;
                        end
                        default : begin
                            OP_REGS <= RESET_REG;
                        end
                    endcase
            end
            default : begin
                OP_REGS <= RESET_REG;
            end

        endcase
    end



    

end

endmodule
