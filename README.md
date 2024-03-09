# EE2026_FPGA_Project (in-lab)
This project is part of National University of Singapore's EE2026 Digital Design, using Verilog HDL to program a FPGA (Digilent Basys3)

> [!IMPORTANT]
> This branch contains archived project for in-lab deliverables (Basic Tasks are not included in this branch).

## Contents of Repo
Contents in Archived Project

- Top_Student.v (clean slate to get started for basic tasks)
- project_lab.v (code to instantiate modules relevant to in-lab tasks, ie. oled,mouse,paint modules)

> [!IMPORTANT]
> Set project_lab.v as top module if you want to generate bitstream for project_lab.


## Structure
    constants.vh (header file containing constants)
    Top_Student.v
    ├── flexible_clock_module.v
    ├── oled.v
    └── task_d.v
        └── index_to_xy.v
    project_lab.v
    ├── flexible_clock_module.v
    ├── Oled_Display.v
    └── Mouse_Control.vhd

## Constraints Naming Convention
- switches:         `[15:0] SW`
- led:              `[15:0] led`
- 7-segment:        `[7:0] seg` and `[3:0] an` and `dp`
- push buttons:     `btnC`, `btnU`, `btnL`, `btnR`, `btnD`
- system clock:     `basys_clk`
- USB HID:          `PS2Clk`, `PS2Data`


## Feature List
| Features | Description | Inputs |
| :---: | --- | --- |
| TBC | Description on Feature | Specific User Instructions |
