//top test for alu

class alu_t extends uvm_test;
`uvm_component_utils(alu_t)

alu_sq sq1;
alu_seqr seqr;
alu_drv drv;

function new(string name="alu_t", uvm_component parent = null);
	super.new(name, parent);
endfunction


function void build_phase(uvm_phase phase);
	seqr = alu_seqr::type_id::create("seqr",this);
	drv = alu_drv::type_id::create("drv", this);
	
	
endfunction : build_phase

function void connect_phase(uvm_phase phase);
	drv.seq_item_port.connect(seqr.seq_item_export);
endfunction : connect_phase

task run_phase(uvm_phase phase);
	sq1 = alu_sq::type_id::create("sq1", this);
	phase.raise_objection(this);
	//tests
	
	$display("-------------------rnt----------------");
	sq1.start(seqr);
	
	
	
	
	
	phase.drop_objection(this);
endtask: run_phase

endclass : alu_t
