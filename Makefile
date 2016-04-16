# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This Makefile does not build a .xpi archive. It has no `install' target.

rsvg_command = rsvg-convert
composite_command = composite
convert_command = convert
xsltproc_command = xsltproc
INSTALL = install

srcdir = ./src
objdir = ./xpi-build

all: addon

$(srcdir)/iceweasel_logo.png: $(srcdir)/iceweasel/iceweasel_logo.svg
	$(rsvg_command) -w 256 -o $@ $<

GENERATED = $(srcdir)/iceweasel_logo.png

$(srcdir)/about-wordmark.svg: $(srcdir)/iceweasel/wordmark.xsl $(srcdir)/iceweasel/iceweasel_logo.svg
	$(xsltproc_command) -o $@ $^

GENERATED += $(srcdir)/about-wordmark.svg

# Make it reproducible
$(srcdir)/about.png: $(srcdir)/iceweasel_logo.png $(srcdir)/iceweasel/about-base.png
	$(composite_command) -compose src-over -gravity center -geometry +0-26 $^ - | \
	$(convert_command) - -define png:exclude-chunk=time +set date:create +set date:modify $@

GENERATED += $(srcdir)/about.png

# 2x resolution
$(srcdir)/addon_icon.png: SIZE=96
$(srcdir)/addon_icon64.png: SIZE=128

$(srcdir)/addon_icon.png: $(srcdir)/addon_icon.svg
	$(rsvg_command) -w $(SIZE) -o $@ $<

$(srcdir)/addon_icon64.png: $(srcdir)/addon_icon.svg
	$(rsvg_command) -w $(SIZE) -o $@ $<

GENERATED += $(srcdir)/addon_icon.png $(srcdir)/addon_icon64.png

$(srcdir)/icon16.png: SIZE=16
$(srcdir)/icon32.png: SIZE=32
$(srcdir)/icon48.png: SIZE=48
$(srcdir)/icon64.png: SIZE=64
$(srcdir)/icon128.png: SIZE=128

$(srcdir)/icon16.png $(srcdir)/icon32.png $(srcdir)/icon48.png $(srcdir)/icon64.png $(srcdir)/icon128.png: $(srcdir)/iceweasel/iceweasel_icon.svg
	$(rsvg_command) -w $(SIZE) -h $(SIZE) -o $@ $<

GENERATED += $(srcdir)/icon16.png $(srcdir)/icon32.png $(srcdir)/icon48.png $(srcdir)/icon64.png $(srcdir)/icon128.png

$(srcdir)/about-wordmark.png: $(srcdir)/about-wordmark.svg
	$(rsvg_command) -o $@ $<

$(srcdir)/about-logo.png: $(srcdir)/iceweasel/iceweasel_icon.svg
	$(rsvg_command) -w 210 -h 210 -o $@ $<

$(srcdir)/about-logo@2x.png: $(srcdir)/iceweasel/iceweasel_icon.svg
	$(rsvg_command) -w 420 -h 420 -o $@ $<

GENERATED += $(srcdir)/about-wordmark.png $(srcdir)/about-logo.png $(srcdir)/about-logo@2x.png

addon: $(GENERATED)
	mkdir -p $(objdir)/chrome
	cp $(srcdir)/xpi/* $(objdir)
	cp $(srcdir)/addon_icon.png $(objdir)/icon.png
	cp $(srcdir)/addon_icon64.png $(objdir)/icon64.png
	cp -r $(srcdir)/iceweasel/locale $(srcdir)/iceweasel/content $(objdir)/chrome
	cp $(srcdir)/icon16.png $(srcdir)/icon32.png $(srcdir)/icon48.png $(srcdir)/icon64.png $(srcdir)/icon128.png $(srcdir)/about.png $(srcdir)/about-wordmark.png $(srcdir)/about-wordmark.svg $(srcdir)/about-logo.png $(srcdir)/about-logo@2x.png $(objdir)/chrome/content

clean:
	rm -f $(GENERATED) ./*.xpi
	rm -fr $(objdir)

