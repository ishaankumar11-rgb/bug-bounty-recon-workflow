# Bug Bounty Recon & Reporting Workflow

My repeatable methodology for **authorized** web application security testing.
Every technique here has been used only on programs where I had explicit
written permission.

I focus on **manual testing** (Burp Suite, OWASP WSTG) rather than automated
scanners, because a finding without a working proof of concept is not a finding.

---

## What's in this repo

| Path | Contents |
|---|---|
| `docs/methodology.md` | Full recon pipeline, phase by phase |
| `reports/` | Redacted example of a report I have written |

---

## Pipeline at a glance

1. **Passive enumeration** — subfinder, assetfinder, crt.sh (zero traffic to target)
2. **Resolve and CNAME map** — dnsx (takeover candidates)
3. **Live host triage** — httpx (find auth and API apps)
4. **JavaScript crawl** — katana (extract real endpoints, never guess)
5. **Manual testing** — Burp Suite (access control, auth, business logic)
6. **Proof of concept** — Burp Repeater (screenshot, stop, report)

**Step 5 is where the work happens.** Steps 1 to 4 only tell me where to look.

---

## Rules I follow

These are not optional. They come from the program policies I work under:

- No automated scanners against production without a manual proof of concept
- Rate limits: 5 requests per second maximum, 30 threads maximum, always
- Only my own test accounts, never another user's data
- Stop immediately if I encounter real user data, and report it
- No DoS, no brute force, no social engineering
- No public disclosure without written permission from the program
- Written scope confirmation before testing anything ambiguous

---

## Tools

**Recon:** subfinder, assetfinder, dnsx, httpx, katana, crt.sh

**Testing:** Burp Suite (Repeater, Intruder, Logger++), curl, jq

**Reference:** OWASP WSTG, PortSwigger Web Security Academy

---

## Background

Independent security researcher. Web application and API security, with a
manual testing focus. Active on HackerOne VDP programs.

- **HackerOne:** [@ishaankumar_rgb](https://hackerone.com/ishaankumar_rgb)
- **LinkedIn:** [ishaan-kumar-giri-rgb](https://www.linkedin.com/in/ishaan-kumar-giri-rgb)

---

## Disclaimer

All content here is for authorized security testing only. Techniques are
documented as methodology, not as an invitation to test systems without
permission. Testing systems you do not have written authorization for is
illegal in most jurisdictions.
