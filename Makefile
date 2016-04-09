# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

rsvg_command = rsvg-convert
composite_command = composite
convert_command = convert

srcdir = ./src
objdir = ./xpi-build
addon_icon_svg = src/icon.svg
about_base_png = src/about-base.png

all: addon

$(srcdir)/iceweasel_logo.png: $(srcdir)/iceweasel_logo.svg
	$(rsvg_command) -w 256 -o $@ $<

GENERATED = $(srcdir)/iceweasel_logo.png

$(srcdir)/about-wordmark.svg: $(srcdir)/wordmark.xsl $(srcdir)/iceweasel_logo.svg
	xsltproc -o $@ $^

GENERATED += $(srcdir)/about-wordmark.svg

# Make it reproducible
$(srcdir)/about.png: $(srcdir)/iceweasel_logo.png $(srcdir)/about-base.png
	composite -compose src-over -gravity center -geometry +0-26 $^ - | \
	convert - -define png:exclude-chunk=time +set date:create +set date:modify $@

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

$(srcdir)/icon16.png $(srcdir)/icon32.png $(srcdir)/icon48.png $(srcdir)/icon64.png $(srcdir)/icon128.png: $(srcdir)/iceweasel_icon.svg
	rsvg-convert -w $(SIZE) -h $(SIZE) -o $@ $<

GENERATED += $(srcdir)/icon16.png $(srcdir)/icon32.png $(srcdir)/icon48.png $(srcdir)/icon64.png $(srcdir)/icon128.png

$(srcdir)/about-logo.png: $(srcdir)/iceweasel_icon.svg
	rsvg-convert -w 210 -h 210 -o $@ $<

$(srcdir)/about-logo@2x.png: $(srcdir)/iceweasel_icon.svg
	rsvg-convert -w 420 -h 420 -o $@ $<

GENERATED += $(srcdir)/about-logo.png $(srcdir)/about-logo@2x.png

addon: $(GENERATED)
	mkdir -p $(objdir)/chrome
	cp $(srcdir)/xpi/* $(objdir)
	cp $(srcdir)/addon_icon.png $(objdir)/icon.png
	cp $(srcdir)/addon_icon64.png $(objdir)/icon64.png
	cp -r $(srcdir)/locale $(srcdir)/content $(objdir)/chrome
	cp $(srcdir)/icon16.png $(srcdir)/icon32.png $(srcdir)/icon48.png $(srcdir)/icon64.png $(srcdir)/icon128.png $(srcdir)/about.png $(srcdir)/about-wordmark.svg $(srcdir)/about-logo.png $(srcdir)/about-logo@2x.png $(objdir)/chrome/content

clean:
	rm -f $(GENERATED)
	rm -fr $(objdir)

