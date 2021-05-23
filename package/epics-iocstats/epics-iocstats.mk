EPICS_IOCSTATS_VERSION = 948b669689f88b68dc351203b7e30931c7515237
EPICS_IOCSTATS_SITE = $(call github,epics-modules,iocstats,$(EPICS_IOCSTATS_VERSION))
EPICS_IOCSTATS_LICENSE = EPICS
EPICS_IOCSTATS_LICENSE_FILES = LICENSE
EPICS_IOCSTATS_DEPENDENCIES = epics-base

define EPICS_IOCSTATS_CONFIGURE_CMDS
$(SED) '/SUPPORT/d' "$(@D)/configure/RELEASE"
$(SED) '/SNCSEQ/d' "$(@D)/configure/RELEASE"
$(SED) '/EPICS_BASE/d' "$(@D)/configure/RELEASE"
echo "EPICS_BASE=$(HOST_DIR)/usr/lib/epics" >> "$(@D)/configure/RELEASE"
endef

define EPICS_IOCSTATS_BUILD_CMDS
$(TARGET_MAKE_ENV) $(MAKE) -j$(PARALLEL_JOBS) -C "$(@D)" \
 INSTALL_LOCATION=$(HOST_DIR)/usr/lib/epics
endef

define EPICS_IOCSTATS_INSTALL_TARGET_CMDS
# (maybe) shared libraries
[ "$(BR2_SHARED_LIBS)" = "y" ] && \
$(INSTALL) -m 755 -D -t $(TARGET_DIR)/usr/lib/epics/lib/$(EPICS_BASE_T_A) \
  $(HOST_DIR)/usr/lib/epics/lib/$(EPICS_BASE_T_A)/*.so*
# (maybe) symlink runtime libraries
[ "$(BR2_SHARED_LIBS)" = "y" ] && \
for lib in $(TARGET_DIR)/usr/lib/epics/lib/$(EPICS_BASE_T_A)/*.so*; do \
  ln -vfs epics/lib/$(EPICS_BASE_T_A)/`basename $$lib` $(TARGET_DIR)/usr/lib/`basename $$lib`; \
done
# db/dbd
$(INSTALL) -m 644 -D -t $(TARGET_DIR)/usr/lib/epics/dbd $(HOST_DIR)/usr/lib/epics/dbd/*.dbd
$(INSTALL) -m 644 -D -t $(TARGET_DIR)/usr/lib/epics/db $(HOST_DIR)/usr/lib/epics/db/*.db
endef

$(eval $(generic-package))
