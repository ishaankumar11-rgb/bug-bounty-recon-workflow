# Recon Methodology

A phase-by-phase pipeline. The goal of phases 1 to 4 is not to find bugs.
It is to build an accurate map of the attack surface, so that phase 5 can be
focused instead of random.

---

## Phase 0 — Before touching anything

1. Read the program policy fully. Note the out-of-scope list.
2. Confirm scope in writing for anything ambiguous.
3. Set up two isolated browser profiles (Account A and Account B).
4. Start Burp with logging enabled from the first request.
5. Create a per-target working folder.

---

## Phase 1 — Passive subdomain enumeration

Zero traffic to the target. Only public data sources.

- `subfinder -d example.com -all`
- `assetfinder --subs-only example.com`
- Certificate transparency logs (crt.sh)

Certificate transparency catches hosts that subdomain APIs miss, including
internal-sounding names that would otherwise go unnoticed.

---

## Phase 2 — Resolve and map CNAMEs

- `dnsx -l all.txt -a -resp`
- `dnsx -l all.txt -cname -resp`

CNAME records are the input for subdomain takeover testing. A CNAME pointing
to a deprovisioned cloud resource is a candidate. But a candidate is not a
finding until claimability has been verified, and the host is production.

---

## Phase 3 — Live host triage

- `httpx -l resolved.txt -status-code -title -tech-detect -rl 20`

Then sort by likely value. Authenticated applications first:

```
graphql | api | portal | console | dashboard | admin | account | project
```

Marketing pages, blogs, and documentation almost never produce a valid finding.

---

## Phase 4 — JavaScript crawl (the highest-value step)

Guessing endpoint names is a waste of time. Applications publish their own API
surface in their JavaScript bundles.

- Crawl with `katana -jc -d 2`
- Download every `.js` file
- Extract `/api/v1/...` paths and `{id}` templates

This gives real endpoints like `/api/v1/user/{id}/projects` instead of guessed
ones like `/api/v1/projects`. The `{id}` templates are the access-control test
cases, and they are the reason this phase matters.

---

## Phase 5 — Manual testing (where findings come from)

Two accounts, always. Cross-account access is the highest-value bug class in
multi-tenant SaaS, and it cannot be tested with one identity.

### Access control

- Replace your resource ID with your second account's resource ID
- Compare the 200 response against the 403 or 404 response
- Test both read (GET) and write (PUT, PATCH, DELETE)

### Authentication

- Token scope: does a read-only token allow writes?
- Session invalidation: does logout actually invalidate the session?
- Password reset flow: token predictability, host header handling

### Business logic

- Negative values, zero, extremely large values
- Skipping steps in a multi-step flow
- Race conditions on limited resources, carefully, never enough to cause DoS

### CORS

Only a finding when both headers are present:

```
Access-Control-Allow-Origin: https://attacker.example
Access-Control-Allow-Credentials: true
```

Echoing the origin without credentials is not exploitable.

---

## Phase 6 — Proof of concept and report

1. Reproduce in Burp Repeater, not just in a script
2. Screenshot the full request and response
3. Stop testing. One confirming request is enough.
4. Write the report with a clear impact statement
5. Submit through the channel the program specifies, usually a form and not email

---

## What I do not do

| Technique | Why not |
|---|---|
| sqlmap, dalfox, or full nuclei templates on production | Policy violation, DoS risk, rejected reports |
| ID enumeration loops | Accesses other users' data |
| High-volume fuzzing above 5 requests per second | Counts as high volume automated scanning |
| Login brute force | Explicitly prohibited everywhere |
| Reporting scanner output without a proof of concept | Ineligible at almost every program |
