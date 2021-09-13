
//
//
`timescale 1ns/10ps


package patel;
import uvm_pkg::*;

class liz extends uvm_scoreboard;
    `uvm_component_utils(liz)
    uvm_analysis_port #(reg[3:0]) byebye;
    uvm_analysis_port #(reg[3:0]) ohno;
    
    function new(string name="liz",uvm_component par=null);
        super.new(name,par);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        $display("It's happy time, I'm building liz's children");
        byebye=new("liz_port",this);
        ohno=new("ohno",this);
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
        fork
            for( reg [3:0] bob = 0; bob < 15; bob += 1) begin
                byebye.write(bob);
                #2;
            end
            for( reg [3:0] bobby=0; bobby < 15; bobby+=1) begin
                ohno.write(bobby+3);
                #0.3ns;
            end
        join
    endtask : run_phase

endclass : liz

class rachel extends uvm_scoreboard;
    `uvm_component_utils(rachel)
    uvm_tlm_analysis_fifo #(reg[3:0]) tome;

    function new(string name="rachel",uvm_component par=null);
        super.new(name,par);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        $display("Hi, My name is Rachel");
        tome=new("tome",this);
    endfunction : build_phase
    
    function void write(input reg[3:0] dat);
        `uvm_info("fun",$sformatf("I got %h",dat),UVM_MEDIUM)
    
    endfunction : write
    
    reg [3:0] q;
    
    task run_phase(uvm_phase phase);
        forever begin
            tome.get(q);
            `uvm_info("loop",$sformatf("rach %h",q),UVM_MEDIUM)
            #10;
        end
    endtask : run_phase

endclass : rachel

class rick extends uvm_scoreboard;
    `uvm_component_utils(rick)
    uvm_analysis_imp #(reg[3:0],rick) tome;

    function new(string name="rick",uvm_component par=null);
        super.new(name,par);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        $display("Hi, My name is Rick");
        tome=new("tome",this);
    endfunction : build_phase
    
    function void write(input reg[3:0] dat);
        `uvm_info("fun",$sformatf("rick got %h",dat),UVM_MEDIUM)
    
    endfunction : write

endclass : rick

class morty extends uvm_scoreboard;
    `uvm_component_utils(morty)
    uvm_analysis_port #(reg[3:0]) tome;
    uvm_analysis_export #(reg[3:0]) fromme;

    function new(string name="morty",uvm_component par=null);
        super.new(name,par);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        $display("Hi, My name is morty");
        tome=new("tome",this);
        fromme=new("fromme",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        tome.connect(fromme);
    endfunction : connect_phase

endclass : morty


class mytest extends uvm_test;
    `uvm_component_utils(mytest)
    
    liz l;
    rachel r;
    rick rk;
    morty mt;
    
    function new(string name="Me",uvm_component parent=null);
        super.new(name,parent);
        
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        $display("Building the test");
        l = liz::type_id::create("liz",this);
        r = rachel::type_id::create("rachel",this);
        rk = rick::type_id::create("rick",this);
        mt = morty::type_id::create("morty",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        l.byebye.connect(r.tome.analysis_export);
        l.byebye.connect(mt.tome);
        mt.fromme.connect(rk.tome);
        l.ohno.connect(r.tome.analysis_export);
    endfunction : connect_phase
    
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this,"I like UVM");
        #30;
        phase.drop_objection(this,"I'm done now");
    endtask : run_phase

endclass : mytest


endpackage : patel


import uvm_pkg::*;

module top();

reg clk;

initial begin
    #5;
    repeat(100) begin
        #5 clk=1;
        #5 clk=0;
    end
    $display("\n\n\nMorris, you ran out of clocks. Fix your life\n\n\n");
    $finish;
end

initial begin
    run_test("mytest");
end





endmodule : top
