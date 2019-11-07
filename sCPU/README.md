# sCPU
**Introduction**

This is a demo on how to use sCPU(Sensitivities Constrained Phase Update (sCPU) for Ghost Artifacts Reduction) for ghost artifacts reduction.
Using coil sensitivities as constraints, a synthetic image can be generated in which the ghost is reduced due to phase cancelation. Phase error was first estimated from the raw image and the synthetic image, 
and then was used to update the phase of raw k-space. The simulated ghost images with linear, random phase error or both random magnitude/phase error can be effiecntly corrected after several iterations.


**How to run the demo** ?

Just run the "main.m"



Simulated Ghost Images and Correction Result

![Simulation Results](./CorrectionResults.png "Simulation Results")

Estimated Phase error at the end of last iteration

![Simulation Results](./PhaseErr.png "Estimated Phase error at the end of last iteration ")

Image at the end of each iteration

![Simulation Results](./Iterations.png "Image at the end of each iteration ")

RMSE at the end of each iteration

![Simulation Results](./RMSE.png "RMSE at the end of each iteration ")
