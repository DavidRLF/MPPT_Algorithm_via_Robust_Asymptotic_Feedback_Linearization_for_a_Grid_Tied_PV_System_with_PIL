Run the script **`M_MPPT_ALGS_PIL_SIM_V1`** first to simulate the MPPT algorithms included in the PV system model, which is provided in **`S_MPPT_ALGS_PIL_SIM_V1`**. **Both models can also run without PIL**—use Simulink’s *Normal* or *Accelerator* simulation modes on the host. PIL on **F28M35x** is optional and documented below.

<p align="center">
  <img src="https://github.com/user-attachments/assets/b42f5856-69db-4567-ba50-4d4dd4e68895" alt="Script M_MPPT_ALGS_PIL_SIM_V1" width="80%">
  <br><em>Figure 1. Simulation script: <code>M_MPPT_ALGS_PIL_SIM_V1</code>.</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/59237380-431f-4d7d-95e0-98a725c76384" alt="PV system model S_MPPT_ALGS_PIL_SIM_V1" width="80%">
  <br><em>Figure 2. PV system model with the MPPT algorithms: <code>S_MPPT_ALGS_PIL_SIM_V1</code>.</em>
</p>


---

## Quick guide: running PIL (on **F28M35x**)

1) **Parameter configuration**
<p align="center">
  <img src="https://github.com/user-attachments/assets/5163501f-b6bf-4e13-9492-b32216704bb3" alt="Parameter configuration" width="40%">
  <br><em>Figure 3. Simulation / code generation parameters.</em>
</p>

2) **Hardware Implementation – Build options (F28M35x)**
<p align="center">
  <img src="https://github.com/user-attachments/assets/a2360c73-3b51-4758-8866-b833ca7ffee5" alt="Hardware Implementation build options" width="60%">
  <br><em>Figure 4. Hardware Implementation (Build options) for F28M35x.</em>
</p>

3) **Hardware Implementation – PIL options (F28M35x)**
<p align="center">
  <img src="https://github.com/user-attachments/assets/0716347f-9dd1-45c4-8be4-c0e40deff673" alt="Hardware Implementation PIL options" width="60%">
  <br><em>Figure 5. Hardware Implementation (PIL options) for F28M35x.</em>
</p>

4) **Deploy the subsystem to hardware (F28M35x)**  
Right-click the subsystem to be converted and choose **“Deploy this Subsystem to Hardware.”** Ensure the **F28M35x** board is connected to the **serial port** as shown.
<p align="center">
  <img src="https://github.com/user-attachments/assets/dc92e7fe-092d-4e3d-abdc-cae42df88e86" alt="Deploy this Subsystem to Hardware" width="60%">
  <br><em>Figure 6. Deploying the subsystem to hardware (F28M35x).</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/80805555-4ff9-405d-9ba3-b99fad9fb626" alt="Board connected to serial port" width="60%">
  <br><em>Figure 7. F28M35x board connected to the serial port.</em>
</p>

5) **Build the subsystem**
<p align="center">
  <img src="https://github.com/user-attachments/assets/24ccb47f-59d4-4032-85f5-0b9492d56bbf" alt="Build button" width="60%">
  <br><em>Figure 8. Click <strong>Build</strong>.</em>
</p>

6) **Check the Diagnostic Viewer**  
At the end, the Diagnostic Viewer should show a successful build.
<p align="center">
  <img src="https://github.com/user-attachments/assets/9e53b30a-c050-4f2c-bcca-e068d5e155a9" alt="Diagnostic Viewer successful build" width="60%">
  <br><em>Figure 9. Successful build in Diagnostic Viewer (PIL target: F28M35x).</em>
</p>

7) **Insert the generated PIL block into the main model**  
The PIL block of the MPPT algorithm is generated in a separate file. Copy–paste and connect it into the main model as indicated.
<p align="center">
  <img src="https://github.com/user-attachments/assets/13b0aa65-74c6-4216-aadf-ac2aea363006" alt="Generated PIL block file" width="60%">
  <br><em>Figure 10. Generated PIL block (separate file).</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/6e1fd494-705f-41de-8e74-1d0b767dac7b" alt="Connecting PIL block 1" width="45%">
  <br><em>Figure 11. Connecting the PIL block (view 1).</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/fcb68232-0445-4b0a-9db4-53555de2c05d" alt="Connecting PIL block 2" width="45%">
  <br><em>Figure 12. Connecting the PIL block (view 2).</em>
</p>

8) **Start the PIL simulation**  
Press the **Run** button (highlighted in green).
<p align="center">
  <img src="https://github.com/user-attachments/assets/a1cedb0f-92d3-4fa3-82e9-780e6e7024ec" alt="Run button highlighted" width="60%">
  <br><em>Figure 13. Start simulation (PIL running on F28M35x).</em>
</p>

9) **Verify the Diagnostic Viewer**  
The Diagnostic Viewer should confirm that **PIL is running on F28M35x**.
<p align="center">
  <img src="https://github.com/user-attachments/assets/fbf9fb17-63ec-4fe8-accb-d0b641d47bb2" alt="Diagnostic Viewer PIL running" width="60%">
  <br><em>Figure 14. PIL execution status.</em>
</p>

10) **Board LEDs**  
The F28M35x development board should indicate communication via its LEDs (pattern depends on board revision).
<p align="center">
  <img src="https://github.com/user-attachments/assets/c75302d2-a046-46f2-8310-12dc6769f72a" alt="Board LEDs during communication" width="35%">
  <br><em>Figure 15. Communication indicators on the F28M35x board.</em>
</p>

11) **PIL simulation in progress**  
You should now see the simulation running in PIL mode. Verify the measurements in **blocks A and B**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/e3ee886b-004a-491c-9d64-73433514252e" alt="PIL simulation in progress — monitor blocks A and B" width="80%">
  <br><em>Figure 16. PIL simulation in progress — monitor blocks A and B.</em>
</p>




---

## ET-only builds (on **F28069M**)

The repository also includes three MPPT controller variants prepared **for deployment on the TI C2000 F28069M board solely for execution-time (ET) measurement**.  
These Simulink models are configured for target code generation and ET profiling (e.g., GPIO toggle / CEP).  
> Note: they are **not** used for PIL validation of control performance (PIL runs on **F28M35x**).

- **`S_MTET_PI_MPPT_ALG_V1`** – PI-based MPPT controller configured for F28069M ET measurement.  
- **`S_MTET_PROP_MPPT_ALG_V1`** – Proportional (P) MPPT controller configured for F28069M ET measurement.  
- **`S_MTET_SF_MPPT_ALG_V1`** – State-feedback (SF) MPPT controller configured for F28069M ET measurement.  

<p align="center">
  <img src="https://github.com/user-attachments/assets/33bb444b-9533-4743-9350-47a12f15fc30" alt="F28069M ET model - PI MPPT (S_MTET_PI_MPPT_ALG_V1)" width="60%">
  <br><em>Figure 16. F28069M ET-measurement model — PI-MPPT: <code>S_MTET_PI_MPPT_ALG_V1</code>.</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/84e316da-0fb7-479b-802b-e5b7b02b04ae" alt="F28069M ET model - P MPPT (S_MTET_PROP_MPPT_ALG_V1)" width="60%">
  <br><em>Figure 17. F28069M ET-measurement model — Proportional MPPT: <code>S_MTET_PROP_MPPT_ALG_V1</code>.</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/9e5981a9-ed8c-429d-a1a2-4ae91858281f" alt="F28069M ET model - SF MPPT (S_MTET_SF_MPPT_ALG_V1)" width="60%">
  <br><em>Figure 18. F28069M ET-measurement model — State-feedback MPPT: <code>S_MTET_SF_MPPT_ALG_V1</code>.</em>
</p>

---

---

## Quick guide: execution-time measurement (on **F28069M**)
Two on-board ET measurement methods are supported:  
**(1) Block Prioritization (BP)** via GPIO toggling + oscilloscope, and  
**(2) Code Execution Profiling (CEP)** via profiling instrumentation and report.  
**The steps below correspond to BP.** A separate subsection can be added for CEP.

### Method 1 — Block Prioritization (BP)

1) **Hardware Implementation — parameter setup (F28069M)**
<p align="center">
  <img src="https://github.com/user-attachments/assets/8610ef5d-0ed5-4594-8a43-ab4cd2e4c117" alt="F28069M Hardware Implementation parameters" width="60%">
  <br><em>Figure 19. Hardware Implementation parameters for execution-time (ET) builds on F28069M.</em>
</p>

2) **Deploy to Hardware**
Click the **Deploy to Hardware** button (red-circled in the toolbar) and ensure the board is connected to the correct serial/COM port.
<p align="center">
  <img src="https://github.com/user-attachments/assets/24d84d2b-8fbb-4b15-9f43-e9022936ae44" alt="Deploy to Hardware button" width="50%">
  <br><em>Figure 20. Deploy to Hardware button.</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/3e35d557-ef43-4a8e-960f-2de5b048e5ad" alt="Board connected to serial port" width="60%">
  <br><em>Figure 21. F28069M board connected to the serial/COM port.</em>
</p>

3) **Check the Diagnostic Viewer**
At the end of the build, the **Diagnostic Viewer** should report a successful deployment.
<p align="center">
  <img src="https://github.com/user-attachments/assets/2d7ccba5-b627-46cc-990c-cf15e5a483c3" alt="Diagnostic Viewer successful ET build" width="60%">
  <br><em>Figure 22. Successful ET build in Diagnostic Viewer (F28069M).</em>
</p>

4) **Program running — oscilloscope verification**
The program should now be executing on the board. In the example below, the **blue** trace measures the **PWM output**, and the **yellow** trace measures the **execution time** using the BP (GPIO toggle) method.
<p align="center">
  <img src="https://github.com/user-attachments/assets/d3523221-74c5-42f8-95fc-5950e2db1419" alt="Oscilloscope signals: PWM (blue) and execution time (yellow)" width="65%">
  <br><em>Figure 23. On-board ET measurement (BP): PWM (blue) and execution time (yellow).</em>
</p>

### Method 2 — Code Execution Profiling (CEP)

- **Repeat the BP build & deploy steps** on **F28069M**.  
- In Simulink, enable **Code Execution Profiling** in *Hardware Implementation → Code profiling / Instrumentation*.

1) **Get profiling data from the target**
```matlab
codertarget.profile.getData('S_MTET_PROP_MPPT_ALG_V1')
```
<p align="center">
  <img src="https://github.com/user-attachments/assets/1c0339d5-cb72-4e55-a614-5baac7f38b2e" alt="MATLAB command to get CEP data" width="50%">
  <br><em>Figure 24. Retrieving CEP data with <code>codertarget.profile.getData(...)</code>.</em>
</p>

2) **Confirm data availability**
<p align="center">
  <img src="https://github.com/user-attachments/assets/4d648a7c-b102-4397-9c7f-66b34ad6d5dc" alt="CEP data availability message" width="50%">
  <br><em>Figure 25. CEP data availability message.</em>
</p>

3) **Open the CEP report**
```matlab
report(ans)
```
<p align="center">
  <img src="https://github.com/user-attachments/assets/ebf8a1a2-d932-44a9-a09f-5881ae031011" alt="Open CEP report from MATLAB" width="60%">
  <br><em>Figure 26. Opening the Code Execution Profiling report.</em>
</p>

4) **Interpret the report (ET)**  
The **execution time (ET)** is shown in the **red** field; multiply it by the **time base** in the **green** field to obtain ET in seconds.
<p align="center">
  <img src="https://github.com/user-attachments/assets/8c6cce98-cab7-48d0-bb3e-a1d12e771492" alt="CEP report with execution time and time base" width="75%">
  <br><em>Figure 27. CEP report — execution time (red) and time base (green).</em>
</p>























