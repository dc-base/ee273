
//
//
`timescale 1ns/10ps

interface bob(input reg clk);
    reg reset;
    reg [7:0] a,b,z;
    reg ci;
    reg co;
    
endinterface : bob

package patel;
import uvm_pkg::*;

class mymessage extends uvm_sequence_item;
    `uvm_object_utils(mymessage)
    
    rand reg [7:0] a,b;
    rand reg ci;
    function new(string name="me-message");
        super.new(name);
    endfunction : new

endclass : mymessage


class mydriver extends uvm_driver #(mymessage);
    `uvm_component_utils(mydriver)
    
    virtual bob b;
    mymessage me;
    
    function new(string name="me-driving them to sleep",uvm_component jill=null);
        super.new(name,jill);
    endfunction : new

    function void connect_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual bob)::get(null, "*",
        "bob_if", this.b)) begin
          `uvm_error("connect", "bob not found")
         end 
    endfunction: connect_phase;
    
    task run_phase(uvm_phase phase);
        repeat(5) @(posedge(b.clk)) #1;
        forever begin
            seq_item_port.get_next_item(me);
            b.a <= me.a;
            b.b <= me.b;
            b.ci <= me.ci;
            @(posedge(b.clk)) #1;
            seq_item_port.item_done();
        end
    endtask : run_phase

endclass : mydriver

class myseqr extends uvm_sequencer #(mymessage);
    `uvm_component_utils(myseqr)
    
    function new(string name="jilly",uvm_component par=null);
        super.new(name,par);
    endfunction : new
    
endclass : myseqr

class seq_test extends uvm_sequence #(mymessage);
    `uvm_object_utils(seq_test)
    mymessage m1;
    
    function new(string name="hi");
        super.new(name);
    endfunction : new
    
    task body;
        m1=mymessage::type_id::create("m1");
        repeat(1000) begin
            start_item(m1);
            m1.randomize() with { ci==1; a== ~b; };
            finish_item(m1);
        end
        repeat(1000) begin
            start_item(m1);
            m1.randomize() with { (a+b+ci)== 9'h42; };
            finish_item(m1);
        end
    endtask : body

endclass : seq_test

class mytest extends uvm_test;
    `uvm_component_utils(mytest)
    
    mydriver d1;
    myseqr seq1;
    
    seq_test t0;
    
    function new(string name="Me",uvm_component parent=null);
        super.new(name,parent);
        
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        d1= mydriver::type_id::create("driver1",this);
        seq1 = myseqr::type_id::create("julie",this);
        
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        d1.seq_item_port.connect(seq1.seq_item_export);
    
    endfunction : connect_phase
    
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this,"I like UVM");
        t0 = seq_test::type_id::create("a test");
        t0.start(seq1);
        phase.drop_objection(this,"I'm done now");
    endtask : run_phase

endclass : mytest


endpackage : patel


import uvm_pkg::*;

module top();

reg clk;

bob b(clk);

initial begin
    #5;
    repeat(10000) begin
        #5 clk=1;
        #5 clk=0;
    end
    $display("\n\n\nMorris, you ran out of clocks. Fix your life\n\n\n");
    $finish;
end

initial begin
    b.reset=1;
    repeat(3) @(posedge(clk));
    b.reset=0;
end


initial begin
    uvm_config_db #(virtual bob)::set(null, "*", "bob_if" , b);
    run_test("mytest");
end

initial begin
    $dumpfile("fun.vpd");
    $dumpvars(9,top);
end

endmodule : top
