PREFIX=/etc/systemd/system
INSTALL=install

SERVICE_OPTS=-o root -g kvm -m 0644
SERVICE= $(wildcard *.service)

.PHONY: all $(SERVICE)

all: $(SERVICE)
	@systemctl enable nocloud-bridge
	@systemctl enable nocloud-dnsmasq
	@systemctl start nocloud-bridge
	@systemctl start nocloud-dnsmasq

$(SERVICE):
	$(INSTALL) $(SINSTALL_OPTS) $@ $(PREFIX)/$@
	@../tools/service_devar
	@systemctl daemon-reload
