
MicroCore Labs – Lockstep Quad Modular Redundant System


Description:
------------
Implementation of a Lockstep Quad Modular Redundant System using four MCL51's which are microsequencer-based 8051 CPU cores.

Please see the Application Note in the Documents directory for detailed information on this project.


Highlights:
-----------
- Four MCL51 modules running in Lock Step
- Four Voters - one per module
- All 8051 CPU register and peripheral accesses are broadcast to neighgboring modules.
- Modules are constantly broadcasting Microcode, Registers, User RAM, and Program ROM contents to neighboring cores.
- If a Module's Voter detects a discrepancy, it puts module into Rebuild Mode.
- While in Rebuild Mode the Module listens to neighbor core broadcasts and updates his resources accordingly.
- Once a number of iterations of the complete broadcast cycle have complete, the module rejoins the Lock Step at the beginning of the next instruction.
- The time from detecting a failure to rebuilding the module and rejoining the Lock Step is around 800uS for the example design.
- Peripherals such as UARTs and Timers chose which module results to use based on the Module's Voter.
- Modules failing, rebuilding, and rejoining the Lock Step is undetectable by the downstream peripherals and the other modules. 
- Healthy Modules are not actively involved with rebuilding failed modules and program execution proceeds unaffected and unnoticed by module failures.
- Module cannot rejoin the lockstep while an interrupt is in progress because of the interrupt_flag

 When Voter detects a failure:
- The Module is put into rebuild mode where it listens to RAM, microcore, and register broadcasts from healthy modules.
- The Lockstep's broadcasts are copied to the Rebuilding Module's local resources.
- The Rebuilding Module will listen for a duration of to two address wrap-arounds to ensure that all memories are updated.
- After this, the module waits for a SYNC pulse so it can then rejoin the lockstep.


Notes:
------
Run Levels:  Each of the four modules contains a run_level signal that indicates its "health"

run_level 	0 = Rebuild running - Gate the BROADCAST_OK signal. Look for 3 address passes
			1 = Rebuilding is done - Waiting for SYNC
			2 = Switch from listening to Broadcast Mode
			3 = Rejoined Lockstep - ungate the BROADCAST_OK voter - Final Mode

