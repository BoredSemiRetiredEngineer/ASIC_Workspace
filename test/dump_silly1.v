module dump();
    initial begin
        $dumpfile ("silly1.vcd");
        $dumpvars (0, silly1);
        #1;
    end
endmodule
