Run the script **“M_MPPT_ALGS_PIL_SIM_V1”** first to simulate the MPPT algorithms included in the PV system model, which is provided in **“S_MPPT_ALGS_PIL_SIM_V1.”** Below are the previously presented contents of both files.

<p align="center">
  <img src="https://github.com/user-attachments/assets/b42f5856-69db-4567-ba50-4d4dd4e68895" alt="Script M_MPPT_ALGS_PIL_SIM_V1" width="1212" height="585">
  <br><em>Figure 1. Simulation script: <code>M_MPPT_ALGS_PIL_SIM_V1</code>.</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/59237380-431f-4d7d-95e0-98a725c76384" alt="PV system model S_MPPT_ALGS_PIL_SIM_V1" width="1874" height="821">
  <br><em>Figure 2. PV system model with the MPPT algorithms: <code>S_MPPT_ALGS_PIL_SIM_V1</code>.</em>
</p>

The repository also includes three MPPT controller variants prepared **for deployment on the TI C2000 F28069M board solely for execution-time (ET) measurement**.  
These Simulink models are configured for target code generation and ET profiling (e.g., GPIO toggle / CEP).  
> Note: they are **not** used for PIL validation of control performance.

- **`S_MTET_PI_MPPT_ALG_V1`** – PI-based MPPT controller configured for F28069M ET measurement.  
- **`S_MTET_PROP_MPPT_ALG_V1`** – Proportional (P) MPPT controller configured for F28069M ET measurement.  
- **`S_MTET_SF_MPPT_ALG_V1`** – State-feedback (SF) MPPT controller configured for F28069M ET measurement.  

<p align="center">
  <img src="https://github.com/user-attachments/assets/33bb444b-9533-4743-9350-47a12f15fc30" alt="F28069M ET model - PI MPPT (S_MTET_PI_MPPT_ALG_V1)" width="60%">
  <br><em>Figure 3. F28069M ET-measurement model — PI-MPPT: <code>S_MTET_PI_MPPT_ALG_V1</code>.</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/84e316da-0fb7-479b-802b-e5b7b02b04ae" alt="F28069M ET model - P MPPT (S_MTET_PROP_MPPT_ALG_V1)" width="60%">
  <br><em>Figure 4. F28069M ET-measurement model — Proportional MPPT: <code>S_MTET_PROP_MPPT_ALG_V1</code>.</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/9e5981a9-ed8c-429d-a1a2-4ae91858281f" alt="F28069M ET model - SF MPPT (S_MTET_SF_MPPT_ALG_V1)" width="60%">
  <br><em>Figure 5. F28069M ET-measurement model — State-feedback MPPT: <code>S_MTET_SF_MPPT_ALG_V1</code>.</em>
</p>









