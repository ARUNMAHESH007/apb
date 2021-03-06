`define DATA_WIDTH  8
`define ADDR_WIDTH  8
`define STATE_WIDTH 2
`define UPPER_ADDR_LIMIT 200

module slave_apb ( 
                   output reg [ `DATA_WIDTH-1 : 0 ]   prdata, 			// dataout from slave	(prdata_c)
                   output reg                         pready, 			// ready signal from slave(pready_c)
                   output reg                         pslverr,			// error signal from salve
		   input                	      penable,                  // to enable read or write
                   input                	      pwrite, 			// control signal 
                   input 	         	      psel,  			// select signal
                   input                              pclk,   			// posedge clk
                   input                	      presetn, 			// negedge reset              
                   input      [ `ADDR_WIDTH-1 : 0 ]   paddr,  			// 8-bit address            
                   input      [ `DATA_WIDTH-1 : 0 ]   pwdata 			// 8-bit write data    
                   );
  
  parameter         IDLE    = 2'd0;              				// states
  parameter         SETUP   = 2'd1;
  parameter         ENABLE  = 2'd2;
  
  reg   [ `STATE_WIDTH-1 : 0 ]   pre_state;   					// to store state changes
  reg   [ `STATE_WIDTH-1 : 0 ]   nxt_state;
  reg   [ `DATA_WIDTH-1 : 0 ]    mem [ 0 : ((2**`ADDR_WIDTH)-1) ]; 		// memory
  reg   [ `DATA_WIDTH-1 : 0 ]    prdata_c;
  reg pready_c;
  reg pslverr_c;
  
  always @ ( posedge pclk or negedge presetn )
  	
  	begin// : fsm_slave
    	     if ( ! presetn )
      			pre_state <= IDLE;
    	     else 
      			pre_state <= nxt_state;
  	end// : fsm_slave
  
  always @ ( * ) 
  	begin
    		prdata_c   = `DATA_WIDTH'd0;
    		pslverr_c  = 1'b0;
    	 	nxt_state  = IDLE;     
    			
		case ( pre_state )
      	
			IDLE   : begin //: idle_state
          				if ( psel == 1 ) 
            					nxt_state = SETUP;
	        			else
          				     begin
            					nxt_state = IDLE;
  	        				prdata_c = `DATA_WIDTH'd0;
          				     end
        			end //: idle_state
      
      		      SETUP  : begin //: setup_state
          				nxt_state  = ENABLE;
        			end //: setup_state
      			
		     ENABLE : begin //: enable_state
          			
		      		    if(paddr <= `UPPER_ADDR_LIMIT)
          				begin
            					pslverr_c      = 1'b0;
            					
						if ( psel == 1 )  //condition for state change
              						nxt_state    = SETUP;
            					else
              						nxt_state    = IDLE; 

	         				 if(!pwrite)     //operation rd/wr

              						prdata_c     = mem [ paddr ];
            					else 
	            					mem [paddr]  = pwdata;


            						//The following is a neat little trick to check whether 
            						//the data is non 'x' value ie read from a unwritten location
            						//If the read is from a written location,prdata_c
            						//will return a valid value whose bitwise 'xor' will either return a
          						//'1' or '0' and not 'x

            					if(((^prdata_c == 1'b0) || (^prdata_c == 1'b1))&& (pwrite == 1'b0))
             					 		pslverr_c    = 1'b0;
            					else
              						  	pslverr_c    = 1'b1;
          			        end // if (paddr <= `ADDR_UPPER_LIMIT)
          		
				else
				        pslverr_c     = 1'b0;
        		     end // case: ENABLE
                  default : nxt_state = IDLE;
          
    endcase
  end //: state_change
  
  always @ ( posedge pclk or negedge presetn)
 	 begin
    		if ( ! presetn)
    			begin
      				prdata    <= 8'b0;
      				pslverr   <= 1'b0;
    			end  
    	     else
      		   if ( ( pre_state == ENABLE ) )
      			begin
        			prdata  <= prdata_c;
        			pready  <= $random;
        			pslverr <= 1'b0;
      			end
  	end
endmodule
