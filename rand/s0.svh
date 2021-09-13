// class s0 template

class s0 extends uvm_sequence #(itm) ; //itm is defined in defs.svh
  `uvm_object_utils(s0)

itm mx;
int num;
int num2;

   function new(string name="s0");
      super.new(name);
   endfunction : new

   task doreset(input int nr);
     repeat(nr) begin
       start_item(mx);
       mx.opcode=E_reset;
       mx.randomize();
       finish_item(mx);
     end
   endtask : doreset
   
   task donop(input int nr);
     repeat(nr) begin
       start_item(mx);
       mx.opcode=E_nop;
       mx.randomize();
       finish_item(mx);
     end
   endtask : donop
   
   task dopush(input int nr);
     repeat(nr) begin
       start_item(mx); //initiate operation of mx
       mx.opcode = E_push;
       mx.randomize();
       finish_item(mx);
     end
   endtask : dopush
   
   task docomplete(input int nr);
     repeat(nr) begin
       start_item(mx); //initiate operation of mx
       mx.opcode = E_pushcomplete;
       mx.randomize();
       finish_item(mx);
     end
   endtask : docomplete
   
// A sequence body template. put tests there
   task body;
     mx=itm::type_id::create("seq_item");
     doreset(3);
     donop(3);
// Put your stuff here...
	
	/*
	//test 1, cycle of commands
	repeat(10000) begin;
		num = $urandom_range(0,3);
		num2 = $urandom_range(1,10);
		//$display("%0d", num);
		case (num) 
		0: doreset(3);
		1: donop(1);
		2: dopush(num2);
		3: docomplete(num2);
       default: doreset(1);
       endcase
    end
    */
    
    //combo
    repeat(10000) begin;
		num = $urandom_range(0,2);
		//$display("%0d", num);
		case (num) 
		0: donop(1);
		1: dopush(1);
		2: docomplete(1);
       default: donop(1);
       endcase
    end
    //spam complete (see if properly nested)
    repeat(1000) begin;
		docomplete(1);
    end
    //spam push
    repeat(1000) begin;
		dopush(1);
    end
    //only push and complete
    repeat(1000) begin;
	num = $urandom_range(0,1);
	//$display("%0d", num);
	if (!num) begin
		dopush(1);
		end
	else begin
		docomplete(1);
		end
    end



		
//
   endtask : body
   
endclass : s0
