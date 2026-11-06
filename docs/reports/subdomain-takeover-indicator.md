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
```

No further exploitation was attempted, in line with the program's restriction
on claiming cloud resources.

---

## Impact (as reported)

If an attacker provisioned a new Azure App Service and bound this custom
domain, they could serve arbitrary content under a subdomain of a
defence-industrial-base contractor. This could support phishing against
employees or partners who trust the domain.

---

## Why it was closed as informational

The triager's reasoning, and what I took from it:

| Reason | Lesson |
|---|---|
| Host was a test subdomain | Test and staging hosts are commonly out of scope. Check the policy's environment exclusions first. |
| Only an indicator, not a verified takeover | Dangling DNS is a precondition. A valid report needs confirmation that the cloud resource is actually claimable. |
| CDN error 1016 is misconfiguration, not takeover | An origin DNS error means the origin is missing, not that a resource is claimable by anyone. |

---

## What I do differently now

1. Confirm the subdomain is production, not test, dev, or stage
2. Verify the cloud resource is genuinely unclaimed and claimable
3. Check the program's takeover-specific rules before writing the report
4. If a program prohibits claiming resources, ask whether an indicator report
   is still in scope before submitting
