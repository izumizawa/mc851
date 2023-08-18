// Instruction Fetch stage.
// modules = ["PC", "Instruction Memory"]

module PC(nextInstruction, currentInstruction, reset, clock, load);
	input reset, clock, load;
    input [31:0] nextInstruction;
	output reg [31:0]  currentInstruction;

    always @(posedge clock) 
    begin
    	if (reset == 1)
    	begin
    		currentInstruction <= 32'b0;
    	end
    	else
    	begin
			if (load == 1) 
            begin
				currentInstruction <= nextInstruction;
			end
    	end
    end
