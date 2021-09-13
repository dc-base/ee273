class encoderTest extends uvm_test;
`uvm_component_utils(encoderTest)
encoderSequence ecdSequence;
encoderSequencer ecdSequencer;
encoderDriver ecdDriver;
encoderMonitorInput ecdMonIn;
encoderMonitorOutput ecdMonOut;
encoderScoreboard ecdScoreboard;

function new(string name="encoderTest",uvm_component parent=null);
	super.new(name,parent);
endfunction: new

  virtual encoder ecd;
  
function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  uvm_config_db#(virtual encoder)::set(this, "*", "encoder", ecd);
  
  
  
  
	//ecdSequence = encoderSequence::type_id::create("ecdSequence",this);
	ecdSequencer = encoderSequencer::type_id::create("ecdSequencer",this);
	ecdDriver = encoderDriver::type_id::create("ecdDriver",this);
	ecdMonIn = encoderMonitorInput::type_id::create("ecdMonIn",this);
	ecdMonOut = encoderMonitorOutput::type_id::create("ecdMonOut",this);
	ecdScoreboard = encoderScoreboard::type_id::create("ecdScoreboard",this);
endfunction: build_phase

// Monitor Variable Declarations
// encoderSequenceMessage eSM;
// encoderSequenceMessageOutput eSMOut;

// uvm_tlm_analysis_fifo #(encoderSequenceMessage) eSMInputFIFO;
// uvm_tlm_analysis_fifo #(encoderSequenceMessageOutput) eSMOutputFIFO;  
  
  
  
function void connect_phase (uvm_phase phase);
	ecdDriver.seq_item_port.connect(ecdSequencer.seq_item_export);
  
 // ecdMonIn.monitorAtInput.connect(ecdScoreboard.eSM.analysis_export);
   //analysis export does not exist
  ecdMonIn.monitorAtInput.connect(ecdScoreboard.eSMInputFIFO.analysis_export);
 
  
	//ecdMonOut.monitorAtOutput.connect(ecdScoreboard.eSMOut.analysis_export); 
  ecdMonOut.monitorAtOutput.connect(ecdScoreboard.eSMOutputFIFO.analysis_export); 
	
endfunction: connect_phase
	
task run_phase(uvm_phase phase);
	ecdSequence = encoderSequence::type_id::create("ecdSequence");
	phase.raise_objection(this);
	ecdSequence.start(ecdSequencer);
	#1000;
	phase.drop_objection(this);
endtask : run_phase



endclass: encoderTest

