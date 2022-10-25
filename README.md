# KOS-Library
Library of programs and missions for KSP

# Ship Computer System
The Ship computer system uses 1 or more computers.

On the KSC Archive the folder Missions, boot, and library is avialble.
Each ship is named and should have the same named folder in the Missions folder. 
In the mission folder of the ship at minimum there should be 0.ks.

0.ks will be used by the bootsystem to startup the system.

If the system have subsystems, then each subsystem computer should be named according to the subsystem and in the ship mission folder programs named according to the subsystems is expected. 

Here is the untested part:
The boot system should copy the subsystem programs into the correct subsystem computer. But each subsystem will remain powered off.
The main system which makes use of 0.ks should control when each of the subsystems come online.

It would be nice to have a program on one of the subsystems and call a functions of it as needed, such as a diagnostic, or a normal startup. 
Meaning computer A calling a function on computer B, I am pretty sure this may be possible via the communication protocol, but not if it can be done directly. 

https://kos.fandom.com/wiki/Archive_and_Volumes

The above link explains that we can do exactly what we wanted. 
each computer have both a CPU and a HDD, and each of these HDD's are on the 'same network' (infact there is no way to isolate it). And you can SWITCH to that archive, but you need to know its name, which means that you can copy files to it, you can even run code from there. But calling a functions from another HDD, will not mean it will run on the CPU of that computer, that can only happen via the messaging system. 
But you can easily enough control other computers, by powering them on or off.




# Old Ship Computer System - Original
Boot files contained the full program, just automatically loaded.
Original Hohmann Manuver created, but never really worked.
Also build a basic launch system, but it was not very efficient either.

# Old Ship Computer System - V2
This system under went several itterations of improvement, and only the result will be documented here for brevity.

This system at its best uses a two boot system called the BootSSystem.

The initBootS.ks file is chosen during ship building and is the entry point for this system.

The initBootS.ks program performs a few basic functions.
1. It determines the ship name and compiles the mission files located in the mission folder of that ship.
2. It compiles and put the genBootS.ks boot file onto the ship.
3. It deletes itself from the ship
4. It reboots the ship computer thereby handing control over to the genBootS.ks system.

The genBootS.ks program is in reality the small operating system of the Ship which does the following:
1. It checks the state file of the ship, and make sure that the program on the ship is allinged with the state.
2. If the state file points to a different file than what is on the system, then OS will try to fetch it from KSP.
3. If the correct program is on the system then it will be run.
4. A few basic funtions is also provided by the OS:
    1. function to collect library files from the KSC archive.
    2. function to advance the state file.

This was the primary system by which the ship functioned, it basically gave the following benifits:
1. You always give the same bootfile during ship building, which cleaned up the boot folder.
2. Ship name and mission names are synced, which means that you easily know which fit with which. This is design by convention.
3. You can have more code that can fit onto the computer and have it loaded at the right time from the KSP Archive. 

Drawbacks of this system:
1. Lots of duplication between missions.
2. Making a mistake in planning may leave you in a standed situation where the ship cannot load new code.

The next major thing build during this phase was the launch system
The launch system was designed to get rockets of Kerbin, but it does not make that assumption. 
It takes velocity, acceleration, and jerk into account and use the Newton Solver to solve the equation for distance, then it use a 1-1 linear equation to get the angle the rocket has to point at. 
Throttle is always kept at maximum, but the launcher system do have throttle control as a capability, but it was found that max thrust results in least energy used. 
The launch system can get any rocket with enough TWR and Delta-V into a steep suborbital point above the Kerman line. 
It was found if the rocket have too much fuel then it will do the same thing only put it at a higher altitude.
The launch system assumes two stages.

Furthermore, it was found that the when the launch system ends there is usualy some fuel left in the second stage which can be used to help circularize, it is however never enough, and thus upon ejection the second stage will crash in the ocoan. 

Issues with the launch system:
1. Feedback is not great.
2. It does not realize when it is failing, due to whatever situation. 
3. No abort system.
4. It does not calculate if it can reach its target.
5. Cannot launch into a different orbit than equatorial.

The last system build during this phase was Mun transition system
1. We got it working to do a transition to Mun, but this system was not refined at all and still need alot of work.


# Ship Computer System V3

The bootstrap.ks file is chosen during ship building and is the entry point for this system.

The bootstrap.ks program performs a few basic functions.
1. It determines the ship name and compiles the mission files located in the mission folder of that ship.
2. It sets up ship programs:
    2.1. It compiles and put the OS.ks boot file onto the ship.
    2.2. It checks for other computers on the ship, and copies the files from the mission folder with the same name to those computers.
3. It deletes itself from the ship
4. It reboots the ship computer thereby handing control over to the OS.

The OS.ks program is the small operating system of the Ship which does the following:
1. It checks the state file of the ship, and make sure that the program on the ship is alligned with the state.
2. If the state file points to a different file than what is on the system, then OS will try to fetch it from KSP.
3. If the correct program is on the system then it will be run.
4. A few basic funtions is also provided by the OS:
    1. function to collect library files from the KSC archive.
    2. function to advance the state file.


This is the primary system by which the ship functions, it basically gives the following benifits:
1. You always give the same bootfile during ship building, which cleans up the boot folder.
2. Ship name and mission names are synced, which means that you easily know which fit with which. This is design by convention.
3. You can have more code that can fit onto the computer and have it loaded at the right time from the KSP Archive. 
4. Subsystems are also linked name-program and is automatically loaded.

Drawbacks of this system:
1. All the same drawbacks of V2.


Additional Conventions for V3:
1. The computer with the OS on it is considered the primary computer of the ship, and should physically be located as close as possible to the command module of the ship. 
2. The primary computer need not be named.
3. All secondary computers should be named according to their function, such as Launch.
4. Secondary computers should never start themselves. (maybe there may be a reason for that, but I can't think of one now)
5. The Primary computer will start the secondary computers when they are needed.
6. Secondary computers should be as far as possible be fully self contained and have a single overall function. 
7. Secondary computers should be physically located as close to the system its controlling as possible.
8. When a secondary computer has completed its function it should power itself off so save energy.
9. Verbose output is of greater value than saving energy, and thus verbose output is highly encouraged. (This is one of the main reasons we want seperate computers, to allow for more text based output).
10. The primary computer program series 0,1,2,.... should in essence contain the full mission. 
11. As much as possible of the executable methods of missions should be extracted into library files, to minimize duplication of mission files, however duplication is still expected.
12. Each mission must have a readme.md file which describes the mission, its goals, some information about the mission, and status upon completion. 
13. If it is not documented then it is not done.