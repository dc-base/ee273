// This is a fun test

//= = = = = = = = =
class A extends uvm_scoreboard;
`uvm_component_utils(A)
uvm_analysis_port #(int) msg;
int qqq;

function new(string name="A",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	msg=new("Amsg",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	qqq=0;
	phase.raise_objection(this);
	repeat(10) begin
		#1;
		msg.write(qqq);
		qqq+=1;
	end
	phase.drop_objection(this);
endtask : run_phase

endclass : A

//= = = = = = = = = =
class B extends uvm_scoreboard;
`uvm_component_utils(B)
uvm_analysis_imp #(int,B) msg;

function new(string name="B",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	msg=new("Bmsg",this);
endfunction : build_phase

function void write(int q);
	`uvm_info("silly",$sformatf("Good message stuff %03d",q),UVM_MEDIUM);
endfunction : write

endclass : B

//= = = = = = = = = =
class C extends uvm_scoreboard;
`uvm_component_utils(C)
uvm_analysis_imp #(int,C) msg;

function new(string name="C",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	msg=new("Cmsg",this);
endfunction : build_phase

function void write(int q);
	if ( (q%3)==0 ) begin
		`uvm_info("silly",$sformatf("Happy, Happy, divisible by 3 %03d",q),UVM_MEDIUM);
	end
endfunction : write

endclass : C


//= = = = = = = = = =
class mytest extends uvm_test;
`uvm_component_utils(mytest)
A boxa;
A boxa1;
B boxb;
B boxb1;
B boxc;
C div3;

function new(string name="mytest",uvm_component parent=null);
	super.new(name,parent);

endfunction : new

function void build_phase(uvm_phase phase);
	boxa=A::type_id::create("boxa",this);
	boxb=B::type_id::create("boxb",this);
	boxa1=A::type_id::create("Daron",this);
	boxb1=B::type_id::create("VinJin",this);
	boxc=B::type_id::create("boxc",this);
	div3=C::type_id::create("div3",this);
endfunction : build_phase

function void connect_phase(uvm_phase phase);
	boxa.msg.connect(boxb.msg);
	boxa1.msg.connect(boxb1.msg);
	boxa.msg.connect(boxc.msg);
	boxa.msg.connect(div3.msg);
endfunction : connect_phase


endclass : mytest
