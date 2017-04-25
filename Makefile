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

.PHONY: all $(BIN) $(LIB) $(SBIN) $(ETC)

all: $(BIN) $(LIB) $(SBIN) $(ETC)
	@echo +++ checking prerequisites
	@./.prerequisites

$(BIN):
	$(INSTALL) $(INSTALL_OPTS) $@ $(PREFIX)/$@

$(LIB):
	$(INSTALL) $(LINSTALL_OPTS) $@ $(PREFIX)/$@

$(SBIN):
	$(INSTALL) $(SINSTALL_OPTS) $@ $(PREFIX)/$@

$(ETC):
	$(INSTALL) $(CINSTALL_OPTS) $@ $(PREFIX)/$@
