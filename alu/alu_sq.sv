class alu_sq extends uvm_sequence #(alu_i);
`uvm_object_utils(alu_sq)
alu_i itm;
int r;

function new(string name = "alu_sq");
	super.new(name);
endfunction 

task body();
$display("------------body------------");
	itm = alu_i::type_id::create("seq_item");
	doxor(100);
	docarry1(20);
	docarry2(20);
	docarry3(10);
	
endtask : body

//randomizes all values and requests the DUT to perform a xor operation
//extreme edge case but also test if carry in flag breaks xor
task doxor(input int n);
	repeat(n) begin
		r = $urandom_range(0,1);
		if (r) begin
			itm.ci = 1;
			end
		else begin
			itm.ci = 0;
			end
		start_item(itm);
		itm.op = op_xor;
		itm.randomize();
		finish_item(itm);
	end
endtask : doxor

//case 1, the sum of inputs A and B are at the max of bits [5:0]
//carry in flag is on so carry procedure must result in value [6:0]
task docarry1(input int n);
	repeat(n) begin
	start_item(itm);
	itm.op = op_add;
	itm.randomize() with {A+B == 63;};
	itm.ci = 1;
	finish_item(itm);
	end
endtask : docarry1

//case 2, the sum of A and B are less than max of [5:0]
//with carry bit on, carry will occur but will not increase to [6:0]
task docarry2(input int n);
	repeat(n) begin
	start_item(itm);
	itm.op = op_add;
	itm.ci = 1;
	itm.randomize() with {A+B < 63;};
	finish_item(itm);
	end
endtask : docarry2

//case 3. carry bit is off. the value is less and = than max [5:0] carry should not occur
task docarry3(input int n);
	repeat(n) begin
	start_item(itm);
	itm.op = op_add;
	itm.ci = 0;
	itm.randomize() with {A+B <= 63;};
	finish_item(itm);
	end
endtask : docarry3

task doall(input int n);
	repeat(n) begin
	r = $urandom_range(0,1);
	start_item(itm);
	if (r) begin
		itm.op = op_add;
		end
	else begin
		itm.op = op_xor;
	end
	itm.randomize();
	finish_item(itm);
	end
endtask : doall
	
endclass : alu_sq
