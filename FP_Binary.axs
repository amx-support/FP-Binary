PROGRAM_NAME='FP_Binary'
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/05/2006  AT: 09:00:25        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvTP = 10001:1:0

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE float		fData
VOLATILE double		dData

VOLATILE char		strFloat[16]
VOLATILE char		strDouble[16]

VOLATILE integer	nInput

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT [dvTP]
{
    ONLINE:
    {
	STACK_VAR integer i
	
	FOR(i=1;i<=4;i++) SEND_COMMAND dvTP,"'^TXT-',ITOA(i+10),',0,',FORMAT('%02X',strFloat[i+1])"
	FOR(i=1;i<=8;i++) SEND_COMMAND dvTP,"'^TXT-',ITOA(i+20),',0,',FORMAT('%02X',strDouble[i+1])"
    }

    STRING:
    {
	STACK_VAR integer i
    
	IF (FIND_STRING(DATA.TEXT,'AKP-',1))
	{
	    REMOVE_STRING(DATA.TEXT,'AKP-',1)
	    SEND_COMMAND dvTP,"'^TXT-1,0,',DATA.TEXT"
	    
	    fData = ATOF(DATA.TEXT)
	    dData = ATOF(DATA.TEXT)
	    
	    VARIABLE_TO_STRING(fData,strFloat,1)
	    VARIABLE_TO_STRING(dData,strDouble,1)
	    
	    FOR(i=1;i<=4;i++) SEND_COMMAND dvTP,"'^TXT-',ITOA(i+10),',0,',FORMAT('%02X',strFloat[i+1])"
	    FOR(i=1;i<=8;i++) SEND_COMMAND dvTP,"'^TXT-',ITOA(i+20),',0,',FORMAT('%02X',strDouble[i+1])"
	}
	IF (FIND_STRING(DATA.TEXT,'AKB-',1))
	{
	    REMOVE_STRING(DATA.TEXT,'AKB-',1)
	    
	    SELECT
	    {
		ACTIVE(nInput == 2):
		{
		    IF (LENGTH_STRING(DATA.TEXT) == 8)
		    {
			strFloat[1] = $E3
			strFloat[2] = HEXTOI("DATA.TEXT[1],DATA.TEXT[2]")
			strFloat[3] = HEXTOI("DATA.TEXT[3],DATA.TEXT[4]")
			strFloat[4] = HEXTOI("DATA.TEXT[5],DATA.TEXT[6]")
			strFloat[5] = HEXTOI("DATA.TEXT[7],DATA.TEXT[8]")
			SET_LENGTH_ARRAY(strFloat,5)
		    }
		    ELSE strFloat = "$E3,$00,$00,$00,$00"
		    
		    STRING_TO_VARIABLE(fData,strFloat,1)
		    dData = fData
		    VARIABLE_TO_STRING(dData,strDouble,1)
		    SEND_COMMAND dvTP,"'^TXT-1,0,',FTOA(fData)"
		}
		ACTIVE(nInput == 3):
		{
		    IF (LENGTH_STRING(DATA.TEXT) == 16)
		    {
			strDouble[1] = $E4
			strDouble[2] = HEXTOI("DATA.TEXT[1],DATA.TEXT[2]")
			strDouble[3] = HEXTOI("DATA.TEXT[3],DATA.TEXT[4]")
			strDouble[4] = HEXTOI("DATA.TEXT[5],DATA.TEXT[6]")
			strDouble[5] = HEXTOI("DATA.TEXT[7],DATA.TEXT[8]")
			strDouble[6] = HEXTOI("DATA.TEXT[9],DATA.TEXT[10]")
			strDouble[7] = HEXTOI("DATA.TEXT[11],DATA.TEXT[12]")
			strDouble[8] = HEXTOI("DATA.TEXT[13],DATA.TEXT[14]")
			strDouble[9] = HEXTOI("DATA.TEXT[15],DATA.TEXT[16]")
			SET_LENGTH_ARRAY(strDouble,9)
		    }
		    ELSE strDouble = "$E3,$00,$00,$00,$00,$00,$00,$00,$00"
		    
		    STRING_TO_VARIABLE(dData,strDouble,1)
		    fData = TYPE_CAST(dData)
		    VARIABLE_TO_STRING(fData,strFloat,1)
		    SEND_COMMAND dvTP,"'^TXT-1,0,',FTOA(dData)"
		}
		ACTIVE(nInput >= 11 && nInput <= 14):
		{
		    strFloat[1] = $E3
		    strFloat[nInput-9] = HEXTOI(DATA.TEXT)
		    SET_LENGTH_ARRAY(strFloat,5)
		    
		    STRING_TO_VARIABLE(fData,strFloat,1)
		    dData = fData
		    VARIABLE_TO_STRING(dData,strDouble,1)
		    SEND_COMMAND dvTP,"'^TXT-1,0,',FTOA(fData)"
		}
		ACTIVE(nInput >= 21 && nInput <= 28):
		{
		    strDouble[1] = $E4
		    strDouble[nInput-19] = HEXTOI(DATA.TEXT)
		    SET_LENGTH_ARRAY(strDouble,9)
		    
		    STRING_TO_VARIABLE(dData,strDouble,1)
		    fData = TYPE_CAST(dData)
		    VARIABLE_TO_STRING(fData,strFloat,1)
		    SEND_COMMAND dvTP,"'^TXT-1,0,',FTOA(dData)"
		}
	    }
	    
	    FOR(i=1;i<=4;i++) SEND_COMMAND dvTP,"'^TXT-',ITOA(i+10),',0,',FORMAT('%02X',strFloat[i+1])"
	    FOR(i=1;i<=8;i++) SEND_COMMAND dvTP,"'^TXT-',ITOA(i+20),',0,',FORMAT('%02X',strDouble[i+1])"
	}
    }
}

BUTTON_EVENT [dvTP,0]
{
    PUSH:
    {
	nInput = BUTTON.INPUT.CHANNEL
	
	IF (BUTTON.INPUT.CHANNEL == 1) SEND_COMMAND dvTP,'^AKP'
	ELSE SEND_COMMAND dvTP,'^AKB'
    }
}

(*****************************************************************)
(*                                                               *)
(*                      !!!! WARNING !!!!                        *)
(*                                                               *)
(* Due to differences in the underlying architecture of the      *)
(* X-Series masters, changing variables in the DEFINE_PROGRAM    *)
(* section of code can negatively impact program performance.    *)
(*                                                               *)
(* See “Differences in DEFINE_PROGRAM Program Execution” section *)
(* of the NX-Series Controllers WebConsole & Programming Guide   *)
(* for additional and alternate coding methodologies.            *)
(*****************************************************************)

DEFINE_PROGRAM

(*****************************************************************)
(*                       END OF PROGRAM                          *)
(*                                                               *)
(*         !!!  DO NOT PUT ANY CODE BELOW THIS COMMENT  !!!      *)
(*                                                               *)
(*****************************************************************)


