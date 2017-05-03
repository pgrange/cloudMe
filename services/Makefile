PREFIX=/etc/systemd/system
INSTALL=install

SERVICE_OPTS=-o root -g kvm -m 0644
SERVICE= $(wildcard *.service)

.PHONY: all $(SERVICE)

all: $(SERVICE)
	@systemctl enable nocloud-bridge --now
	@systemctl enable nocloud-dnsmasq --now

$(SERVICE):
	$(INSTALL) $(SINSTALL_OPTS) $@ $(PREFIX)/$@
	@systemctl daemon-reload
