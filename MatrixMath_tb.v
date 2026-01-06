module testbench;
    

    // Connections

    reg clk;
    reg rst_n;
    reg [7:0] ui_in;
    reg [7:0] uio;
    wire [7:0] uo_out;

    MatrixMath MatrixMath(.clk(clk), .rst_n(rst_n), .ui_in(ui_in), .uo_out(uo_out), .uio(uio));

    initial 
        clk = 0;
     
    always
        #5 clk = ~clk;
    
    initial begin
        $dumpfile("tb_waveform.vcd");
        $dumpvars(0,testbench);

        #1 rst_n = 1;
        #2 ui_in = 8'hFF;
        #10 uio = 8'h00;
        #500 uio = 8'hCA;
        #510 uio = 8'hCB;
        #600 uio = 8'hBB;
        #2000 rst_n = 0;
        #2500 rst_n = 1;
//     #600 uio = 8'hDA;
//      #700 uio = 8'hDB;
//      #800 uio = 8'hEE;
        #10000 $finish;

    end
    initial begin
    $monitor("clk = %b, rst_n = %b : ui_in = %h, uio = %h --> uo_out = %h  ", clk, rst_n, ui_in, uio, uo_out);
    end

endmodule
