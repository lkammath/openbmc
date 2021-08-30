FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SYSTEMD_SERVICE_${PN}_append_p10bmc += "obmc-clear-all-faults@.service"

# Copies config file having arguments for clear-all-faults.sh
SYSTEMD_ENVIRONMENT_FILE_${PN}_append_p10bmc +="obmc/led/clear-all/faults/config"

PACKAGECONFIG_append_ibm-ac-server = " associations"
SRC_URI_append_ibm-ac-server = " file://associations.json"
DEPENDS_append_ibm-ac-server = " inventory-cleanup"

PACKAGECONFIG_append_p10bmc = " associations"
SRC_URI_append_p10bmc = " \
    file://ibm,rainier-2u_associations.json \
    file://ibm,rainier-4u_associations.json \
    file://ibm,everest_associations.json \
    "

pkg_postinst_${PN}_p10bmc () {
    # Needed this to run as part of BMC boot
    mkdir -p $D$systemd_system_unitdir/multi-user.target.wants
    LINK_CLEAR="$D$systemd_system_unitdir/multi-user.target.wants/obmc-clear-all-faults@true.service"
    TARGET_CLEAR="../obmc-clear-all-faults@.service"
    ln -s $TARGET_CLEAR $LINK_CLEAR

    # Needed this to run as part of Power On
    mkdir -p $D$systemd_system_unitdir/obmc-chassis-poweron@0.target.wants
    LINK_CLEAR="$D$systemd_system_unitdir/obmc-chassis-poweron@0.target.wants/obmc-clear-all-faults@true.service"
    TARGET_CLEAR="../obmc-clear-all-faults@.service"
    ln -s $TARGET_CLEAR $LINK_CLEAR
}

pkg_prerm_${PN}_p10bmc () {
    LINK_CLEAR="$D$systemd_system_unitdir/multi-user.target.wants/obmc-clear-all-faults@true.service"
    rm $LINK_CLEAR

    LINK_CLEAR="$D$systemd_system_unitdir/obmc-chassis-poweron@0.target.wants/obmc-clear-all-faults@true.service"
    rm $LINK_CLEAR
}

do_install_append_ibm-ac-server() {
    install -d ${D}${base_datadir}
    install -m 0755 ${WORKDIR}/associations.json ${D}${base_datadir}/associations.json
}

do_install_append_p10bmc() {
    install -d ${D}${base_datadir}
    install -m 0755 ${WORKDIR}/ibm,rainier-2u_associations.json ${D}${base_datadir}/ibm,rainier-2u_associations.json
    install -m 0755 ${WORKDIR}/ibm,rainier-4u_associations.json ${D}${base_datadir}/ibm,rainier-4u_associations.json
    install -m 0755 ${WORKDIR}/ibm,everest_associations.json ${D}${base_datadir}/ibm,everest_associations.json
}
