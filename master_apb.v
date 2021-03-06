
`timescale 1ms/1us // 1ms-0-1cms , 1us=1mm 2mm
`define DATA_WIDTH  8
`define ADDR_WIDTH  8
`define STATE_WIDTH 2
`define UPPER_ADDR_LIMIT 200

module master_apb();
 		   wire [ `DATA_WIDTH-1 : 0 ]   prdata; 			// dataout from slave
                   wire                         pready; 			// ready signal from slave
                   wire                         pslverr;			// error signal from salve
		   reg                	      penable;                 // to enable read or write
                   reg                	      pwrite; 			// control signal 
                   reg 	         	      psel; 			// select signal
                   reg                              pclk;   			// posedge clk
                   reg                	      presetn; 			// negedge reset              
                   reg      [ `ADDR_WIDTH-1 : 0 ]   paddr;  			// 8-bit address            
                   reg     [ `DATA_WIDTH-1 : 0 ]   pwdata; 			// 8-bit write data    
         

		  wire [ `DATA_WIDTH-1 : 0 ]   rdata_c; 			// dataout from slave
                   reg      [ `ADDR_WIDTH-1 : 0 ]   addr;  			// 8-bit address            
                   reg     [ `DATA_WIDTH-1 : 0 ]   wdata; 		//8bit right data
                  



 
slave_apb dut(prdata, pready,pslverr, penable,pwrite,psel,pclk,presetn,padder,pwdata);

//generate the clock and initialize  the other signals
initial begin
penable=0;
presetn=0;
pclk=0;
forever #1 pclk= ~pclk;
end
/*---------------------------------------------------------------------------------------------------*/
//generate the test_case 1
/*=--------------------------------------------------------------------------------------------------*/
initial begin
presetn=1;

@(negedge pclk);

    penable=1;

    psel = 1;
    pwrite = 1;
    paddr = 8'h33;
    pwdata = 8'h88;
  


//enable state
@(negedge pclk);
	penable=1;
	//rdata_c=prdata;
	wdata=pwdata;
	addr=paddr;

//ideal state
@(negedge pclk);
	 penable = 0;
   	 psel= 0;
         $display("Write: addr 0x%x data 0x%x",addr, wdata);

//----------------------------------------------------------------------------------------------------------//

//generate the test_case 2

/*-----------------------------------------------------------------------------------------------------------------*/
@(negedge pclk);
    psel = 1;
    pwrite = 0;
    paddr = 2'b01;
     pwdata=2'b11;
   



//enable state
@(negedge pclk);
	penable=1;
	//rdata_c=prdata;
	wdata=pwdata;
	addr=paddr;

//ideal state
@(negedge pclk);
	 penable = 0;
   	 psel = 0;
      //   $display("read: addr 0x%x data 0x%x",addr, wdata);
#100 $finish;

end
endmodule





































