global function TuiEcamTest_Init

// ECAM lib test commands (console): ecam <sub> [args...]
// ecam demo | clear
// ecam warn|caution|ok|info <text...>
// ecam add <parent> <text...> [|target]
// ecam set <id> <text...>
// ecam sev <id> <0-3>
// ecam done <id> [0/1]        (2nd arg = autoCollapse, default 1)
// ecam reopen <id>
// ecam col <id> [0/1]         (2nd arg = collapse, default 1)
// ecam del <id>

void function TuiEcamTest_Init()
{
	AddClientCommandCallback( "ecam", EcamTest_Command )
}

bool function EcamTest_Command( entity player, array<string> args )
{
//  	int index = NSCreateTUI( player, 60, 30, 32, 0.5, 0.5, 10 )
//  	NSSendTUI(player, index, "\x1b[30;48;2;255;102;0m┌\x1b[48;2;255;140;0m┐\x1b[48;2;255;178;0ml\x1b[48;2;255;217;0m─\x1b[48;2;255;255;102mo\x1b[48;2;217;255;102m你\x1b[48;2;178;255;102m好\x1b[48;2;140;255;102m│\x1b[48;2;102;255;102m│\x1b[48;2;102;255;140mr\x1b[48;2;102;255;178ml\x1b[48;2;102;255;217md\x1b[48;2;102;255;255m测\x1b[48;2;102;217;255m试\x1b[48;2;102;178;255ma\x1b[48;2;102;140;255mb\x1b[48;2;102;102;255mc\x1b[48;2;140;102;255md\x1b[48;2;178;102;255me\x1b[48;2;217;102;255mf\x1b[0m\n\x1b[30;48;2;255;102;255m渲\x1b[48;2;255;102;217m染\x1b[48;2;255;102;178m器\x1b[48;2;255;102;140mR\x1b[97;48;2;140;14;14me\x1b[48;2;140;61;14m│\x1b[48;2;140;108;14m│\x1b[48;2;124;140;14me\x1b[48;2;77;140;14mr\x1b[48;2;30;140;14m引\x1b[48;2;14;140;45m擎\x1b[48;2;14;140;93mT\x1b[48;2;14;140;140me\x1b[48;2;14;61;140ms\x1b[48;2;14;46;140mt\x1b[48;2;30;14;140m单\x1b[48;2;77;14;140m格\x1b[48;2;124;14;140mX\x1b[48;2;108;14;140mY\x1b[48;2;61;14;140mZ\x1b[0m")
//  	return true;
	if ( args.len() == 0 )
	{
		EcamTest_Usage( player )
		return true
	}

	string sub = args[ 0 ].tolower()

	if ( sub == "demo" )
	{
		EcamTest_Demo( player )
		return true
	}

	if ( sub == "clear" )
	{
		ECAM_Clear( player )
		Chat_ServerPrivateMessage( player, "ecam cleared", false )
		return true
	}

	if ( sub == "warn" || sub == "caution" || sub == "ok" || sub == "info" || sub == "action" )
	{
		if ( args.len() < 2 )
		{
			EcamTest_Usage( player )
			return true
		}

		int severity = eEcamSeverity.INFO
		if ( sub == "warn" )
			severity = eEcamSeverity.WARNING
		else if ( sub == "caution" )
			severity = eEcamSeverity.CAUTION
		else if ( sub == "ok" )
			severity = eEcamSeverity.OK
		else if ( sub == "action" )
			severity = eEcamSeverity.ACTION

		int id = ECAM_Insert( player, 0, EcamTest_JoinArgs( args, 1 ), severity )
		Chat_ServerPrivateMessage( player, format( "inserted id %d", id ), false )
		return true
	}

	if ( sub == "add" )
	{
		if ( args.len() < 3 )
		{
			EcamTest_Usage( player )
			return true
		}

		string text = EcamTest_JoinArgs( args, 2 )
		string target = ""
		var pipe = text.find( "|" )
		if ( pipe != null )
		{
			int split = expect int( pipe )
			target = text.slice( split + 1, text.len() )
			text = text.slice( 0, split )
		}

		int id = ECAM_Insert( player, args[ 1 ].tointeger(), text, eEcamSeverity.ACTION, target )
		Chat_ServerPrivateMessage( player, format( "inserted id %d", id ), false )
		return true
	}

	if ( sub == "set" )
	{
		if ( args.len() < 3 )
		{
			EcamTest_Usage( player )
			return true
		}

		ECAM_SetText( player, args[ 1 ].tointeger(), EcamTest_JoinArgs( args, 2 ) )
		Chat_ServerPrivateMessage( player, "text updated", false )
		return true
	}

	if ( sub == "sev" )
	{
		if ( args.len() < 3 )
		{
			EcamTest_Usage( player )
			return true
		}

		ECAM_SetSeverity( player, args[ 1 ].tointeger(), args[ 2 ].tointeger() )
		Chat_ServerPrivateMessage( player, "severity updated", false )
		return true
	}

	if ( sub == "done" )
	{
		if ( args.len() < 2 )
		{
			EcamTest_Usage( player )
			return true
		}

		bool autoCollapse = args.len() < 3 || args[ 2 ] != "0"
		ECAM_Complete( player, args[ 1 ].tointeger(), autoCollapse )
		Chat_ServerPrivateMessage( player, "completed", false )
		return true
	}

	if ( sub == "reopen" )
	{
		if ( args.len() < 2 )
		{
			EcamTest_Usage( player )
			return true
		}

		ECAM_Reopen( player, args[ 1 ].tointeger() )
		Chat_ServerPrivateMessage( player, "reopened", false )
		return true
	}

	if ( sub == "col" )
	{
		if ( args.len() < 2 )
		{
			EcamTest_Usage( player )
			return true
		}

		bool collapse = args.len() < 3 || args[ 2 ] != "0"
		ECAM_Collapse( player, args[ 1 ].tointeger(), collapse )
		Chat_ServerPrivateMessage( player, collapse ? "collapsed" : "expanded", false )
		return true
	}

	if ( sub == "del" )
	{
		if ( args.len() < 2 )
		{
			EcamTest_Usage( player )
			return true
		}

		ECAM_Delete( player, args[ 1 ].tointeger() )
		Chat_ServerPrivateMessage( player, "deleted", false )
		return true
	}

	EcamTest_Usage( player )
	return true
}

void function EcamTest_Demo( entity player )
{
	int fire = ECAM_Insert( player, 0, "ENG 1 FIRE", eEcamSeverity.WARNING )
	int handle = ECAM_Insert( player, fire, "FIRE HANDLE", eEcamSeverity.ACTION, "PULL" )
	int agent = ECAM_Insert( player, fire, "AGENT 1", eEcamSeverity.ACTION, "DISCH" )
	ECAM_Complete( player, agent )
	ECAM_Insert( player, fire, "THIS IS A VERY LONG CHECKLIST ITEM TEXT THAT SHOULD WRAP ACROSS MULTIPLE PANEL LINES WHEN IT EXCEEDS THE CONTENT WIDTH LIMIT", eEcamSeverity.INFO )
	ECAM_Insert( player, fire, "引擎一号起火 立即执行灭火程序 拉起灭火手柄后释放灭火剂", eEcamSeverity.INFO )

	int nav = ECAM_Insert( player, 0, "NAV DB OUT OF DATE", eEcamSeverity.CAUTION )
	ECAM_Insert( player, nav, "CHECK ROUTE", eEcamSeverity.ACTION, "DONE" )
	ECAM_Insert( player, nav, "UPDATE DB", eEcamSeverity.ACTION, "TODO" )
	ECAM_Collapse( player, nav, true )

	int elec = ECAM_Insert( player, 0, "ELEC EMER CONFIG", eEcamSeverity.CAUTION )
	ECAM_Insert( player, elec, "GEN 1", eEcamSeverity.ACTION, "OFF" )
	ECAM_Insert( player, elec, "AC BUS 1", eEcamSeverity.ACTION, "?" )

	int cnv = ECAM_Insert( player, 0, "增压异常", eEcamSeverity.CAUTION )
	ECAM_Insert( player, cnv, "氧气面罩", eEcamSeverity.ACTION, "佩戴" )
	ECAM_Insert( player, cnv, "高度", eEcamSeverity.ACTION, "3000M" )
	ECAM_Insert( player, cnv, "立即联系管制报告情况", eEcamSeverity.ACTION, "EXEC" )

	ECAM_Insert( player, 0, "FUEL BALANCE IN PROGRESS", eEcamSeverity.OK )

	int apu = ECAM_Insert( player, 0, "APU START", eEcamSeverity.CAUTION )
	ECAM_Insert( player, apu, "APU MASTER", eEcamSeverity.ACTION, "ON" )
	ECAM_Complete( player, apu, true )

	ECAM_Insert( player, 0, "CABIN READY FOR DEPARTURE", eEcamSeverity.INFO )

	Chat_ServerPrivateMessage( player, format( "ecam demo: fire=%d nav=%d elec=%d apu=%d cnv=%d", fire, nav, elec, apu, cnv ), false )
}

void function EcamTest_Usage( entity player )
{
	Chat_ServerPrivateMessage( player, "ecam demo | clear", false )
	Chat_ServerPrivateMessage( player, "ecam warn|caution|ok|action|info <text...>", false )
	Chat_ServerPrivateMessage( player, "ecam add <parent> <text...> [|target]", false )
	Chat_ServerPrivateMessage( player, "ecam set <id> <text...> | ecam sev <id> <0-3>", false )
	Chat_ServerPrivateMessage( player, "ecam done <id> [0/1] | ecam reopen <id>", false )
	Chat_ServerPrivateMessage( player, "ecam col <id> [0/1] | ecam del <id>", false )
}

string function EcamTest_JoinArgs( array<string> args, int start )
{
	string text = ""
	for ( int i = start; i < args.len(); i++ )
	{
		if ( i > start )
			text += " "
		text += args[ i ]
	}
	return text
}
