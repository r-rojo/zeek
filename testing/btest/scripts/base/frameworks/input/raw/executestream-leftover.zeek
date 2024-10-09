# @TEST-DOC: Launching a program that produces output slowly and strangely separated.
# @TEST-EXEC: chmod +x run.sh
# @TEST-EXEC: btest-bg-run zeek zeek -b %INPUT
# @TEST-EXEC: btest-bg-wait 10
# @TEST-EXEC: btest-diff zeek/.stdout

redef exit_only_after_terminate = T;

redef Threading::heartbeat_interval = 0.01sec;

@TEST-START-FILE run.sh
#!/usr/bin/env bash
echo -e -n "aaa\nb"
sleep 0.1
echo -e -n "bb\nfi"
sleep 0.1
echo "nal"

sleep infinity
@TEST-END-FILE

module A;

type Val: record {
	s: string;
};

global lines = 0;

event one_line(description: Input::EventDescription, tpe: Input::Event, s: string)
	{
	print tpe, s;
	++lines;

	if ( lines == 3 )
		{
		Input::remove("input");
		terminate();
		}
	}

event zeek_init()
	{
	Input::add_event([
		$name="run",
		$source="../run.sh |",
		$reader=Input::READER_RAW,
		$mode=Input::STREAM,
		$fields=Val,
		$ev=one_line, $want_record=F,
	]);
	}