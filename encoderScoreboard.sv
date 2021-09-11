class encoderScoreboard extends uvm_scoreboard;
`uvm_component_utils(encoderScoreboard)

encoderSequenceMessage eSM;
encoderSequenceMessageOutput eSMOut;

uvm_tlm_analysis_fifo #(encoderSequenceMessage) eSMInputFIFO;
uvm_tlm_analysis_fifo #(encoderSequenceMessageOutput) eSMOutputFIFO;

function new(string name="encoderScoreboard",uvm_component parent=null);
	super.new(name,parent); 
endfunction

function void build_phase(uvm_phase phase);
	eSMInputFIFO = new("eSMInputFIFO",this);
	eSMOutputFIFO = new("eSMOutputFIFO",this);
	
	//eSM = encoderSequenceMessage::type_id::create("eSM",this);
	//eSMOut = encoderSequenceMessageOutput::type_id::create("eSMOut",this);
endfunction: build_phase

logic RD = 0;

task run_phase(uvm_phase phase);
//Get item from input FIFO 
//Process to see if control code and if so encode accordingly and check against output
//Once done with 4 packets of control code get data and encode accordingly and check against output 
//Once a k23.7 is detected at output take the next 8 bits from data and convert to crc and encode and compare to output and 

reg [9:0] expectedControlPacketEncodedData;
reg [5:0] sixBitData;
reg [3:0] fourBitData;
reg [9:0] expectedtenBitData;
int countOfZero = 0;
int countOfOne = 0; 
bit [31:0] crcOnData;
byte unsigned crcQueue[$];
integer index0 = 0;
integer index1 = 4;
integer index2 = 5;
integer index3 = 7;
byte unsigned inputqueue[$];

forever 
begin 
	eSMInputFIFO.get(eSM);

if(eSM.datain != 'b110111100) //Uptill k28.5 there are 4 control packets and data packets so output is just encoded versions of those
begin
	if(eSM.datain[8]==1)  //if controlCode==1 then control packet so encode accordingly and check against entry in output FIFO
	begin
		expectedControlPacketEncodedData = encoderExpectedControl(eSM.datain[7:0]);
		eSMOutputFIFO.get(eSMOut);
		if(expectedControlPacketEncodedData == eSMOut.dataout)
		begin
			`uvm_info("debug",$sformatf("Packet Matches"),UVM_MEDIUM)
		end
		else 
		begin
			`uvm_info("debug",$sformatf("Packet Does Not Match"),UVM_MEDIUM) 
		end
	end 
	else //not a control packet so encode as data packet
	begin 
		sixBitData = encoderExpectedData_firstFive(eSM.datain[4:0]);
		fourBitData = 																		encoderExpectedData_secondThree(eSM.datain[7:5],eSM.datain[4:0]);
		expectedtenBitData = {fourBitData,sixBitData};

		//Logic to get RD of the encoded Data
		countOfZero = 0;
		countOfOne = 0; 
		for(int a=0; a<10; a++)
		begin
			if(expectedtenBitData[a] == 0)
			begin
				countOfZero=countOfZero+1;  
			end
		else
			begin
				countOfOne=countOfOne+1;
			end
		end 
	
		//Only if disparity is not constant then update RD or else keep it same as before 
		if(countOfOne > countOfZero)
		begin
			RD = 0 ;
		end 
		if(countOfOne < countOfZero)
		begin 
			RD = 1 ;
		end

		//Check if output data is equal to expected data
		eSMOutputFIFO.get(eSMOut);
		if(expectedtenBitData == eSMOut.dataout)
		begin
			`uvm_info("debug",$sformatf("Packet Matches"),UVM_MEDIUM)
		end
		else 
		begin
			`uvm_info("debug",$sformatf("Packet Does Not Match"),UVM_MEDIUM) 
		end

		//Since it is data packet store in queue to calculate CRC later
		crcQueue.push_back(eSM.datain[7:0]); //Pushes the calculated CRC on data packet into Queue 
		
	end
end
else if(eSM.datain == 'b110111100) //Hit the k28.5 control packet in the input FIFO. There should be no more entries in the input FIFO
begin

	//Check the next item from outputFIFO to be a k23.7 control code (encoded appropriately though) 
	sixBitData = encoderExpectedData_firstFive('b10111); //Change to k23.7 
	fourBitData = encoderExpectedData_secondThree('b111,'b10111);
	expectedtenBitData = {fourBitData,sixBitData};
	eSMOutputFIFO.get(eSMOut);
	if(expectedtenBitData == eSMOut.dataout)
	begin
		`uvm_info("debug",$sformatf("Packet Matches"),UVM_MEDIUM)
	end
	else 
	begin
		`uvm_info("debug",$sformatf("Packet Does Not Match"),UVM_MEDIUM) 
	end


	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//Take the queue of CRC and encode that data and check against output packet 
	crcOnData = CRC_calc(inputqueue);
  	for(int b=0; b <4; b++) begin 
      
      $display("crcondata %b", crcOnData);
      $display("index 0: %d", index0);
      //$display("index 0: %d index 1: %d index 2: %d index 3: %d", index0, index 1, index2, index3);
	 	//sixBitData = encoderExpectedData_firstFive(crcOnData[index1:index0]);
	 	//fourBitData = encoderExpectedData_secondThree(crcOnData[index3:index2],crcOnData[index1:index0]);
     	expectedtenBitData = {fourBitData,sixBitData};
	 	//Compare the last encoded control packet with the next packets from outputFIFO 
		 eSMOutputFIFO.get(eSMOut);
	 	if(expectedtenBitData == eSMOut.dataout)
	 	begin
			`uvm_info("debug",$sformatf("Packet Matches"),UVM_MEDIUM)
	 	end
	 	else 
	 	begin
			`uvm_info("debug",$sformatf("Packet Does Not Match"),UVM_MEDIUM) 
	 	end

	 	//Logic to get RD of the encoded Data
		 countOfZero = 0;
		 countOfOne = 0; 
		 for(int a=0; a<10; a++)
		 begin
			if(expectedtenBitData[a] == 0)
			begin
				countOfZero=countOfZero+1;  
			end
			else
			begin
				countOfOne=countOfOne+1;
			end
		 end 
	
		 //Only if disparity is not constant then update RD or else keep it same as before 
		 if(countOfOne > countOfZero)
		 begin
		 	RD = 0 ;
		 end 
		 if(countOfOne < countOfZero)
		 begin 
			RD = 1 ;
		 end 

		 index0 = index0 + 8;
		 index1 = index1 + 8;
		 index2 = index2 + 8;
		 index3 = index3 + 8;

 	end

	//Check the last entry in the outputFIFO to be a k28.5 (encoded appropriately though)
	 sixBitData = encoderExpectedData_firstFive('b11100);
	 fourBitData = encoderExpectedData_secondThree('b101,'b11100);
     expectedtenBitData = {fourBitData,sixBitData};
	 //Compare the last encoded control packet with the next packets from outputFIFO 
	 eSMOutputFIFO.get(eSMOut);
	 if(expectedtenBitData == eSMOut.dataout)
	 begin
		`uvm_info("debug",$sformatf("Packet Matches"),UVM_MEDIUM)
	 end
	 else 
	 begin
		`uvm_info("debug",$sformatf("Packet Does Not Match"),UVM_MEDIUM) 
	 end
end
end 
endtask : run_phase




int unsigned CRC32Table[256] = {
	32'h00000000, 32'h77073096, 32'hee0e612c, 32'h990951ba, 32'h076dc419, 32'h706af48f,
	32'he963a535, 32'h9e6495a3,	32'h0edb8832, 32'h79dcb8a4, 32'he0d5e91e, 32'h97d2d988,
	32'h09b64c2b, 32'h7eb17cbd, 32'he7b82d07, 32'h90bf1d91, 32'h1db71064, 32'h6ab020f2,
	32'hf3b97148, 32'h84be41de,	32'h1adad47d, 32'h6ddde4eb, 32'hf4d4b551, 32'h83d385c7,
	32'h136c9856, 32'h646ba8c0, 32'hfd62f97a, 32'h8a65c9ec,	32'h14015c4f, 32'h63066cd9,
	32'hfa0f3d63, 32'h8d080df5,	32'h3b6e20c8, 32'h4c69105e, 32'hd56041e4, 32'ha2677172,
	32'h3c03e4d1, 32'h4b04d447, 32'hd20d85fd, 32'ha50ab56b,	32'h35b5a8fa, 32'h42b2986c,
	32'hdbbbc9d6, 32'hacbcf940,	32'h32d86ce3, 32'h45df5c75, 32'hdcd60dcf, 32'habd13d59,
	32'h26d930ac, 32'h51de003a, 32'hc8d75180, 32'hbfd06116, 32'h21b4f4b5, 32'h56b3c423,
	32'hcfba9599, 32'hb8bda50f, 32'h2802b89e, 32'h5f058808, 32'hc60cd9b2, 32'hb10be924,
	32'h2f6f7c87, 32'h58684c11, 32'hc1611dab, 32'hb6662d3d,	32'h76dc4190, 32'h01db7106,
	32'h98d220bc, 32'hefd5102a, 32'h71b18589, 32'h06b6b51f, 32'h9fbfe4a5, 32'he8b8d433,
	32'h7807c9a2, 32'h0f00f934, 32'h9609a88e, 32'he10e9818, 32'h7f6a0dbb, 32'h086d3d2d,
	32'h91646c97, 32'he6635c01, 32'h6b6b51f4, 32'h1c6c6162, 32'h856530d8, 32'hf262004e,
	32'h6c0695ed, 32'h1b01a57b, 32'h8208f4c1, 32'hf50fc457, 32'h65b0d9c6, 32'h12b7e950,
	32'h8bbeb8ea, 32'hfcb9887c, 32'h62dd1ddf, 32'h15da2d49, 32'h8cd37cf3, 32'hfbd44c65,
	32'h4db26158, 32'h3ab551ce, 32'ha3bc0074, 32'hd4bb30e2, 32'h4adfa541, 32'h3dd895d7,
	32'ha4d1c46d, 32'hd3d6f4fb, 32'h4369e96a, 32'h346ed9fc, 32'had678846, 32'hda60b8d0,
	32'h44042d73, 32'h33031de5, 32'haa0a4c5f, 32'hdd0d7cc9, 32'h5005713c, 32'h270241aa,
	32'hbe0b1010, 32'hc90c2086, 32'h5768b525, 32'h206f85b3, 32'hb966d409, 32'hce61e49f,
	32'h5edef90e, 32'h29d9c998, 32'hb0d09822, 32'hc7d7a8b4, 32'h59b33d17, 32'h2eb40d81,
	32'hb7bd5c3b, 32'hc0ba6cad, 32'hedb88320, 32'h9abfb3b6, 32'h03b6e20c, 32'h74b1d29a,
	32'head54739, 32'h9dd277af, 32'h04db2615, 32'h73dc1683, 32'he3630b12, 32'h94643b84,
	32'h0d6d6a3e, 32'h7a6a5aa8, 32'he40ecf0b, 32'h9309ff9d, 32'h0a00ae27, 32'h7d079eb1,
	32'hf00f9344, 32'h8708a3d2, 32'h1e01f268, 32'h6906c2fe, 32'hf762575d, 32'h806567cb,
	32'h196c3671, 32'h6e6b06e7, 32'hfed41b76, 32'h89d32be0, 32'h10da7a5a, 32'h67dd4acc,
	32'hf9b9df6f, 32'h8ebeeff9, 32'h17b7be43, 32'h60b08ed5, 32'hd6d6a3e8, 32'ha1d1937e,
	32'h38d8c2c4, 32'h4fdff252, 32'hd1bb67f1, 32'ha6bc5767, 32'h3fb506dd, 32'h48b2364b,
	32'hd80d2bda, 32'haf0a1b4c, 32'h36034af6, 32'h41047a60, 32'hdf60efc3, 32'ha867df55,
	32'h316e8eef, 32'h4669be79, 32'hcb61b38c, 32'hbc66831a, 32'h256fd2a0, 32'h5268e236,
	32'hcc0c7795, 32'hbb0b4703, 32'h220216b9, 32'h5505262f, 32'hc5ba3bbe, 32'hb2bd0b28,
	32'h2bb45a92, 32'h5cb36a04, 32'hc2d7ffa7, 32'hb5d0cf31, 32'h2cd99e8b, 32'h5bdeae1d,
	32'h9b64c2b0, 32'hec63f226, 32'h756aa39c, 32'h026d930a, 32'h9c0906a9, 32'heb0e363f,
	32'h72076785, 32'h05005713, 32'h95bf4a82, 32'he2b87a14, 32'h7bb12bae, 32'h0cb61b38,
	32'h92d28e9b, 32'he5d5be0d, 32'h7cdcefb7, 32'h0bdbdf21, 32'h86d3d2d4, 32'hf1d4e242,
	32'h68ddb3f8, 32'h1fda836e, 32'h81be16cd, 32'hf6b9265b, 32'h6fb077e1, 32'h18b74777,
	32'h88085ae6, 32'hff0f6a70, 32'h66063bca, 32'h11010b5c, 32'h8f659eff, 32'hf862ae69,
	32'h616bffd3, 32'h166ccf45, 32'ha00ae278, 32'hd70dd2ee, 32'h4e048354, 32'h3903b3c2,
	32'ha7672661, 32'hd06016f7, 32'h4969474d, 32'h3e6e77db, 32'haed16a4a, 32'hd9d65adc,
	32'h40df0b66, 32'h37d83bf0, 32'ha9bcae53, 32'hdebb9ec5, 32'h47b2cf7f, 32'h30b5ffe9,
	32'hbdbdf21c, 32'hcabac28a, 32'h53b39330, 32'h24b4a3a6, 32'hbad03605, 32'hcdd70693,
	32'h54de5729, 32'h23d967bf, 32'hb3667a2e, 32'hc4614ab8, 32'h5d681b02, 32'h2a6f2b94,
	32'hb40bbe37, 32'hc30c8ea1, 32'h5a05df1b, 32'h2d02ef8d
};

//CRC SINGLE BYTE 
//function bit[31:0] CRC_calc(reg [7:0]q);
//   reg [31:0] CRC = 32'hFFFFFFFF;
//     reg [31:0]CRC_result;
// 	//while(q.size > 0) begin
//     bit [31:0]index;
//       index = (q ^ CRC) & 8'hFF;
// 		CRC_result = (CRC >> 8) ^ CRC32Table[index];
// 	//end
// 	return CRC_result ^ 32'hFFFFFFFF;
// endfunction : CRC_calc

//CRC ARRAY INPUT
// function bit[31:0] CRC_calc(reg [7:0] q[]);
//   	reg [31:0] CRC = 32'hFFFFFFFF;
//     reg [31:0]CRC_result;
//     int size = q.size();
//     for(int i = 0; i < size; i++) begin
//     	bit [31:0]index;
//       	index = (q ^ CRC) & 8'hFF;
// 		CRC_result = (CRC >> 8) ^ CRC32Table[index];
// 	end
// 	return CRC_result ^ 32'hFFFFFFFF;
// endfunction : CRC_calc
  
//CRC QUEUE INPUT
function bit[31:0] CRC_calc(byte unsigned q[$]);
  	reg [31:0] CRC = 32'hFFFFFFFF;
    reg [31:0]CRC_result;
  $display("CRC input queue size: %d", q.size());
    while(q.size() > 0) begin
    	bit [31:0]index;
      
     	index = (q.pop_front() ^ CRC) & 8'hFF;
      $display("Table index: %d", index);
		CRC_result = (CRC >> 8) ^ CRC32Table[index];
	end
	return CRC_result ^ 32'hFFFFFFFF;
endfunction : CRC_calc



function bit[9:0] encoderExpectedControl(reg[7:0] data);  //change return type needs to return output
//bit RD: 0 = -1 and 1 = +1
case(data)
//k28.1
'b00111100: begin
				if(RD==0)
				begin 
					return 'b0011111001;
					RD=1;	//take out assign statements
				end
				else
				begin 
					return 'b1100000110;
					RD=0;
				end 
			end 
//k23.7 
'b11110111: begin
				if(RD==0)
				begin 
					return 'b1110101000;
					RD=1;	
				end
				else
				begin 
					return 'b0001010111;
					RD=0;
				end 
			end
//k28.5 
'b10111100: begin
				if(RD==0)
				begin 
					return 'b0011111010;
					RD=1;	
				end
				else
				begin 
					return 'b1100000101;
					RD=0;
				end 
			end		

endcase
endfunction : encoderExpectedControl


//Calculate RD after combining the 6 bit and 4bit  
//bit RD: 0 = -1 and 1 = +1
function bit[5:0] encoderExpectedData_firstFive(reg[4:0] data);
case(data)
'b00000: begin  //check the orientation of the bits for the condtions A-I
				if(RD==0)
				begin 
					return 'b111001; 
				end
				else
				begin 
					return 'b000110;
				end 
		end
'b00001: begin
				if(RD==0)
				begin 
					return 'b101110; 
				end
				else
				begin 
					return 'b010001; 
				end 
		end
'b00010: begin
				if(RD==0)
				begin 
					return 'b101101; 
				end
				else
				begin 
					return 'b010010;  	
				end 
		end
'b00011: begin
				if(RD==0)
				begin 
					return 'b10011; 
				end
				else
				begin 
					return 'b10011; 
				end 
		end
'b00100: begin
				if(RD==0)
				begin 
					return 'b101011; 
				end
				else
				begin 
					return 'b010100; 	
				end 
		end
'b00101: begin
				if(RD==0)
				begin 
					return 'b100101; 	
				end
				else
				begin 
					return 'b100101; 
				end 
		end
'b00110: begin
				if(RD==0)
				begin 
					return 'b100110; 
				end
				else
				begin 
					return 'b100110; 
				end 
		end
'b00111: begin
				if(RD==0)
				begin 
					return 'b000111; 	
				end
				else
				begin 
					return 'b111000; 	
				end 
		end
'b01000: begin
				if(RD==0)
				begin 
					return 'b100111; 	
				end
				else
				begin 
					return 'b011000; 	
				end 
		end
'b01001: begin
				if(RD==0)
				begin 
					return 'b101001; 	
				end
				else
				begin 
					return 'b101001; 
				end 
		end
'b01010: begin
				if(RD==0)
				begin 
					return 'b101010; 	
				end
				else
				begin 
					return 'b101010; 
				end 
		end
'b01011: begin
				if(RD==0)
				begin 
					return 'b001011; 		
				end
				else
				begin 
					return 'b001011; 
				end 
		end
'b01100: begin
				if(RD==0)
				begin 
					return 'b101100; 			
				end
				else
				begin 
					return 'b101100; 
				end 
		end
'b01101: begin
				if(RD==0)
				begin 
					return 'b001101; 				
				end
				else
				begin 
					return 'b001101; 
				end 
		end
'b01110	: begin
				if(RD==0)
				begin 
					return 'b001110; 				
				end
				else
				begin 
					return 'b001110; 
				end 
		end
'b01111: begin
				if(RD==0)
				begin 
					return 'b111010; 				
				end
				else
				begin 
					return 'b000101; 
				end 
		end
'b10000: begin
				if(RD==0)
				begin 
					return 'b110110;					
				end
				else
				begin 
					return 'b001001;	
				end 
		end
'b10001: begin
				if(RD==0)
				begin 
					return 'b110001;						
				end
				else
				begin 
					return 'b110001;	
				end 
		end
'b10010: begin
				if(RD==0)
				begin 
					return 'b110010; 					
				end
				else
				begin 
					return 'b110010;	
				end 
		end

'b10011: begin
				if(RD==0)
				begin 
					return 'b010011; 		
				end
				else
				begin 
					return 'b010011;	
				end 
		end
'b10100: begin
				if(RD==0)
				begin 
					return 'b110100; 		
				end
				else
				begin 
					return 'b110100;	
				end 
		end
'b10101: begin  
				if(RD==0)
				begin 
					return 'b010101; 			
				end
				else
				begin 
					return 'b010101;	
				end 
		end
'b10110: begin  
				if(RD==0)
				begin 
					return 'b010110; 				
				end
				else
				begin 
					return 'b010110;	
				end 
		end
'b10111: begin  
				if(RD==0)
				begin 
					return 'b010111; 					
				end
				else
				begin 
					return 'b101000; 		
				end 
		end
'b11000: begin  
				if(RD==0)
				begin 
					return 'b110011; 						
				end
				else
				begin 
					return 'b001100;  		
				end 
		end
'b11001: begin  
				if(RD==0)
				begin 
					return 'b011001; 						
				end
				else
				begin 
					return 'b011001;  		
				end 
		end
'b11010: begin  
				if(RD==0)
				begin 
					return 'b011010; 							
				end
				else
				begin 
					return 'b011010;  			
				end 
		end
'b11011: begin  
				if(RD==0)
				begin 
					return 'b011011; 								
				end
				else
				begin 
					return 'b100100;  			
				end 
		end
'b11100: begin  
				if(RD==0)
				begin 
					return 'b011100; 							
				end
				else
				begin 
					return 'b011100;  			
				end 
		end
'b11101: begin  
				if(RD==0)
				begin 
					return 'b011101; 								
				end
				else
				begin 
					return 'b100010; 	 			
				end 
		end
'b11110: begin  
				if(RD==0)
				begin 
					return 'b011110; 									
				end
				else
				begin 
					return 'b100001; 		 			
				end 
		end
'b11111:begin  
				if(RD==0)
				begin 
					return 'b110101; 										
				end
				else
				begin 
					return 'b001010; 			 			
				end 
		end
endcase
endfunction

function bit[3:0] encoderExpectedData_secondThree(reg[2:0] data,reg[4:0] fiveBitData);
case(data)
'b000:begin  
				if(RD==0)
				begin 
					return 'b1101; 										
				end
				else
				begin 
					return 'b0010; 				 			
				end 
		end
'b001:begin  
				if(RD==0)
				begin 
					return 'b1001; 										
				end
				else
				begin 
					return 'b1001; 				 			
				end 
		end
'b010:begin  
				if(RD==0)
				begin 
					return 'b1010; 											
				end
				else
				begin 
					return 'b1010; 					 			
				end 
		end
'b011:begin  
				if(RD==0)
				begin 
					return 'b0011; 											
				end
				else
				begin 
					return 'b0011; 					 			
				end 
		end
'b100	:begin  
				if(RD==0)
				begin 
					return 'b1011; 										
				end
				else
				begin 
					return 'b0100; 						 			
				end 
		end
'b101	:begin  
				if(RD==0)
				begin 
					return 'b0101; 											
				end
				else
				begin 
					return 'b0101; 							 			
				end 
		end
'b110		:begin  
				if(RD==0)
				begin 
					return 'b0110; 											
				end
				else
				begin 
					return 'b0110; 							 			
				end 
		end
//FINISH UP 
'b111		:begin  
				if((RD==0) && ( (fiveBitData == 'd17) || (fiveBitData == 'd18) || (fiveBitData == 'd20) ) )
				begin 
					return 'b0111; 											
				end
				else if( (fiveBitData == 'd11) || (fiveBitData == 'd13) || (fiveBitData == 'd14) )
				begin 
					return 'b1000; 							 			
				end
				else if(RD==0)
				begin
					return 'b1110;	 
				end
				else 
				begin
					return 'b0001; 
				end
		end
endcase

endfunction
endclass: encoderScoreboard 
