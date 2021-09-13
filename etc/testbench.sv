`timescale 1ns/10ps
//Include files 

`include "interfaceEncoder.sv"
`include "encoderDUT.sv"

package encoderPackage;
import uvm_pkg::*;
`include "encoderSequence.sv"




`include "encoderMonitors.sv"
`include "encoderScoreboard.sv"
`include "encoderDriver.sv"
`include "encoderTest.sv"

endpackage: encoderPackage;

import uvm_pkg::*;
module top();
  
reg clk;
reg reset;
reg pushin;
reg startin;
reg [8:0]datain;
reg pushout;
reg startout;
reg [9:0]dataout;

//dut encoderdut(clk, reset, datain, startin, pushout, dataout, startout);
encoder ecd(clk);
  
initial begin 
	uvm_config_db #(virtual encoder)::set(null,"midterm","ecd",ecd);
  	$display("BEGIN----------------");
  	run_test("encoderTest");
end

initial begin
  	clk = 0;
	forever begin
		#5 clk = ~clk;
	end
end
initial begin 
	$dumpfile("dump.vcd");
	$dumpvars(9,top);
end

endmodule:top
