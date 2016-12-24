do_cve_search() {
        ${STAGING_BINDIR_NATIVE}/search.py -p ${PN}:${PV} -o json || \
        die "cve-search execution failed."
}

do_cve_search[depends] = "cve-search-native:do_update_db"

addtask cve_search before do_build

EXPORT_FUNCTIONS do_cve_search

# Install Event-Handler to kill DB-Instances if started
addhandler cvesearch_eventhandler
cvesearch_eventhandler[eventmask] = "bb.event.BuildCompleted bb.cooker.CookerExit"
python cvesearch_eventhandler() {
	from bb.event import getName
	from bb import data
	from oeqa.utils.commands import get_bb_var
	import os.path
	import os
	import signal
	mongodbfile = '%s/mongodb.pid' % (data.getVar('TMPDIR', e.data, True))
	if os.path.isfile(mongodbfile):
		f=open(mongodbfile)
		for line in f:
			os.kill(int(line), signal.SIGTERM)
		f.close()
		os.remove(mongodbfile)
	redisdbfile = '%s/redis-server.pid' % (data.getVar('TMPDIR', e.data, True))
	if os.path.isfile(redisdbfile):
		f=open(redisdbfile)
		for line in f:
			os.kill(int(line), signal.SIGTERM)
		f.close()
		os.remove(redisdbfile)
}
