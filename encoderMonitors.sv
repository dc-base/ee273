//Monitor at input
class encoderMonitorInput extends uvm_monitor;
`uvm_component_utils(encoderMonitorInput)

uvm_analysis_port#(encoderSequenceMessage) monitorAtInput;

virtual encoder ecd;
encoderSequenceMessage eSM;


function new(string name, uvm_component parent);
	super.new(name,parent);
endfunction: new 

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
     if(!(uvm_config_db#(virtual encoder)::get(this,"*","encoder",ecd)))
       `uvm_fatal("encoderMonIN", "vif failed")
	monitorAtInput = new("encoderSequenceMesssage",this);
endfunction: build_phase

task run_phase(uvm_phase phase);
	forever @(posedge ecd.clk) begin
			if((!ecd.reset && ecd.startin==1) || (!ecd.reset && ecd.pushin==1))
			begin
				eSM = new();
				eSM.datain = ecd.datain;
				monitorAtInput.write(eSM);
			end 
	end		
endtask: run_phase

endclass: encoderMonitorInput 



//Monitor At Output
class encoderMonitorOutput extends uvm_monitor;
`uvm_component_utils(encoderMonitorOutput)
  
virtual encoder ecd;
encoderSequenceMessageOutput eSMOut;

uvm_analysis_port #(encoderSequenceMessageOutput) monitorAtOutput;

function new(string name="encoderMonitorOutput",uvm_component parent=null);
	super.new(name,parent);
endfunction: new

function void connect_phase(uvm_phase phase);
endfunction: connect_phase

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    if(!(uvm_config_db#(virtual encoder)::get(this,"*","encoder",ecd)))
      `uvm_fatal("encoderMonOUT", "vif failed")
	monitorAtOutput = new("encoderSequenceMessageOutput",this);

endfunction: build_phase

task run_phase(uvm_phase phase);
	forever @(posedge(ecd.clk)) begin 
	if((!ecd.reset && ecd.startout==1) || (!ecd.reset && ecd.pushout==1)) 
      	begin
		eSMOut = new();
		eSMOut.dataout = ecd.dataout;
		monitorAtOutput.write(eSMOut);
        end
	end
endtask: run_phase

endclass: encoderMonitorOutput

