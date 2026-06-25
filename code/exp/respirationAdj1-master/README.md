## respirationAdj1: List of Requirements

---

### Experiment

#### Hardware

- Digitimer DS5 (electrical stimulation)
  - Manual: https://www.digitimer.com/product/human-neurophysiology/peripheral-stimulators/ds5-isolated-bipolar-constant-current-stimulator/ 
  - Stimulation intensity relates to adjusted voltage and current (e.g., 10V:10mA, signal of 5 relates to 5 mA)
  - DS5 current and voltage output have to multiplied by 10 (1V signal equals 10mA resp. 10V)
  - If input positive, then red output is positive, so current flows from black to red
- National Instruments NI USB-6343 (DAQ card)
  - Manual: https://www.ni.com/en-us/support/model.usb-6343.html
- Ring electrodes (Digital Ring Electrodes, Digitimer; https://www.digitimer.com/product/human-neurophysiology/neurodiagnostic-accessories/nerve-conduct-study-ncs/digital-ring-electrodes/#downloads)
- Parallel port for binary button response box
- Binary button response box

#### Software

- Windows 10
- MATLAB 64-bit [R2020a Update 3 (9.8.0.1396136)]
- MATLAB Toolboxes
  - Data Acquisition Toolbox v4.1 (http://de.mathworks.com/products/daq/)
  - Psychtoolbox v3.0.19 (http://psychtoolbox.org)
  - GStreamer 1.0
  - Palamedes Toolbox 1.9.0 (http://palamedestoolbox.org) [included in the repository]
  - Mex-file plug-in for MATLAB port I/O access on 64-bit Windows (http://apps.usd.edu/coglab/psyc770/IO32on64.html)
  
---

### Recording

#### Hardware

- 64-Channel EEG System (NeurOne, Bittium, Oulu, Finland) [Ground = POz, Ref = FCz]
  - NeurOne Jackbox (VP00477; SN JB2016058, SN JB2016055)
  - NeurOne Amplifier (VP00430; SN MRI2017147B, SN MRI2017146B)
- 2 single electrodes: (1) ECG, (2) EOG
- Breath sensor 3-way 1-channel (Respiration flow sensor; R74-1401 / EAN 07290008986083; GVB-geliMED GmbH, Bad Segeberg, Germany)
  - https://gvb-gelimed.de/en/breath-sensor-3-way-1-channel/r74-1401-bp
- ~~Reusable Respiratory Effort Sensor (Respiration Belt; RESPA00000; Spes-Medica, Genova, Italy):~~
  - ~~https://www.spesmedica.com/wp-content/uploads/2019/06/STC_-_REUSABLE_RESPIRATORY_EFFORT_SENSORS.pdf~~

### Software

- Windows 10
- NeurOne x64 (Version 1.4.1.64)
- Electrode Digitization
  - Matlab (R2007b, Version 7.5.0)
  - Brainstorm 3.2 (Version 3.2.140303)

---

### Consumables

- EEG electrode preparation (in descending order):
  - [1] disinfectant
  - [2] default: High-chloride abrasive electrolyte gel (EasyCap GmbH, Abralyt HiCl, 1000g); for individuals with sensitive skin / allergics: Abrasive electrolyte gel salt-free & hypoallergenic (EasyCap GmbH, Abralyt 2000, 1000g)
  - [3] fluid top-up (Electro-gel; Electro-Cap International, Inc., Eaton, Ohio, USA)
  - Cotton sticks # for [1]
  - Syringes with blunted needles (16G/1.6 mm) # for [2-3]
  - Alcohol swabs # to clean skin for EOG/ECG positions
  - Towels (shoulder-covering, hair-washing)
- Breathing Control
  - Nose clips (Farla Medical)
  - Tape over closed lips (Leukosilk®)
- Ring electrode gel
  - Electrolyte gel (Signa gel, Electrode Gel, Parker Laboratories, Inc.)
- Earplugs (uvex x-fit, SNR 37 dB; 2112.001 / EAN 4031101312750; Uvex Arbeitsschutz GmbH, Fuerth, Germany)

---


