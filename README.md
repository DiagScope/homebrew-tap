# DiagScope

**Will this code explain itself when it breaks in production?**

DiagScope is a static analyzer for Java and Kotlin projects. It follows real call flows — REST
endpoints, Kafka consumers, scheduled jobs, reactive handlers, and plain public methods — and
reports code that silently destroys diagnostic evidence before it can reach your logs.

It does not style-check your code. Every finding is anchored to a specific entrypoint → method
chain so you see *which production path* goes blind when something breaks. It never compiles or
executes your project: it reads source files and reasons about structure.

---

## What it catches

| Category | Example finding |
|---|---|
| **Exception handling** | Catch block swallows the exception — no log, no rethrow, no stable error code |
| **Transactions** | `orderRepository.save()` without `@Transactional` — if the next write fails, the first cannot roll back |
| **HTTP resilience** | `webClient.block()` without a timeout — a slow upstream holds the thread forever |
| **Concurrency** | `future.get()` with no timeout; `HashMap` used where `ConcurrentHashMap` is needed |
| **Observability** | MDC context not propagated into async tasks; metric tag with unbounded cardinality |
| **Database** | JDBC connection opened but never closed; N+1 query inside a loop |
| **AOP / Proxy** | `@Transactional` method called from the same class — Spring proxy is bypassed |
| **Maintainability** | Class with 17 public methods; method with 7 parameters; excessive cyclomatic complexity |

44 rules. Results in Markdown, HTML, JSON, and SARIF.

---

## Install

```bash
brew tap DiagScope/tap
brew install diagscope
```

Java 25 is pulled in automatically as a dependency — nothing else to configure.

---

## Quick start

```bash
# Analyze a Spring / Quarkus / Micronaut project
diagscope scan --project /path/to/project

# Plain Java or Kotlin — no framework annotations needed
diagscope scan --project /path/to/project --entrypoint PUBLIC_METHOD

# Only findings in files changed since the base branch — useful in CI
diagscope scan --project . --changed-since origin/main --fail-on ERROR

# Understand a specific rule
diagscope explain SILENT_CATCH

# See all rules with severity and version
diagscope rules
```

Output lands in `target/diagscope/` (Maven) or `build/diagscope/` (Gradle):

```
target/diagscope/
├── report.md    ← for pull request review and terminal reading
├── report.html  ← interactive, self-contained, no network required
└── result.json  ← machine-readable for dashboards and automation
```

---

## Example report

The HTML report is interactive — filter by severity, follow flow paths from entrypoint to the
exact line with the problem, and read the fix guidance inline.

→ **[View example report](docs/example-report.html)**

---

## How it works

1. **Parse** — reads all `.java` and `.kt` files and extracts structural facts (method calls,
   catch blocks, annotations, loops) into a language-neutral model. No compilation needed.

2. **Build flows** — for each entrypoint it follows the call graph up to a configurable depth
   and collects all reachable methods into a *flow*. A flow represents one real execution path
   from the edge of the system inward.

3. **Run rules** — each rule inspects every method in every flow. Findings are never more
   confident than the path that leads to them: ambiguous resolution and depth truncation are
   reported as *flow boundaries* so you know exactly what was and was not analyzed.

---

## Suppress a finding

```java
catch (CleanupException ignored) {
    // diagscope:ignore SILENT_CATCH -- best-effort cleanup after response was committed
}
```

Vague comments and plain `// TODO` lines are not accepted as suppressions. The reason is required.

For bulk suppression of pre-existing findings, record a baseline:

```bash
diagscope scan --project . --update-baseline   # snapshot current state
diagscope scan --project . --baseline --fail-on ERROR  # gate only new findings
```

---

## Privacy and security

DiagScope is designed to be safe to run on proprietary and company codebases.

**Your code never leaves your machine.** DiagScope reads source files from the path you
specify and writes results to a local output directory. It makes no network requests during
analysis — there are no telemetry calls, no licence checks, no cloud backends.

**Nothing is collected or transmitted.** DiagScope has no analytics, no crash reporting, and
no update pings. It does not know you ran it, what project you analyzed, or what it found.

**No code is executed or compiled.** The tool reads `.java` and `.kt` source files and reasons
about their structure. It never invokes `javac`, runs your tests, or loads your application's
classes. Your build system and runtime dependencies are not touched.

**Results stay where you put them.** The output files (`report.md`, `report.html`,
`result.json`) are written to your local filesystem. Nothing is uploaded or shared unless you
choose to share them yourself.

**You can verify this.** DiagScope is a self-contained JAR. Tools like
[`Wireshark`](https://www.wireshark.org) or `sudo lsof -i -p <pid>` can confirm that no
network connections are opened while it runs. The source is available to authorised team
members on request.

---

## Update

```bash
brew update && brew upgrade diagscope
```
