class encoderSequenceItem extends uvm_sequence_item;
    `uvm_object_utils(encoderSequenceItem)

     rand bit [7:0] data;
 
     function new(string name = "encoderSequenceItem");
          super.new(name);
     endfunction: new
endclass: encoderSequenceItem



class encoderSequenceMessage; 
	reg [8:0] datain;  
endclass: encoderSequenceMessage



class encoderSequenceMessageOutput;
	reg [9:0] dataout;
endclass: encoderSequenceMessageOutput



class encoderSequence extends uvm_sequence#(encoderSequenceItem);
`uvm_object_utils(encoderSequence);
encoderSequenceItem encoderSI;

function new(string name="encoderSequence");
	super.new(name);
endfunction: new

task body();
	encoderSI=encoderSequenceItem::type_id::create("encoderSI");
	repeat(1) begin 
		start_item(encoderSI);
		encoderSI.randomize();   //put constraint so when control code=0 then randomize 
		finish_item(encoderSI);
	end
	$display("1 Patttern Done.");	
endtask: body
endclass: encoderSequence



class encoderSequencer extends uvm_sequencer#(encoderSequenceItem);
`uvm_component_utils(encoderSequencer)
function new(string name="encoderSequencer",uvm_component parent=null);
	super.new(name,parent);
endfunction 
endclass: encoderSequencer
