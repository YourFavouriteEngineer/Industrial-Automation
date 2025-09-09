TYPE
  LOGLEVEL : (CRITICAL, WARNING, INFO, DEBUG) := INFO;
END_TYPE

FUNCTION_BLOCK LOGGER
  VAR_INPUT
    TRIG : BOOL;
    MSG : STRING;
    LEVEL : LOGLEVEL := INFO;
  END_VAR
  VAR
    TRIG0 : BOOL;
  END_VAR

  IF TRIG AND NOT TRIG0 THEN
  {{
   LogMessage(GetFbVar(LEVEL),(char*)GetFbVar(MSG, .body),GetFbVar(MSG, .len));
  }}
  END_IF;
  TRIG0:=TRIG;
END_FUNCTION_BLOCK


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
  RedTimer := TON0.ET;
  GreenTimer := TON1.ET;
  YellowTimer := TON2.ET;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : trafficlight;
  END_RESOURCE
END_CONFIGURATION
