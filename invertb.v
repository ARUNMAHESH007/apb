module invertertb;
  reg a;
  wire y;

  //Design Instance
  inv jinv(a,y);
  
	initial
	begin
      $display ("RESULT\ta\tb");
#10 a=1'b1;
#10 a=1'b0; 		
	end
  
  //enabling the wave dump
 // initial begin 
 //   $dumpfile("dump.vcd"); $dumpvars;
  //end
endmodule