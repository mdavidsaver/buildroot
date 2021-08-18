################################################################################
#
# linux_iio_bpm
#
################################################################################

LINUX_IIO_BPM_VERSION = $(subst ",, $(BR2_LINUX_IIO_BPM_REV))
LINUX_IIO_BPM_SITE = $(call github,mdavidsaver,linux_iio_bpm,$(LINUX_IIO_BPM_VERSION))
LINUX_IIO_BPM_LICENSE = GPL-2.0
LINUX_IIO_BPM_LICENSE_FILES = LICENSE

$(eval $(kernel-module))
$(eval $(generic-package))
