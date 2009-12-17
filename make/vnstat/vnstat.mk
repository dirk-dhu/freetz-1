$(call PKG_INIT_BIN, 1.9)
$(PKG)_SOURCE:=vnstat-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ebaf8352fa3674faea2fe2ce1001a38d
$(PKG)_SITE:=http://humdi.net/vnstat
$(PKG)_BINARIES_ALL := vnstat vnstatd vnstati
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_VNSTAT_DAEMON),,vnstatd) $(if $(FREETZ_PACKAGE_VNSTAT_IMAGE),,vnstati),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBS := -lm

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_VNSTAT_DAEMON
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_VNSTAT_IMAGE

ifeq ($(strip $(FREETZ_PACKAGE_VNSTAT_IMAGE)),y)
$(PKG)_DEPENDS_ON += gd
$(PKG)_DEPENDS_ON += freetype
$(PKG)_LIBS += -lgd
$(PKG)_LIBS += -lfreetype
$(PKG)_MAKE_TARGET := all
$(PKG)_FREETYPE_CPPFLAGS:="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/freetype2"
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) $(VNSTAT_MAKE_TARGET) -C $(VNSTAT_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS) $(VNSTAT_FREETYPE_CPPFLAGS)" \
	LIBS="$(VNSTAT_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(MAKE) -C $(VNSTAT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(VNSTAT_BINARIES_ALL:%=$(VNSTAT_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
