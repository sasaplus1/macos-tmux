.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

root := $(makefile_dir)

prefix := $(abspath $(root)/usr)

pkg_config_path := $(abspath $(prefix)/lib/pkgconfig)

libevent_version := 2.1.12
libevent_configs := $(strip \
  --disable-openssl \
  --enable-shared \
)

ncurses_version := 6.2
ncurses_configs := $(strip \
  --enable-pc-files \
  --with-pkg-config-libdir='$(pkg_config_path)' \
  --with-shared \
  --with-termlib \
)

tmux_version := 3.2
tmux_configs := $(strip \
)

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: clean
clean: ## remove files
	$(RM) -r $(root)/usr/bin/* $(root)/usr/include/* $(root)/usr/lib/* $(root)/usr/man/* $(root)/usr/share/* $(root)/usr/src/*

.PHONY: install
install: ## install tmux and dependencies
install: download-libevent install-libevent
install: download-ncurses install-ncurses
install: download-tmux install-tmux

.PHONY: download-libevent
download-libevent: ## [subtarget] download libevent archive
	curl -fsSL -o '$(root)/usr/src/libevent-$(libevent_version).tar.gz' https://github.com/libevent/libevent/releases/download/release-$(libevent_version)-stable/libevent-$(libevent_version)-stable.tar.gz

.PHONY: download-ncurses
download-ncurses: ## [subtarget] download ncurses archive
	curl -fsSL -o '$(root)/usr/src/ncurses-$(ncurses_version).tar.gz' https://invisible-mirror.net/archives/ncurses/ncurses-$(ncurses_version).tar.gz

.PHONY: download-tmux
download-tmux: ## [subtarget] download tmux archive
	curl -fsSL -o '$(root)/usr/src/tmux-$(tmux_version).tar.gz' https://github.com/tmux/tmux/releases/download/$(tmux_version)/tmux-$(tmux_version).tar.gz

.PHONY: install-libevent
install-libevent: ## [subtarget] install libevent
	$(RM) -r '$(root)/usr/src/libevent-$(libevent_version)'
	tar fvx '$(root)/usr/src/libevent-$(libevent_version).tar.gz' -C '$(root)/usr/src'
	mv '$(root)'/usr/src/libevent-$(libevent_version){-stable,}
	cd '$(root)/usr/src/libevent-$(libevent_version)' && ./configure --prefix='$(prefix)' $(libevent_configs)
	make -C '$(root)/usr/src/libevent-$(libevent_version)'
	make install -C '$(root)/usr/src/libevent-$(libevent_version)'

.PHONY: install-ncurses
install-ncurses: ## [subtarget] install ncurses
	$(RM) -r '$(root)/usr/src/ncurses-$(ncurses_version)'
	tar fvx '$(root)/usr/src/ncurses-$(ncurses_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/ncurses-$(ncurses_version)' && ./configure --prefix='$(prefix)' $(ncurses_configs)
	make -C '$(root)/usr/src/ncurses-$(ncurses_version)'
	make install -C '$(root)/usr/src/ncurses-$(ncurses_version)'

.PHONY: install-tmux
install-tmux: ## [subtarget] install tmux
	$(RM) -r '$(root)/usr/src/tmux-$(tmux_version)'
	tar fvx '$(root)/usr/src/tmux-$(tmux_version).tar.gz' -C '$(root)/usr/src/'
	cd '$(root)/usr/src/tmux-$(tmux_version)' && PKG_CONFIG_PATH='$(pkg_config_path)' ./configure --prefix='$(prefix)' $(tmux_configs) CFLAGS='-I$(prefix)/include' LDFLAGS='-L$(prefix)/lib'
	make -C '$(root)/usr/src/tmux-$(tmux_version)'
	make install -C '$(root)/usr/src/tmux-$(tmux_version)'
