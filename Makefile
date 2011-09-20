PREFIX = /usr/local/bin

SCRIPT = difff.sh
FILE_PATH = $(CURDIR)/$(SCRIPT)
INSTALL_FILE_PATH = $(PREFIX)/$(basename $(SCRIPT))

test:
	$(CURDIR)/test.sh

.PHONY: $(INSTALL_FILE_PATH)
$(INSTALL_FILE_PATH):
	cp $(FILE_PATH) $(INSTALL_FILE_PATH)

.PHONY: install
install: $(INSTALL_FILE_PATH)

include tools.mk
