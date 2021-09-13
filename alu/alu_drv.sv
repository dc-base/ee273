class alu_drv extends uvm_driver #(alu_i);
`uvm_component_utils(alu_drv)
alu_i d_itm;

function new(string name = "alu_drv", uvm_component parent = null);
	super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(d_itm);
		$display("Operation: %s Input_A: %0d Input_B: %0d, Carry_In: %d",
			d_itm.op, d_itm.A, d_itm.B, d_itm.ci);
		seq_item_port.item_done();
	end
	
endtask : run_phase

endclass : alu_drv
