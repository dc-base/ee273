class encoderDriver extends uvm_driver#(encoderSequenceItem);
  `uvm_component_utils(encoderDriver)
      virtual encoder ecd;


	  
	  logic [2:0] state ;
      logic controlCode = 0;
      logic [8:0] nineBitData;
	  
  	function new(string name="encoderDiver", uvm_component parent);
    	super.new(name, parent);
    endfunction: new
 	 
  	virtual function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      if(!(uvm_config_db#(virtual encoder)::get(this,"*","encoder",ecd)))
        `uvm_fatal("encoderDriver", "vif failed")
        
    endfunction: build_phase
      
    task run_phase(uvm_phase phase);
          drive();
     endtask: run_phase

     virtual task drive();
     	encoderSequenceItem eSI; //sequenceItem 
     	ecd.pushin = 'b0; 
     	ecd.startin = 'b0;
     	ecd.datain = 'b0;
     	
		//concat with unsize constants dynamic type in non proc context
     	//assign nineBitData = {controlCode, 'b00111100};
       nineBitData = {controlCode, 8'b00111100};
     	forever begin 

     	@(posedge ecd.clk)	
     		case(state)
     		0: begin 
     			ecd.reset = 'b1;
     		end
     		1: begin
     			ecd.reset = 'b0;
     			ecd.pushin = 'b1;
     			ecd.startin ='b1;
     			ecd.datain  = 'b100111100;  //hardcode to k28.1
     			state = state  + 1; 
     		end 
     		2: begin
     			ecd.startin = 'b0;
     			ecd.datain = 'b100111100; 
     			state = state + 1; 
     		end 
     		3: begin
     			ecd.datain = 'b100111100; 
     			state = state + 1;
     		end 
     		4: begin 
     			ecd.datain = 'b100111100;
     			state = state + 1; 
     		end 
     		5: begin
     			seq_item_port.try_next_item(eSI);
     			while(eSI != null)
     			begin
     				controlCode = 0;
     				//seq_item_port.get_next_item(eSI);
     				nineBitData = {controlCode,eSI.data};
     				ecd.datain = nineBitData;
     			    seq_item_port.try_next_item(eSI);
     			end
     			state = state + 1;
     		end 
     		6: begin
     			ecd.datain = 'b110111100; //k28.5 control packet
     			ecd.pushin = 0; 
     		end 
     		endcase
     	end 

     endtask: drive

endclass: encoderDriver
