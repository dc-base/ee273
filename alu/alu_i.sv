//msg item for sequencer

typedef enum {
	op_add,
	op_xor
	} operation;
	
	
class alu_i extends uvm_sequence_item;
`uvm_object_utils(alu_i)

function new (string name = "alu_i");
	super.new(name);
endfunction

	operation op; //0 to add, 1 to xor
	rand logic signed [35:0] A; //signed
	rand logic signed [20:0] B; //signed
	logic ci; //carry in

endclass : alu_i
