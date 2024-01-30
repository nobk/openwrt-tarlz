#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tarlz
PKG_VERSION:=0.25
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.lz
PKG_SOURCE_URL:=http://download.savannah.gnu.org/releases/lzip/$(PKG_NAME)
PKG_HASH:=7d0bbe9c3a137bb93a10be56988fcf7362e4dbc65490639edc4255b704105fce
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later

PKG_BUILD_DEPENDS:=plzip/host

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/tarlz
	SECTION:=utils
	CATEGORY:=Utilities
	SUBMENU:=Compression
	TITLE:=parallel tar archiver and lzip compressor
	URL:=https://www.nongnu.org/lzip/tarlz.html
	DEPENDS:= $(CXX_DEPENDS) +lzlib +libpthread
endef

define Package/tarlz/description
 Tarlz is a massively parallel (multi-threaded) combined implementation of the tar archiver and the lzip compressor. Tarlz creates, lists, and extracts archives in a simplified and safer variant of the POSIX pax format compressed with lzip, keeping the alignment between tar members and lzip members. The resulting multimember tar.lz archive is fully backward compatible with standard tar tools like GNU tar, which treat it like any other tar.lz archive. Tarlz can append files to the end of such compressed archives.
endef

HOST_BUILD_DEPENDS:=lzlib/host plzip/host
HOST_CONFIGURE_ARGS += \
        CXXFLAGS+="-I$(STAGING_DIR_HOSTPKG)/include" \
	LDFLAGS="-L$(STAGING_DIR_HOSTPKG)/lib -L$(TOOLCHAIN_DIR)/lib"

CONFIGURE_VARS += CXXFLAGS="$$$$CXXFLAGS -fno-rtti -I$(TOOLCHAIN_DIR)/include"
CONFIGURE_ARGS += CXXFLAGS="-Wall -W -O3 -I$(TOOLCHAIN_DIR)/include"

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)/
	mkdir -p $(PKG_BUILD_DIR)/
	$(STAGING_DIR_HOST)/bin/plzip -dc $(DL_DIR)/$(PKG_SOURCE) | $(TAR) -xf - -C $(PKG_BUILD_DIR) --strip 1
	$(Build/Patch)
endef

define Host/Prepare
	rm -rf $(HOST_BUILD_DIR)/
	mkdir -p $(HOST_BUILD_DIR)/
	$(STAGING_DIR_HOST)/bin/plzip -dc $(DL_DIR)/$(PKG_SOURCE) | $(TAR) -xf - -C $(HOST_BUILD_DIR) --strip 1
	$(Build/Patch)
endef

define Package/tarlz/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin
	$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)strip -s $(1)/usr/bin/$(PKG_NAME)
endef

define Host/Install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/$(PKG_NAME) $(STAGING_DIR_HOST)/bin/
	$(STAGING_DIR_HOST)/bin/sstrip $(STAGING_DIR_HOST)/bin/$(PKG_NAME)
endef

$(eval $(call BuildPackage,tarlz))
$(eval $(call HostBuild))
