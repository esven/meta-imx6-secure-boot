BBCLASSEXTEND = "native"

# these dependencies are populated to sysroot without specific dependency
RDEPENDS_${PN}_remove_class-native = "${PYTHON_PN}-numbers"
RDEPENDS_${PN}_remove_class-native = "${PYTHON_PN}-email"
RDEPENDS_${PN}_remove_class-native = "${PYTHON_PN}-subprocess"
RDEPENDS_${PN}_remove_class-native = "${PYTHON_PN}-pkgutil"
RDEPENDS_${PN}_remove_class-native = "${PYTHON_PN}-html"
RDEPENDS_${PN}_remove_class-native = "${PYTHON_PN}-json"
