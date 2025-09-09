PROGRAM VFD
  VAR_OUTPUT
    AO_Speed : REAL := 0.0;
  END_VAR
  VAR_INPUT
    SetSpeedHz : REAL := 0.0;
  END_VAR
  VAR
    _TMP_DIV2_OUT : REAL;
    _TMP_MUL3_OUT : REAL;
  END_VAR

  _TMP_DIV2_OUT := DIV(SetSpeedHz, 60.0);
  _TMP_MUL3_OUT := MUL(_TMP_DIV2_OUT, 10.0);
  AO_Speed := _TMP_MUL3_OUT;
END_PROGRAM

FUNCTION_BLOCK MotorCtrl
  VAR_INPUT
    StartCmd : BOOL;
    StopCmd : BOOL;
    ResetCmd : BOOL;
    OL_Fault : BOOL;
    FB_Run : BOOL;
  END_VAR
  VAR_OUTPUT
    MotorRun : BOOL;
    Running : BOOL;
    Fault : BOOL;
  END_VAR
  VAR
    Latch : BOOL;
    FaultLatch : BOOL;
  END_VAR

  IF OL_Fault OR NOT(FB_Run) AND Latch THEN
    FaultLatch := TRUE; (*set*)
  END_IF;
  IF ResetCmd THEN
    FaultLatch := FALSE; (*reset*)
  END_IF;
  Latch := (Latch OR StartCmd) AND NOT(FaultLatch) AND NOT(StopCmd);
  MotorRun := Latch;
  Running := FB_Run;
  Fault := FaultLatch;
END_FUNCTION_BLOCK

PROGRAM motorcontrol
  VAR
    MotorCtrl0 : MotorCtrl;
  END_VAR
  VAR_INPUT
    Start : BOOL;
    Stop : BOOL;
    Reset : BOOL;
    Overload : BOOL;
  END_VAR
  VAR_OUTPUT
    Motor : BOOL;
    RunLight : BOOL;
    FaultLight : BOOL;
  END_VAR
  VAR
    Feedback : BOOL;
  END_VAR

  MotorCtrl0(StartCmd := Start, StopCmd := Stop, ResetCmd := Reset, OL_Fault := Overload, FB_Run := Feedback);
  Motor := MotorCtrl0.MotorRun;
  RunLight := MotorCtrl0.Running;
  FaultLight := MotorCtrl0.Fault;
  Feedback := MotorCtrl0.MotorRun;
END_PROGRAM

PROGRAM tanklevelctrl
  VAR_INPUT
    LevelSensor : REAL;
  END_VAR
  VAR_OUTPUT
    PUMP1 : BOOL;
    PUMP2 : BOOL;
  END_VAR
  VAR_INPUT
    SwitchState : BOOL;
  END_VAR
  VAR
    InLatch : BOOL;
    OutLatch : BOOL;
    _TMP_LE4_OUT : BOOL;
    _TMP_AND10_OUT : BOOL;
    _TMP_GE5_OUT : BOOL;
    _TMP_OR14_OUT : BOOL;
    _TMP_GE15_OUT : BOOL;
    _TMP_AND17_OUT : BOOL;
    _TMP_LE21_OUT : BOOL;
    _TMP_OR24_OUT : BOOL;
  END_VAR

  _TMP_LE4_OUT := LE(LevelSensor, 40.0);
  _TMP_AND10_OUT := AND(SwitchState, _TMP_LE4_OUT);
  IF _TMP_AND10_OUT THEN
    InLatch := TRUE; (*set*)
  END_IF;
  _TMP_GE5_OUT := GE(LevelSensor, 80.0);
  _TMP_OR14_OUT := OR(NOT(SwitchState), _TMP_GE5_OUT);
  IF _TMP_OR14_OUT THEN
    InLatch := FALSE; (*reset*)
  END_IF;
  _TMP_GE15_OUT := GE(LevelSensor, 80.0);
  _TMP_AND17_OUT := AND(SwitchState, _TMP_GE15_OUT);
  IF _TMP_AND17_OUT THEN
    OutLatch := TRUE; (*set*)
  END_IF;
  _TMP_LE21_OUT := LE(LevelSensor, 40.0);
  _TMP_OR24_OUT := OR(NOT(SwitchState), _TMP_LE21_OUT);
  IF _TMP_OR24_OUT THEN
    OutLatch := FALSE; (*reset*)
  END_IF;
  PUMP1 := InLatch;
  PUMP2 := OutLatch;
END_PROGRAM

PROGRAM stardelta
  VAR
    Stop : BOOL;
    Start : BOOL;
    Motor : BOOL;
    K1 : BOOL;
    Delta : BOOL;
    Star : BOOL;
    TON0 : TON;
    TOF0 : TOF;
    R_TRIG0 : R_TRIG;
  END_VAR

  R_TRIG0(CLK := K1);
  TOF0(IN := R_TRIG0.Q, PT := T#5s);
  Delta := NOT(Star) AND TOF0.Q;
  TON0(IN := K1, PT := T#5s);
  Star := NOT(Delta) AND TON0.Q;
  Motor := Delta OR Star;
  K1 := NOT(Stop) AND (K1 OR Start);
END_PROGRAM

PROGRAM dol
  VAR
    Start : BOOL;
    Stop : BOOL;
    Motor : BOOL;
    L1 : BOOL;
  END_VAR

  L1 := (L1 OR Start) AND NOT(Stop);
  Motor := L1;
END_PROGRAM

PROGRAM fwdrev
  VAR_INPUT
    STOP : BOOL;
    STF : BOOL;
    STR : BOOL;
  END_VAR
  VAR
    FWD : BOOL;
    REV : BOOL;
  END_VAR
  VAR_OUTPUT
    MOTOR : BOOL;
  END_VAR

  FWD := NOT(REV) AND (FWD OR STF) AND NOT(STOP);
  REV := NOT(FWD) AND (REV OR STR) AND NOT(STOP);
  MOTOR := FWD OR REV;
END_PROGRAM

PROGRAM tanklevelsim
  VAR
    TankLevel : REAL;
    PumpCtrl : REAL;
    _TMP_ADD3_OUT : REAL;
    _TMP_LE7_OUT : BOOL;
    _TMP_MOVE9_ENO : BOOL;
    _TMP_MOVE9_OUT : REAL;
    _TMP_GE5_OUT : BOOL;
    _TMP_MOVE8_ENO : BOOL;
    _TMP_MOVE8_OUT : REAL;
  END_VAR

  _TMP_ADD3_OUT := ADD(TankLevel, PumpCtrl);
  TankLevel := _TMP_ADD3_OUT;
  _TMP_LE7_OUT := LE(TankLevel, 40.0);
  _TMP_MOVE9_OUT := MOVE(EN := _TMP_LE7_OUT, IN := 0.1, ENO => _TMP_MOVE9_ENO);
  IF _TMP_MOVE9_ENO THEN
      PumpCtrl := _TMP_MOVE9_OUT;
  END_IF;
  _TMP_GE5_OUT := GE(TankLevel, 70.0);
  _TMP_MOVE8_OUT := MOVE(EN := _TMP_GE5_OUT, IN := -0.1, ENO => _TMP_MOVE8_ENO);
  IF _TMP_MOVE8_ENO THEN
      PumpCtrl := _TMP_MOVE8_OUT;
  END_IF;
END_PROGRAM

PROGRAM trafficlight
  VAR_INPUT NON_RETAIN
    Start : BOOL;
    Stop : BOOL;
  END_VAR
  VAR
    Cycle_Start : BOOL;
    T_Red : BOOL;
    T_Green : BOOL;
    T_Yellow : BOOL;
  END_VAR
  VAR_OUTPUT
    RED : BOOL;
    GREEN : BOOL;
    YELLOW : BOOL;
  END_VAR
  VAR
    TON0 : TON;
    TON1 : TON;
    TON2 : TON;
    R_TRIG1 : R_TRIG;
  END_VAR

  Cycle_Start := (Cycle_Start OR Start) AND NOT(Stop);
  RED := NOT(T_Red) AND Cycle_Start;
  GREEN := NOT(T_Green) AND T_Red AND Cycle_Start;
  YELLOW := NOT(T_Yellow) AND T_Green AND Cycle_Start;
  TON0(IN := NOT(T_Red) AND Cycle_Start, PT := T#5s);
  IF TON0.Q THEN
    T_Red := TRUE; (*set*)
  END_IF;
  TON1(IN := NOT(T_Green) AND T_Red AND Cycle_Start, PT := T#5s);
  IF TON1.Q THEN
    T_Green := TRUE; (*set*)
  END_IF;
  TON2(IN := NOT(T_Yellow) AND T_Green AND Cycle_Start, PT := T#5s);
  R_TRIG1(CLK := TON2.Q);
  T_Yellow := R_TRIG1.Q;
  IF T_Yellow THEN
    T_Red := FALSE; (*reset*)
  END_IF;
  IF T_Yellow THEN
    T_Green := FALSE; (*reset*)
  END_IF;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    TASK task1(INTERVAL := T#20ms,PRIORITY := 0);
    TASK task2(INTERVAL := T#20ms,PRIORITY := 0);
    TASK task3(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : trafficlight;
    PROGRAM instance1 WITH task1 : tanklevelsim;
    PROGRAM instance2 WITH task1 : tanklevelctrl;
    PROGRAM instance3 WITH task2 : dol;
    PROGRAM instance4 WITH task2 : fwdrev;
    PROGRAM instance5 WITH task2 : stardelta;
    PROGRAM instance6 WITH task2 : motorcontrol;
    PROGRAM instance7 WITH task2 : VFD;
  END_RESOURCE
END_CONFIGURATION

(*DBG:char md5[] = "964ccd755be7e2e3e9b33180e6b6cbfb";*)
(*DBG:/**)
(*DBG: * This file is part of OpenPLC Runtime*)
(*DBG: **)
(*DBG: * Copyright (C) 2023 Autonomy, GP Orcullo*)
(*DBG: * Based on the work by GP Orcullo on Beremiz for uC*)
(*DBG: **)
(*DBG: * This program is free software; you can redistribute it and/or*)
(*DBG: * modify it under the terms of the GNU General Public License*)
(*DBG: * as published by the Free Software Foundation; either version 2*)
(*DBG: * of the License, or (at your option) any later version.*)
(*DBG: **)
(*DBG: * This program is distributed in the hope that it will be useful,*)
(*DBG: * but WITHOUT ANY WARRANTY; without even the implied warranty of*)
(*DBG: * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the*)
(*DBG: * GNU General Public License for more details.*)
(*DBG: **)
(*DBG: * You should have received a copy of the GNU General Public License*)
(*DBG: * along with this program; If not, see <http://www.gnu.org/licenses/>.*)
(*DBG: **)
(*DBG: */*)
(*DBG:*)
(*DBG:#include <stdbool.h>*)
(*DBG:*)
(*DBG:#include "iec_types_all.h"*)
(*DBG:#include "POUS.h"*)
(*DBG:*)
(*DBG:#define SAME_ENDIANNESS      0*)
(*DBG:#define REVERSE_ENDIANNESS   1*)
(*DBG:*)
(*DBG:uint8_t endianness;*)
(*DBG:*)
(*DBG:*)
(*DBG:extern TRAFFICLIGHT RES0__INSTANCE0;*)
(*DBG:extern TANKLEVELSIM RES0__INSTANCE1;*)
(*DBG:extern TANKLEVELCTRL RES0__INSTANCE2;*)
(*DBG:extern DOL RES0__INSTANCE3;*)
(*DBG:extern FWDREV RES0__INSTANCE4;*)
(*DBG:extern STARDELTA RES0__INSTANCE5;*)
(*DBG:extern MOTORCONTROL RES0__INSTANCE6;*)
(*DBG:extern VFD RES0__INSTANCE7;*)
(*DBG:*)
(*DBG:static const struct {*)
(*DBG:    void *ptr;*)
(*DBG:    __IEC_types_enum type;*)
(*DBG:} debug_vars[] = {*)
(*DBG:    {&(RES0__INSTANCE0.START), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.STOP), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CYCLE_START), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.T_RED), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.T_GREEN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.T_YELLOW), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.RED), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.GREEN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.YELLOW), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.PT), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.ET), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.STATE), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.PREV_IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.CURRENT_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON0.START_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.PT), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.ET), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.STATE), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.PREV_IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.CURRENT_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.START_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.PT), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.ET), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.STATE), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.PREV_IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.CURRENT_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.START_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.CLK), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.M), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1.TANKLEVEL), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1.PUMPCTRL), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1._TMP_ADD3_OUT), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1._TMP_LE7_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1._TMP_MOVE9_ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1._TMP_MOVE9_OUT), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1._TMP_GE5_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1._TMP_MOVE8_ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE1._TMP_MOVE8_OUT), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2.LEVELSENSOR), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2.PUMP1), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2.PUMP2), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2.SWITCHSTATE), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2.INLATCH), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2.OUTLATCH), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2._TMP_LE4_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2._TMP_AND10_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2._TMP_GE5_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2._TMP_OR14_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2._TMP_GE15_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2._TMP_AND17_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2._TMP_LE21_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE2._TMP_OR24_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE3.START), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE3.STOP), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE3.MOTOR), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE3.L1), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE4.STOP), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE4.STF), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE4.STR), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE4.FWD), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE4.REV), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE4.MOTOR), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.STOP), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.START), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.MOTOR), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.K1), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.DELTA), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.STAR), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.PT), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.ET), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.STATE), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.PREV_IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.CURRENT_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TON0.START_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.PT), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.ET), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.STATE), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.PREV_IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.CURRENT_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.TOF0.START_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.R_TRIG0.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.R_TRIG0.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.R_TRIG0.CLK), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.R_TRIG0.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE5.R_TRIG0.M), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.STARTCMD), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.STOPCMD), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.RESETCMD), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.OL_FAULT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.FB_RUN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.MOTORRUN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.RUNNING), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.FAULT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.LATCH), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTORCTRL0.FAULTLATCH), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.START), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.STOP), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.RESET), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.OVERLOAD), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.MOTOR), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.RUNLIGHT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.FAULTLIGHT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE6.FEEDBACK), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE7.AO_SPEED), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE7.SETSPEEDHZ), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE7._TMP_DIV2_OUT), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE7._TMP_MUL3_OUT), REAL_ENUM},*)
(*DBG:};*)
(*DBG:*)
(*DBG:#define VAR_COUNT               132*)
(*DBG:*)
(*DBG:uint16_t get_var_count(void)*)
(*DBG:{*)
(*DBG:    return VAR_COUNT;*)
(*DBG:}*)
(*DBG:*)
(*DBG:size_t get_var_size(size_t idx)*)
(*DBG:{*)
(*DBG:    if (idx >= VAR_COUNT)*)
(*DBG:    {*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:    switch (debug_vars[idx].type) {*)
(*DBG:    case BOOL_ENUM:*)
(*DBG:        return sizeof(BOOL);*)
(*DBG:    case TIME_ENUM:*)
(*DBG:        return sizeof(TIME);*)
(*DBG:    case REAL_ENUM:*)
(*DBG:        return sizeof(REAL);*)
(*DBG:    case SINT_ENUM:*)
(*DBG:        return sizeof(SINT);*)
(*DBG:    default:*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void *get_var_addr(size_t idx)*)
(*DBG:{*)
(*DBG:    void *ptr = debug_vars[idx].ptr;*)
(*DBG:*)
(*DBG:    switch (debug_vars[idx].type) {*)
(*DBG:    case BOOL_ENUM:*)
(*DBG:        return (void *)&((__IEC_BOOL_t *) ptr)->value;*)
(*DBG:    case TIME_ENUM:*)
(*DBG:        return (void *)&((__IEC_TIME_t *) ptr)->value;*)
(*DBG:    case REAL_ENUM:*)
(*DBG:        return (void *)&((__IEC_REAL_t *) ptr)->value;*)
(*DBG:    case SINT_ENUM:*)
(*DBG:        return (void *)&((__IEC_SINT_t *) ptr)->value;*)
(*DBG:    default:*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void force_var(size_t idx, bool forced, void *val)*)
(*DBG:{*)
(*DBG:    void *ptr = debug_vars[idx].ptr;*)
(*DBG:*)
(*DBG:    if (forced) {*)
(*DBG:        size_t var_size = get_var_size(idx);*)
(*DBG:        switch (debug_vars[idx].type) {*)
(*DBG:        case BOOL_ENUM: {*)
(*DBG:            memcpy(&((__IEC_BOOL_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_BOOL_t *) ptr)->value = *((BOOL *) val);*)
(*DBG:            ((__IEC_BOOL_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case TIME_ENUM: {*)
(*DBG:            memcpy(&((__IEC_TIME_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_TIME_t *) ptr)->value = *((TIME *) val);*)
(*DBG:            ((__IEC_TIME_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case REAL_ENUM: {*)
(*DBG:            memcpy(&((__IEC_REAL_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_REAL_t *) ptr)->value = *((REAL *) val);*)
(*DBG:            ((__IEC_REAL_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case SINT_ENUM: {*)
(*DBG:            memcpy(&((__IEC_SINT_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_SINT_t *) ptr)->value = *((SINT *) val);*)
(*DBG:            ((__IEC_SINT_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        default:*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:    } else {*)
(*DBG:        switch (debug_vars[idx].type) {*)
(*DBG:        case BOOL_ENUM:*)
(*DBG:            ((__IEC_BOOL_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case TIME_ENUM:*)
(*DBG:            ((__IEC_TIME_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case REAL_ENUM:*)
(*DBG:            ((__IEC_REAL_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case SINT_ENUM:*)
(*DBG:            ((__IEC_SINT_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        default:*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void swap_bytes(void *ptr, size_t size) *)
(*DBG:{*)
(*DBG:    uint8_t *bytePtr = (uint8_t *)ptr;*)
(*DBG:    size_t i;*)
(*DBG:    for (i = 0; i < size / 2; ++i) *)
(*DBG:    {*)
(*DBG:        uint8_t temp = bytePtr[i];*)
(*DBG:        bytePtr[i] = bytePtr[size - 1 - i];*)
(*DBG:        bytePtr[size - 1 - i] = temp;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void trace_reset(void)*)
(*DBG:{*)
(*DBG:    for (size_t i=0; i < VAR_COUNT; i++) *)
(*DBG:    {*)
(*DBG:        force_var(i, false, 0);*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void set_trace(size_t idx, bool forced, void *val)*)
(*DBG:{*)
(*DBG:    if (idx >= 0 && idx < VAR_COUNT) *)
(*DBG:    {*)
(*DBG:        if (endianness == REVERSE_ENDIANNESS)*)
(*DBG:        {*)
(*DBG:            // Aaaaarghhhh... Stupid AVR is Big Endian.*)
(*DBG:            swap_bytes(val, get_var_size(idx));*)
(*DBG:        }*)
(*DBG:*)
(*DBG:        force_var(idx, forced, val);*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void set_endianness(uint8_t value)*)
(*DBG:{*)
(*DBG:    if (value == SAME_ENDIANNESS || value == REVERSE_ENDIANNESS)*)
(*DBG:    {*)
(*DBG:        endianness = value;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)