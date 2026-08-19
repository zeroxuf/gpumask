PREFIX ?= /usr/local
BINDIR := $(DESTDIR)$(PREFIX)/bin
COMPDIR := $(DESTDIR)$(PREFIX)/share/bash-completion/completions

.PHONY: install uninstall

install:
	install -Dm755 bin/gpumask     $(BINDIR)/gpumask
	install -Dm755 bin/gpumask-run $(BINDIR)/gpumask-run
	install -Dm644 completions/gpumask.bash $(COMPDIR)/gpumask
	@echo ""
	@echo "Installed to $(BINDIR)."
	@echo "Make sure $(PREFIX)/bin is on your PATH, then run: gpumask --help"

uninstall:
	rm -f $(BINDIR)/gpumask $(BINDIR)/gpumask-run $(COMPDIR)/gpumask
