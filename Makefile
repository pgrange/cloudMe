PREFIX=/usr/local
INSTALL=install

INSTALL_OPTS=-o root -g kvm -m 0755
BIN= $(wildcard bin/*)

LINSTALL_OPTS=-o root -g kvm -m 0644
LIB= $(wildcard lib/*)

CINSTALL_OPTS=-o root -g kvm -m 0644
ETC= $(wildcard etc/*)

SINSTALL_OPTS=-o root -g kvm -m 0755
SBIN= $(wildcard sbin/*)

.PHONY: all $(BIN) $(LIB) $(SBIN)

all: $(BIN) $(LIB) $(SBIN) $(ETC)
	@echo +++ checking prerequisites
	@./.prerequisites

$(BIN): bin_msg
	$(INSTALL) $(INSTALL_OPTS) $@ $(PREFIX)/$@

bin_msg:
	@echo +++ installing binaries

$(LIB): lib_msg
	$(INSTALL) $(LINSTALL_OPTS) $@ $(PREFIX)/$@

lib_msg:
	@echo +++ installing libraries

$(SBIN): sbin_msg
	$(INSTALL) $(SINSTALL_OPTS) $@ $(PREFIX)/$@

sbin_msg:
	@echo +++ installing superuser binaries

$(ETC): etc_msg
	$(INSTALL) $(CINSTALL_OPTS) $@ $(PREFIX)/$@

etc_msg:
	@echo +++ installing configuration files
