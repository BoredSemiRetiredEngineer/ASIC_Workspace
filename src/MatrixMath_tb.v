module testbench;
    

    // Connections

    reg clk;
    reg rst_n;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;

    MatrixMath MatrixMath(.clk(clk), .rst_n(rst_n), .ui_in(ui_in), .uo_out(uo_out), .uio_in(uio_in));

    initial 
        clk = 0;
     
    always
        #5 clk = ~clk;
    
    initial begin
        $dumpfile("tb_waveform.vcd");
        $dumpvars(0,testbench);
        #1 rst_n = 0;
        #2 ui_in = 8'h01;
        #10 uio_in = 8'h11;
        #20 uio_in = 8'hBB;
        #20 ui_in = 8'h01;
        #30 uio_in = 8'h12;
        #40 uio_in = 8'hBB;
        #50 ui_in = 8'h01;
        #60 uio_in = 8'h13;
        #70 uio_in = 8'hBB;
        #80 ui_in = 8'h01;
        #90 uio_in = 8'h21;
        #100 uio_in = 8'hBB;
        #110 ui_in = 8'h01;
        #120 uio_in = 8'h22;
        #130 uio_in = 8'hBB;
        #140 ui_in = 8'h01;
        #150 uio_in = 8'h23;
        #160 uio_in = 8'hBB;
        #170 ui_in = 8'h01;
        #180 uio_in = 8'h31;
        #190 uio_in = 8'hBB;
        #200 ui_in = 8'h01;
        #210 uio_in = 8'h32;
        #220 uio_in = 8'hBB;
        #230 ui_in = 8'h01;
        #240 uio_in = 8'h33;
        #250 uio_in = 8'hBB;
        #260 ui_in = 8'hFF;
        #270 uio_in = 8'h41;
        #280 uio_in = 8'hBB;
        #290 ui_in = 8'h01;
        #300 uio_in = 8'h42;
        #310 uio_in = 8'hBB;
        #320 ui_in = 8'h01;
        #330 uio_in = 8'h43;
        #340 uio_in = 8'hBB;
        #350 ui_in = 8'h01;
        #360 uio_in = 8'h51;
        #370 uio_in = 8'hBB;
        #380 ui_in = 8'h01;
        #390 uio_in = 8'h52;
        #400 uio_in = 8'hBB;
        #410 ui_in = 8'h01;
        #420 uio_in = 8'h53;
        #430 uio_in = 8'hBB;
        #440 ui_in = 8'h01;
        #450 uio_in = 8'h61;
        #460 uio_in = 8'hBB;
        #470 ui_in = 8'h01;
        #480 uio_in = 8'h62;
        #490 uio_in = 8'hBB;
        #500 ui_in = 8'h01;
        #510 uio_in = 8'h63;
        #520 uio_in = 8'hBB;
        #530 uio_in = 8'hD0;
        #540 uio_in = 8'hAA;
        #550 rst_n = 1;
        #560 ui_in = 8'h01; //Input A00
        #570 uio_in = 8'h11;
        #580 uio_in = 8'hBB;
        #590 ui_in = 8'h23;  //Input A01
        #600 uio_in = 8'h12;
        #610 uio_in = 8'hBB;
        #620 ui_in = 8'h45;  //Input A02
        #630 uio_in = 8'h13;
        #640 uio_in = 8'hBB;
        #650 ui_in = 8'h67;  //Input A10
        #660 uio_in = 8'h21;
        #670 uio_in = 8'hBB;
        #680 ui_in = 8'h89;  //Input A11
        #690 uio_in = 8'h22;
        #700 uio_in = 8'hBB;
        #710 ui_in = 8'hAB;  //Input A12
        #720 uio_in = 8'h23;
        #730 uio_in = 8'hBB;
        #740 ui_in = 8'hCD;  //Input A20
        #750 uio_in = 8'h31;
        #760 uio_in = 8'hBB;
        #770 ui_in = 8'hEF;  //Input A21
        #780 uio_in = 8'h32;
        #790 uio_in = 8'hBB;
        #800 ui_in = 8'hFF;  //Input A22
        #810 uio_in = 8'h33;
        #820 uio_in = 8'hBB;
        #830 ui_in = 8'hFE;  //Input B00
        #840 uio_in = 8'h41;
        #850 uio_in = 8'hBB;
        #860 ui_in = 8'hDC;  //Input B01
        #870 uio_in = 8'h42;
        #880 uio_in = 8'hBB;
        #890 ui_in = 8'hBA;  //Input B02
        #900 uio_in = 8'h43;
        #910 uio_in = 8'hBB;
        #920 ui_in = 8'h98;  //Input B10
        #930 uio_in = 8'h51;
        #940 uio_in = 8'hBB;
        #950 ui_in = 8'h76;  //Input B11
        #960 uio_in = 8'h52;
        #970 uio_in = 8'hBB;
        #980 ui_in = 8'h54;  //Input B12
        #990 uio_in = 8'h53;
        #1000 uio_in = 8'hBB;
        #1010 ui_in = 8'h32;     //Input B20
        #1020 uio_in = 8'h61;    
        #1030 uio_in = 8'hBB;
        #1040 ui_in = 8'h11;     //Input B21 make error
        #1050 uio_in = 8'h62;  
        #1060 uio_in = 8'hBB;
        #1070 ui_in = 8'h00;     //Input B22
        #1080 uio_in = 8'h63;
        #1090 uio_in = 8'hBB;
        #1100 uio_in = 8'hD0;
        #1105 uio_in = 8'hBB;
        #1110 uio_in = 8'hD1;
        #1120 uio_in = 8'hBB;
        #1130 uio_in = 8'hD2;
        #1140 uio_in = 8'hBB;
        #1150 uio_in = 8'hD3;
        #1160 uio_in = 8'hBB;
        #1170 uio_in = 8'hD4;
        #1180 uio_in = 8'hBB;
        #1190 uio_in = 8'hD5;
        #1200 uio_in = 8'hBB;
        #1210 uio_in = 8'hD6;
        #1220 uio_in = 8'hBB;
        #1230 uio_in = 8'hD7;
        #1240 uio_in = 8'hBB;
        #1250 uio_in = 8'hD8;
        #1260 uio_in = 8'hBB;
        #1270 uio_in = 8'hE0;
        #1280 uio_in = 8'hBB;
        #1290 uio_in = 8'hE1;
        #1300 uio_in = 8'hBB;
        #1310 uio_in = 8'hE2;
        #1320 uio_in = 8'hBB;
        #1330 uio_in = 8'hE3;
        #1340 uio_in = 8'hBB;
        #1350 uio_in = 8'hE4;
        #1360 uio_in = 8'hBB;
        #1370 uio_in = 8'hE5;
        #1380 uio_in = 8'hBB;
        #1390 uio_in = 8'hE6;
        #1400 uio_in = 8'hBB;
        #1410 uio_in = 8'hE7;
        #1420 uio_in = 8'hBB;
        #1430 uio_in = 8'hE8;
        #1440 uio_in = 8'hBB;
        #1445 uio_in = 8'hEE;
        #1450 uio_in = 8'hAA; //Reset Regs
        #1460 ui_in = 8'h01; //Input A00
        #1470 uio_in = 8'h11;
        #1480 uio_in = 8'hBB;
        #1490 ui_in = 8'h23;  //Input A01
        #1500 uio_in = 8'h12;
        #1510 uio_in = 8'hBB;
        #1520 ui_in = 8'h45;  //Input A02
        #1530 uio_in = 8'h13;
        #1540 uio_in = 8'hBB;
        #1550 ui_in = 8'h67;  //Input A10
        #1560 uio_in = 8'h21;
        #1570 uio_in = 8'hBB;
        #1580 ui_in = 8'h89;  //Input A11
        #1590 uio_in = 8'h22;
        #1600 uio_in = 8'hBB;
        #1610 ui_in = 8'hAB;  //Input A12
        #1620 uio_in = 8'h23;
        #1630 uio_in = 8'hBB;
        #1640 ui_in = 8'hCD;  //Input A20
        #1650 uio_in = 8'h31;
        #1660 uio_in = 8'hBB;
        #1670 ui_in = 8'hEF;  //Input A21
        #1680 uio_in = 8'h32;
        #1690 uio_in = 8'hBB;
        #1700 ui_in = 8'hFF;  //Input A22
        #1710 uio_in = 8'h33;
        #1720 uio_in = 8'hBB;
        #1730 ui_in = 8'hFE;  //Input B00
        #1740 uio_in = 8'h41;
        #1750 uio_in = 8'hBB;
        #1760 ui_in = 8'hDC;  //Input B01
        #1770 uio_in = 8'h42;
        #1780 uio_in = 8'hBB;
        #1790 ui_in = 8'hBA;  //Input B02
        #1800 uio_in = 8'h43;
        #1810 uio_in = 8'hBB;
        #1820 ui_in = 8'h98;  //Input B10
        #1830 uio_in = 8'h51;
        #1840 uio_in = 8'hBB;
        #1850 ui_in = 8'h76;  //Input B11
        #1860 uio_in = 8'h52;
        #1870 uio_in = 8'hBB;
        #1880 ui_in = 8'h54;  //Input B12
        #1890 uio_in = 8'h53;
        #1900 uio_in = 8'hBB;
        #1910 ui_in = 8'h32;     //Input B20
        #1920 uio_in = 8'h61;    
        #1930 uio_in = 8'hBB;
        #1940 ui_in = 8'h10;     //Input B21 fixed
        #1950 uio_in = 8'h62;  
        #1960 uio_in = 8'hBB;
        #1970 ui_in = 8'h00;     //Input B22
        #1980 uio_in = 8'h63;
        #1990 uio_in = 8'hBB;
        #2000 uio_in = 8'hD0;
        #2005 uio_in = 8'hBB;
        #2010 uio_in = 8'hD1;
        #2020 uio_in = 8'hBB;
        #2030 uio_in = 8'hD2;
        #2040 uio_in = 8'hBB;
        #2050 uio_in = 8'hD3;
        #2060 uio_in = 8'hBB;
        #2070 uio_in = 8'hD4;
        #2080 uio_in = 8'hBB;
        #2090 uio_in = 8'hD5;
        #2100 uio_in = 8'hBB;
        #2110 uio_in = 8'hD6;
        #2120 uio_in = 8'hBB;
        #2130 uio_in = 8'hD7;
        #2140 uio_in = 8'hBB;
        #2150 uio_in = 8'hD8;
        #2160 uio_in = 8'hBB;
        #2170 uio_in = 8'hE0;
        #2180 uio_in = 8'hBB;
        #2190 uio_in = 8'hE1;
        #2200 uio_in = 8'hBB;
        #2210 uio_in = 8'hE2;
        #2220 uio_in = 8'hBB;
        #2230 uio_in = 8'hE3;
        #2240 uio_in = 8'hBB;
        #2250 uio_in = 8'hE4;
        #2260 uio_in = 8'hBB;
        #2270 uio_in = 8'hE5;
        #2280 uio_in = 8'hBB;
        #2290 uio_in = 8'hE6;
        #2300 uio_in = 8'hBB;
        #2310 uio_in = 8'hE7;
        #2320 uio_in = 8'hBB;
        #2330 uio_in = 8'hE8;
        #2340 uio_in = 8'hBB;
        #2350 uio_in = 8'hEE;
        #2360 uio_in = 8'hAA; //Reset Regs
        #2370 uio_in = 8'hBB;
        #2380 ui_in = 8'h53; //Input A00
        #2390 uio_in = 8'h11;
        #2400 uio_in = 8'hBB;
        #2410 ui_in = 8'h26;  //Input B00
        #2420 uio_in = 8'h41;
        #2430 uio_in = 8'hBB;
        #2440 uio_in = 8'hD0;
        #2450 uio_in = 8'hBB;
        #2460 uio_in = 8'hE0;
        #2470 uio_in = 8'hBB;
        #2480 uio_in = 8'hEE;


        #10000 $finish;


    end
    initial begin
    $monitor("clk = %b, rst_n = %b : ui_in = %h, uio_in = %h --> uo_out = %h  ", clk, rst_n, ui_in, uio_in, uo_out);
    end

endmodule
