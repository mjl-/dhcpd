implement Testipval;

include "sys.m";
	sys: Sys;
	sprint: import sys;
include "draw.m";
include "arg.m";
include "bufio.m";
include "attrdb.m";
	attrdb: Attrdb;
	Db: import attrdb;
include "../../lib/ipval.m";
	ipval: Ipval;

Testipval: module {
	init:	fn(nil: ref Draw->Context, nil: list of string);
};

dflag: int;

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	arg := load Arg Arg->PATH;
	attrdb = load Attrdb Attrdb->PATH;
	attrdb->init();
	ipval = load Ipval Ipval->PATH;
	if(ipval == nil)
		fail(sprint("load ipval: %r"));

	arg->init(args);
	arg->setusage(arg->progname()+" [-d] ip attr ...");
	while((c := arg->opt()) != 0)
		case c {
		'd' =>	dflag++;
		* =>	arg->usage();
		}
	args = arg->argv();
	if(len args < 2)
		arg->usage();
	ip := hd args;
	attrs := tl args;

	db := Db.open("/lib/ndb/local");
	if(db == nil)
		fail(sprint("open ndb: %r"));
	(r, err) := ipval->findvals(db, ip, attrs);
	if(err != nil)
		fail("findvals: "+err);
	for(; r != nil; r = tl r)
		sys->print("%q=%q\n", (hd r).t0, (hd r).t1);
}

fail(s: string)
{
	sys->fprint(sys->fildes(2), "%s\n", s);
	raise "fail:"+s;
}
