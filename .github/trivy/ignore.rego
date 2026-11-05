package trivy

import rego.v1

default ignore := false

# linux-libc-dev is the kernel headers package, so every kernel CVE is attributed to it. A container
# runs the host's kernel, never the one these headers describe. The package cannot be removed:
# libc6-dev depends on it and the PECL extension builds need libc6-dev.
ignore if input.PkgName == "linux-libc-dev"
