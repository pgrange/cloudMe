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

.PHONY: all $(BIN) $(LIB) $(SBIN) $(ETC) system

prerequisites:
	@echo +++ checking prerequisites
	@tools/prerequisites

all: prerequisites $(BIN) $(LIB) $(SBIN) $(ETC) system

$(BIN):
	$(INSTALL) $(INSTALL_OPTS) $@ $(PREFIX)/$@

$(LIB):
	$(INSTALL) $(LINSTALL_OPTS) $@ $(PREFIX)/$@

$(SBIN):
	$(INSTALL) $(SINSTALL_OPTS) $@ $(PREFIX)/$@

$(ETC):
	$(INSTALL) $(CINSTALL_OPTS) $@ $(PREFIX)/$@

system:
	@tools/qemu-bridge
	@tools/kvm-mod
	@echo +++ installing service
	@cd services && make
