class alu_seqr extends uvm_sequencer #(alu_i);
`uvm_component_utils(alu_seqr)

function new(string name = "alu_seqr", uvm_component parent = null);
	super.new(name, parent);
endfunction


endclass : alu_seqr
