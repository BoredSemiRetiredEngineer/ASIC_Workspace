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
/** Date of creation: 12/04/2025                                            **/
/**                                                                         **/
/** Dependent Files:  MatrixOps.v                                           **/
/**                                                                         **/
/*****************************************************************************/

/* Things to consider:                                                      **/
/*  1) Loading Matrix collisions                                            **/

module MatrixMath (
    
    
    input clk,
    input rst_n,
    input [7:0] ui_in,
    output [7:0] uo_out, 
    inout [7:0] uio
    );
    //Register Operations and states
    typedef enum logic [7:0] {
        RESET_REG        =   8'hAA,
        IDLE_REG         =   8'hBB,
        LOAD_REGA        =   8'hCA,
        LOAD_REGB        =   8'hCB,
        OPERATE_REG_ADD  =   8'hDA,
        OPERATE_REG_SUB  =   8'hDB,
        READ_RESULT_MATC =   8'hEE

    } reg_state;

    reg_state OP_REGS;

    // Registers for the internals
    reg [7:0] Ain;
    reg [7:0] Bin;
    reg [7:0] State_out = uo_out; // fix?
    reg [7:0] Cinout = uio; 
    reg [7:0] MatrixA[2:0][2:0];
    reg [7:0] MatrixB[2:0][2:0];
    reg [7:0] MatrixC[2:0][2:0];
    wire reset = ! rst_n;
    assign uo_out = State_out;

    // Operations Modules
    // MatrixOps MatrixOps(.clk(clk), .rst_n(rst_n), .ui_in(ui_in), .uo_out(uo_out), .uio(uio));
    
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
        case(Cinout)
            RESET_REG : begin
                OP_REGS <= RESET_REG;
            end
            IDLE_REG : begin
                OP_REGS <= IDLE_REG;
            end
            LOAD_REGA : begin
                OP_REGS <= LOAD_REGA;
            end
            LOAD_REGB : begin
                OP_REGS <= LOAD_REGB;
            end
            OPERATE_REG_ADD : begin
                OP_REGS <= OPERATE_REG_ADD;
            end
            OPERATE_REG_SUB : begin
                OP_REGS <= OPERATE_REG_SUB;
            end
            READ_RESULT_MATC : begin
                OP_REGS <= READ_RESULT_MATC;
            end
            default: begin
                OP_REGS <= RESET_REG;
            end
        endcase
    end else begin
       
        case(OP_REGS) 
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
                case(Cinout)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA : begin
                        OP_REGS <= LOAD_REGA;
                    end
                    LOAD_REGB : begin
                        OP_REGS <= LOAD_REGB;
                    end
                    OPERATE_REG_ADD : begin
                        OP_REGS <= OPERATE_REG_ADD;
                    end
                    OPERATE_REG_SUB : begin
                        OP_REGS <= OPERATE_REG_SUB;
                    end
                    READ_RESULT_MATC : begin
                        OP_REGS <= READ_RESULT_MATC;
                    end
                    default:
                        OP_REGS <= RESET_REG;
                endcase
            end
            IDLE_REG : begin
                Ain <= Ain;
                Bin <= Bin;
                State_out <= OP_REGS;
                // Direct state machine
                case(Cinout)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA : begin
                        OP_REGS <= LOAD_REGA;
                    end
                    LOAD_REGB : begin
                        OP_REGS <= LOAD_REGB;
                    end
                    OPERATE_REG_ADD : begin
                        OP_REGS <= OPERATE_REG_ADD;
                    end
                    OPERATE_REG_SUB : begin
                        OP_REGS <= OPERATE_REG_SUB;
                    end
                    READ_RESULT_MATC : begin
                        OP_REGS <= READ_RESULT_MATC;
                    end
                    default:
                        OP_REGS <= RESET_REG;
                endcase
            end
            LOAD_REGA : begin
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

                MatrixA[0][1][0] <= Ain[0];
                MatrixA[0][1][1] <= Ain[1];
                MatrixA[0][1][2] <= Ain[2];
                MatrixA[0][1][3] <= Ain[3];
                MatrixA[0][1][4] <= Ain[4];
                MatrixA[0][1][5] <= Ain[5];
                MatrixA[0][1][6] <= Ain[6];
                MatrixA[0][1][7] <= Ain[7];

                MatrixA[0][2][0] <= Ain[0];
                MatrixA[0][2][1] <= Ain[1];
                MatrixA[0][2][2] <= Ain[2];
                MatrixA[0][2][3] <= Ain[3];
                MatrixA[0][2][4] <= Ain[4];
                MatrixA[0][2][5] <= Ain[5];
                MatrixA[0][2][6] <= Ain[6];
                MatrixA[0][2][7] <= Ain[7];

                MatrixA[1][0][0] <= Ain[0];
                MatrixA[1][0][1] <= Ain[1];
                MatrixA[1][0][2] <= Ain[2];
                MatrixA[1][0][3] <= Ain[3];
                MatrixA[1][0][4] <= Ain[4];
                MatrixA[1][0][5] <= Ain[5];
                MatrixA[1][0][6] <= Ain[6];
                MatrixA[1][0][7] <= Ain[7];

                MatrixA[1][1][0] <= Ain[0];
                MatrixA[1][1][1] <= Ain[1];
                MatrixA[1][1][2] <= Ain[2];
                MatrixA[1][1][3] <= Ain[3];
                MatrixA[1][1][4] <= Ain[4];
                MatrixA[1][1][5] <= Ain[5];
                MatrixA[1][1][6] <= Ain[6];
                MatrixA[1][1][7] <= Ain[7];

                MatrixA[1][2][0] <= Ain[0];
                MatrixA[1][2][1] <= Ain[1];
                MatrixA[1][2][2] <= Ain[2];
                MatrixA[1][2][3] <= Ain[3];
                MatrixA[1][2][4] <= Ain[4];
                MatrixA[1][2][5] <= Ain[5];
                MatrixA[1][2][6] <= Ain[6];
                MatrixA[1][2][7] <= Ain[7];

                MatrixA[2][0][0] <= Ain[0];
                MatrixA[2][0][1] <= Ain[1];
                MatrixA[2][0][2] <= Ain[2];
                MatrixA[2][0][3] <= Ain[3];
                MatrixA[2][0][4] <= Ain[4];
                MatrixA[2][0][5] <= Ain[5];
                MatrixA[2][0][6] <= Ain[6];
                MatrixA[2][0][7] <= Ain[7];

                MatrixA[2][1][0] <= Ain[0];
                MatrixA[2][1][1] <= Ain[1];
                MatrixA[2][1][2] <= Ain[2];
                MatrixA[2][1][3] <= Ain[3];
                MatrixA[2][1][4] <= Ain[4];
                MatrixA[2][1][5] <= Ain[5];
                MatrixA[2][1][6] <= Ain[6];
                MatrixA[2][1][7] <= Ain[7];

                MatrixA[2][2][0] <= Ain[0];
                MatrixA[2][2][1] <= Ain[1];
                MatrixA[2][2][2] <= Ain[2];
                MatrixA[2][2][3] <= Ain[3];
                MatrixA[2][2][4] <= Ain[4];
                MatrixA[2][2][5] <= Ain[5];
                MatrixA[2][2][6] <= Ain[6];
                MatrixA[2][2][7] <= Ain[7];
                                                   
                // Direct state machine
                case(Cinout)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA : begin
                        OP_REGS <= LOAD_REGA;
                    end
                    LOAD_REGB : begin
                        OP_REGS <= LOAD_REGB;
                    end
                    OPERATE_REG_ADD : begin
                        OP_REGS <= OPERATE_REG_ADD;
                    end
                    OPERATE_REG_SUB : begin
                        OP_REGS <= OPERATE_REG_SUB;
                    end
                    READ_RESULT_MATC : begin
                        OP_REGS <= READ_RESULT_MATC;
                    end
                    default:
                        OP_REGS <= RESET_REG;
                endcase
            end
            LOAD_REGB : begin
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

                MatrixB[0][1][0] <= Bin[0];
                MatrixB[0][1][1] <= Bin[1];
                MatrixB[0][1][2] <= Bin[2];
                MatrixB[0][1][3] <= Bin[3];
                MatrixB[0][1][4] <= Bin[4];
                MatrixB[0][1][5] <= Bin[5];
                MatrixB[0][1][6] <= Bin[6];
                MatrixB[0][1][7] <= Bin[7];

                MatrixB[0][2][0] <= Bin[0];
                MatrixB[0][2][1] <= Bin[1];
                MatrixB[0][2][2] <= Bin[2];
                MatrixB[0][2][3] <= Bin[3];
                MatrixB[0][2][4] <= Bin[4];
                MatrixB[0][2][5] <= Bin[5];
                MatrixB[0][2][6] <= Bin[6];
                MatrixB[0][2][7] <= Bin[7];

                MatrixB[1][0][0] <= Bin[0];
                MatrixB[1][0][1] <= Bin[1];
                MatrixB[1][0][2] <= Bin[2];
                MatrixB[1][0][3] <= Bin[3];
                MatrixB[1][0][4] <= Bin[4];
                MatrixB[1][0][5] <= Bin[5];
                MatrixB[1][0][6] <= Bin[6];
                MatrixB[1][0][7] <= Bin[7];

                MatrixB[1][1][0] <= Bin[0];
                MatrixB[1][1][1] <= Bin[1];
                MatrixB[1][1][2] <= Bin[2];
                MatrixB[1][1][3] <= Bin[3];
                MatrixB[1][1][4] <= Bin[4];
                MatrixB[1][1][5] <= Bin[5];
                MatrixB[1][1][6] <= Bin[6];
                MatrixB[1][1][7] <= Bin[7];

                MatrixB[1][2][0] <= Bin[0];
                MatrixB[1][2][1] <= Bin[1];
                MatrixB[1][2][2] <= Bin[2];
                MatrixB[1][2][3] <= Bin[3];
                MatrixB[1][2][4] <= Bin[4];
                MatrixB[1][2][5] <= Bin[5];
                MatrixB[1][2][6] <= Bin[6];
                MatrixB[1][2][7] <= Bin[7];

                MatrixB[2][0][0] <= Bin[0];
                MatrixB[2][0][1] <= Bin[1];
                MatrixB[2][0][2] <= Bin[2];
                MatrixB[2][0][3] <= Bin[3];
                MatrixB[2][0][4] <= Bin[4];
                MatrixB[2][0][5] <= Bin[5];
                MatrixB[2][0][6] <= Bin[6];
                MatrixB[2][0][7] <= Bin[7];

                MatrixB[2][1][0] <= Bin[0];
                MatrixB[2][1][1] <= Bin[1];
                MatrixB[2][1][2] <= Bin[2];
                MatrixB[2][1][3] <= Bin[3];
                MatrixB[2][1][4] <= Bin[4];
                MatrixB[2][1][5] <= Bin[5];
                MatrixB[2][1][6] <= Bin[6];
                MatrixB[2][1][7] <= Bin[7];

                MatrixB[2][2][0] <= Bin[0];
                MatrixB[2][2][1] <= Bin[1];
                MatrixB[2][2][2] <= Bin[2];
                MatrixB[2][2][3] <= Bin[3];
                MatrixB[2][2][4] <= Bin[4];
                MatrixB[2][2][5] <= Bin[5];
                MatrixB[2][2][6] <= Bin[6];
                MatrixB[2][2][7] <= Bin[7];
               
                // Direct state machine
                case(Cinout)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA : begin
                        OP_REGS <= LOAD_REGA;
                    end
                    LOAD_REGB : begin
                        OP_REGS <= LOAD_REGB;
                    end
                    OPERATE_REG_ADD : begin
                        OP_REGS <= OPERATE_REG_ADD;
                    end
                    OPERATE_REG_SUB : begin
                        OP_REGS <= OPERATE_REG_SUB;
                    end
                    READ_RESULT_MATC : begin
                        OP_REGS <= READ_RESULT_MATC;
                    end
                    default:
                        OP_REGS <= RESET_REG;
                endcase
            end
            OPERATE_REG_ADD : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;
                // Direct state machine
                case(Cinout)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA : begin
                        OP_REGS <= LOAD_REGA;
                    end
                    LOAD_REGB : begin
                        OP_REGS <= LOAD_REGB;
                    end
                    OPERATE_REG_ADD : begin
                        OP_REGS <= OPERATE_REG_ADD;
                    end
                    OPERATE_REG_SUB : begin
                        OP_REGS <= OPERATE_REG_SUB;
                    end
                    READ_RESULT_MATC : begin
                        OP_REGS <= READ_RESULT_MATC;
                    end
                    default:
                        OP_REGS <= RESET_REG;
                endcase
            end
            OPERATE_REG_SUB : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;
                // Direct state machine
                case(Cinout)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA : begin
                        OP_REGS <= LOAD_REGA;
                    end
                    LOAD_REGB : begin
                        OP_REGS <= LOAD_REGB;
                    end
                    OPERATE_REG_ADD : begin
                        OP_REGS <= OPERATE_REG_ADD;
                    end
                    OPERATE_REG_SUB : begin
                        OP_REGS <= OPERATE_REG_SUB;
                    end
                    READ_RESULT_MATC : begin
                        OP_REGS <= READ_RESULT_MATC;
                    end
                    default:
                        OP_REGS <= RESET_REG;
                endcase
            end
            READ_RESULT_MATC : begin
                State_out <= OP_REGS;
                Ain <= Ain;
                Bin <= Bin;
                // Direct state machine
                case(Cinout)
                    RESET_REG : begin
                        OP_REGS <= RESET_REG;
                    end
                    IDLE_REG : begin
                        OP_REGS <= IDLE_REG;
                    end
                    LOAD_REGA : begin
                        OP_REGS <= LOAD_REGA;
                    end
                    LOAD_REGB : begin
                        OP_REGS <= LOAD_REGB;
                    end
                    OPERATE_REG_ADD : begin
                        OP_REGS <= OPERATE_REG_ADD;
                    end
                    OPERATE_REG_SUB : begin
                        OP_REGS <= OPERATE_REG_SUB;
                    end
                    READ_RESULT_MATC : begin
                        OP_REGS <= READ_RESULT_MATC;
                    end
                    default:
                        OP_REGS <= RESET_REG;
                endcase
            end
            default:
                OP_REGS <= IDLE_REG;
        endcase
    end
end


endmodule
