# Subdomain takeover indicator via dangling Azure DNS

**Program:** Public VDP on HackerOne
**Target:** Redacted
**Outcome:** Informational (closed)
**Date:** October 2026

---

## Summary

A host under the program's scope resolved through a CDN provider, but the
underlying origin forwarded to a Microsoft Azure App Service that did not have
the custom domain configured. Requesting the host returned Azure's default
"404 Web Site not found" page with the text:

> Custom domain has not been configured inside Azure.

Several other hosts on the same domain returned CDN error 1016 (origin DNS
error), suggesting the same underlying issue across multiple hosts.

---

## Steps to reproduce

```bash
dig extranetregistration.test.redacted.com
# resolves to CDN anycast IPs

curl -sI https://extranetregistration.test.redacted.com/
# HTTP/2 404, server: cloudflare

curl -s https://extranetregistration.test.redacted.com/
# response body contains Azure App Service default error page:
#   "404 Web Site not found."
#   "Custom domain has not been configured inside Azure."
