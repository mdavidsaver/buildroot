EPICS_BASE_VERSION = b777233efb06fa4e988c4f0738b0270dd3d095a3
EPICS_BASE_SITE = $(call github,epics-base,epics-base,$(EPICS_BASE_VERSION))
EPICS_BASE_LICENSE = EPICS
EPICS_BASE_LICENSE_FILES = LICENSE
EPICS_BASE_DEPENDENCIES = host-perl host-readline readline

# TODO:
#  to suport ccache, patch $(HOSTCC) and $(HOSTCXX) into configure/os/CONFIG_SITE.$(EPICS_HOST_ARCH).$(EPICS_HOST_ARCH)

# remove quotes
EPICS_BASE_T_A=$(subst ",,$(BR_EPICS_BASE_TARGET))

define EPICS_BASE_CONFIGURE_CMDS

echo "EPICS_SITE_VERSION = br" > "$(@D)/configure/CONFIG_SITE.local"
echo "CROSS_COMPILER_TARGET_ARCHS=$(EPICS_BASE_T_A)" >> "$(@D)/configure/CONFIG_SITE.local"

echo "GNU_TARGET=$(GNU_TARGET_NAME)" > "$(@D)/configure/CONFIG_SITE.target.local"
echo "GNU_DIR=$(HOST_DIR)" >> "$(@D)/configure/CONFIG_SITE.target.local"
echo "LINKER_USE_RPATH=NO" >> "$(@D)/configure/CONFIG_SITE.target.local"

if [ "$(BR2_SHARED_LIBS)" = "y" ]; then \
  echo "SHARED_LIBRARIES=YES" >> "$(@D)/configure/CONFIG_SITE.target.local"; \
  echo "STATIC_BUILD=NO" >> "$(@D)/configure/CONFIG_SITE.target.local"; \
else \
  echo "SHARED_LIBRARIES=NO" >> "$(@D)/configure/CONFIG_SITE.target.local" ; \
  echo "STATIC_BUILD=YES" >> "$(@D)/configure/CONFIG_SITE.target.local" ; \
fi

mv "$(@D)/configure/CONFIG_SITE.target.local" \
 "$(@D)/configure/os/CONFIG_SITE.`$(HOST_DIR)/bin/perl "$(@D)/src/tools/EpicsHostArch.pl"`.$(EPICS_BASE_T_A)"

endef

define EPICS_BASE_BUILD_CMDS
$(TARGET_MAKE_ENV) $(MAKE) -j$(PARALLEL_JOBS) -C "$(@D)" \
 INSTALL_LOCATION=$(HOST_DIR)/usr/lib/epics \
 SUBMODULES=
endef

define EPICS_BASE_INSTALL_TARGET_CMDS
# install to /usr/lib/epics
# executables
$(INSTALL) -m 755 -D -t $(TARGET_DIR)/usr/lib/epics/bin/$(EPICS_BASE_T_A) \
  $(HOST_DIR)/usr/lib/epics/bin/$(EPICS_BASE_T_A)/{caget,caput,camonitor,cainfo,casw,caRepeater,softIoc}
# (maybe) shared libraries
[ "$(BR2_SHARED_LIBS)" = "y" ] && \
$(INSTALL) -m 755 -D -t $(TARGET_DIR)/usr/lib/epics/lib/$(EPICS_BASE_T_A) \
  $(HOST_DIR)/usr/lib/epics/lib/$(EPICS_BASE_T_A)/*.so*
# db/dbd
$(INSTALL) -m 644 -D -t $(TARGET_DIR)/usr/lib/epics/dbd $(HOST_DIR)/usr/lib/epics/dbd/softIoc.dbd
$(INSTALL) -m 644 -D -t $(TARGET_DIR)/usr/lib/epics/db $(HOST_DIR)/usr/lib/epics/db/*.db
# symlink executables in /usr/bin
$(INSTALL) -d $(TARGET_DIR)/usr/bin
for exe in caget caput camonitor cainfo casw caRepeater softIoc; do \
  ln -vfs ../lib/epics/bin/$(EPICS_BASE_T_A)/$$exe $(TARGET_DIR)/usr/bin/$$exe; \
done
# (maybe) symlink runtime libraries
[ "$(BR2_SHARED_LIBS)" = "y" ] && \
for lib in $(TARGET_DIR)/usr/lib/epics/lib/$(EPICS_BASE_T_A)/*.so*; do \
  ln -vfs epics/lib/$(EPICS_BASE_T_A)/`basename $$lib` $(TARGET_DIR)/usr/lib/`basename $$lib`; \
done
endef

define EPICS_BASE_INSTALL_INIT_SYSV
$(INSTALL) -m 644 -D $(@D)/modules/ca/src/client/S99caRepeater@ $(TARGET_DIR)/etc/init.d/S99caRepeater
$(SED) 's|@INSTALL_BIN@|/usr/lib/epics/bin/$(EPICS_BASE_T_A)|g' $(TARGET_DIR)/etc/init.d/S99caRepeater
chmod 0755 $(TARGET_DIR)/etc/init.d/S99caRepeater
endef

define EPICS_BASE_INSTALL_INIT_SYSTEMD
$(INSTALL) -m 644 -D $(@D)/modules/ca/src/client/caRepeater.service@ $(TARGET_DIR)/usr/lib/systemd/system/caRepeater.service
$(SED) 's|@INSTALL_BIN@|/usr/lib/epics/bin/$(EPICS_BASE_T_A)|g' $(TARGET_DIR)/usr/lib/systemd/system/caRepeater.service
endef

$(eval $(generic-package))
