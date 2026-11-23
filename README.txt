RV32I SINGLE-CYCLE PROCESSOR - MODELSIM PROJECT

Files:
- ProgramCounter.v          Program Counter
- InstructionMemory.v       Instruction Memory
- RegisterFile.v            Register File
- ImmediateGenerator.v      Immediate Generator
- BranchComparator.v        Branch Comparator
- ALU.v                     Arithmetic Logic Unit
- ControlUnit.v             Control Unit
- data_memory.v             Lab 11 standalone 1024 x 32 Data Memory interface
- DataMemory.v              Processor byte/half-word/word Data Memory
- RV32I_Processor.v         Top-level processor integration
- RV32I_Processor_tb.v      Testbench
- run_simulation.do         ModelSim compile-and-run script

HOW TO RUN:
1. Extract this ZIP file.
2. Open ModelSim and change directory to the extracted folder.
3. In Transcript, enter: do run_simulation.do
4. The testbench prints expected and actual register/memory values.
5. Top-level module is RV32I_Processor.
6. Testbench top is RV32I_Processor_tb.

IMPORTANT:
All .v files are separate source files but are compiled together into the
same ModelSim work library. Do not compile only RV32I_Processor.v by itself;
it instantiates the other modules.
