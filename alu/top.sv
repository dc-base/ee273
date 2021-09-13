`timescale 1ns/10ps

package alu_c;
import uvm_pkg::*;
`include "alu_i.sv"
`include "alu_sq.sv"
`include "alu_seqr.sv"
`include "alu_drv.sv"
`include "alu_t.sv"


endpackage : alu_c


import uvm_pkg::*;

module top();

initial begin
	run_test("alu_t");
end

endmodule : top

