BBCLASSEXTEND = "native"

# datetime is populated to sysroot without specific dependency
RDEPENDS_${PN}_remove_class-native = "${PYTHON_PN}-datetime"
