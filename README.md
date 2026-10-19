# DiagScope

**Will this code explain itself when it breaks in production?**

DiagScope is a static analyzer for Java and Kotlin projects. It follows real call flows — REST
endpoints, Kafka consumers, scheduled jobs, reactive handlers, and plain public methods — and
reports code that silently destroys diagnostic evidence before it can reach your logs.

It does not style-check your code. Every finding is anchored to a specific entrypoint → method
chain, so you see *which production path* goes blind when something breaks. It never compiles or
executes your project: it only reads source files.

🌐 **Website:** <https://diagscope.github.io> · 📄 **[Example report](https://diagscope.github.io/example-report.html)** (rendered, no install needed)

This repository is the Homebrew tap. The analyzer itself lives in
[DiagScope/diagscope](https://github.com/DiagScope/diagscope).

---

## Contents

- [Install](#install)
- [Try it in 5 minutes](#try-it-in-5-minutes)
- [Collecting the reports](#collecting-the-reports)
- [Reading a report](#reading-a-report)
- [Useful options](#useful-options)
- [Setting the tolerance: the gate](#setting-the-tolerance-the-gate)
- [Using it in CI](#using-it-in-ci)
- [Using it in a Maven build](#using-it-in-a-maven-build)
- [Using it with AI coding assistants](#using-it-with-ai-coding-assistants)
- [Suppressing findings](#suppressing-findings)
- [Troubleshooting](#troubleshooting)
- [Privacy and security](#privacy-and-security)
- [Update and uninstall](#update-and-uninstall)

---

## Install

You need [Homebrew](https://brew.sh) (macOS or Linux). Java 17 is installed automatically as a
dependency — there is nothing else to configure.

```bash
brew tap DiagScope/tap
brew install diagscope
```

Check that it works:

```bash
diagscope --version
```

---

## Try it in 5 minutes

Run these from any Java or Kotlin project (Maven or Gradle layout). No build step is required and
nothing is compiled.

**1. Check what DiagScope understands about the project** (optional, but the quickest way to spot
a setup problem):

```bash
diagscope doctor --project /path/to/project
```

It lists the build system, the source roots, the languages found, and which framework rules will
apply.

**2. Scan it:**

```bash
diagscope scan --project /path/to/project
```

**3. Open the report:**

```bash
open /path/to/project/target/diagscope/report.html        # macOS (Maven)
xdg-open /path/to/project/build/diagscope/report.html     # Linux (Gradle)
```

**4. Start with the top of the report.** *Fix these first* is ranked by severity, confidence and
how many runtime flows the finding sits on. For any rule you do not recognise:

```bash
diagscope explain SILENT_CATCH
```

It prints what the rule means, why it matters, how it is detected, and what to do about it.

**Plain library, or no framework annotations?** By default the entrypoints are REST endpoints,
Kafka listeners, reactive messaging handlers and scheduled jobs. For anything else, treat every
public method as an entrypoint:

```bash
diagscope scan --project /path/to/project --entrypoint PUBLIC_METHOD
```

`--entrypoint` replaces the default list, so for an application where you want both, name them all:
`--entrypoint REST,KAFKA_LISTENER,REACTIVE_MESSAGE,SCHEDULED,PUBLIC_METHOD`.

**Browse the rules.** The catalog grows with every release, so ask the tool instead of a document:

```bash
diagscope rules                  # every rule, with severity and version
diagscope rules --format JSON    # the same, for scripts
```

---

## Collecting the reports

Each scan writes its files to `target/diagscope/` (Maven) or `build/diagscope/` (Gradle), inside the
analyzed project:

| File | What it is for |
|---|---|
| `report.html` | Interactive and self-contained: open it in a browser, no network or server. Filter by severity and confidence, group by flow or file, and follow the call path to the exact line. |
| `report.md` | Plain text for pull-request comments and terminal reading. |
| `result.json` | Machine-readable result with a versioned schema, for dashboards, automation and comparing two runs. |
| `result.sarif` | For GitHub code scanning and other SARIF viewers (add `--format SARIF`). |

By default you get `report.md`, `report.html` and `result.json`. Pick the ones you want and where
they go:

```bash
diagscope scan --project . --output ~/diagscope-reports/orders --format HTML,JSON,SARIF
```

An absolute `--output` is used as given; a relative one is resolved inside the project.

### Several projects at once

```bash
for project in ~/work/orders ~/work/payments ~/work/catalog; do
  diagscope scan --project "$project" \
    --output "$HOME/diagscope-reports/$(basename "$project")" \
    --format HTML,JSON
done
```

You end up with one folder per project, each with its own `report.html` and `result.json`.

### Comparing two runs

Keep the `result.json` of a scan, change the code, scan again, then:

```bash
diagscope trend --base before/result.json --current after/result.json
```

It lists the findings that are new, fixed, and still there. Add `--format JSON` for a
machine-readable answer, or `-o trend.md` to write it to a file.

### Sharing a report

A report is a single file you can attach to a ticket or an email. Keep in mind that it contains
**source snippets and file paths from your project**, so share it only where you would share the
code itself.

---

## Reading a report

Every finding shows:

- the **rule** and its **severity** — `ERROR`, `WARNING` or `INFO`;
- the **confidence** — `HIGH`, `MEDIUM` or `LOW`. A finding is never more confident than the path
  that leads to it, so triage `HIGH` first;
- the **file and line**, with a code snippet;
- the **flow** — the entrypoint and the chain of calls that reaches the problem, e.g.
  `POST /payments/{id}/capture → PaymentService.capture → PaymentMetrics.record`;
- why it matters and how to fix it.

Where DiagScope could not follow a call (ambiguous target, external library, depth limit) it says
so as a *flow boundary* instead of guessing. That tells you what was **not** analyzed.

A scan that finds nothing does not prove the code is clean: it means none of the rules matched on
the paths DiagScope could follow.

---

## Useful options

| Option | What it does |
|---|---|
| `--project`, `-p` | Project directory (required). |
| `--output`, `-o` | Where to write the reports. |
| `--format` | Any of `MARKDOWN`, `JSON`, `HTML`, `SARIF`, `AGENT`, comma-separated. `AGENT` alone prints compact text to the terminal. |
| `--entrypoint` | Comma-separated subset of `REST`, `KAFKA_LISTENER`, `REACTIVE_MESSAGE`, `SCHEDULED`, plus `PUBLIC_METHOD` for plain code. |
| `--max-depth` | How deep to follow calls from each entrypoint (0–32, default 3). |
| `--fail-on` | Exit with code 1 when a finding of this severity or higher exists: `ERROR`, `WARNING`, `INFO`. Overrides the `gate:` of `diagscope.yml`. |
| `--fail-on-confidence` | With `--fail-on`, only findings of at least this confidence (`LOW`, `MEDIUM`, `HIGH`) count. |
| `--gate-profile` | Use a named profile from the `gate:` section of `diagscope.yml`. |
| `--files` | Only report findings in these files (comma-separated). The whole project is still analyzed. |
| `--changed-since <ref>` | Only report findings in files changed since a git ref, such as `origin/main`. |
| `--baseline` / `--update-baseline` | Ignore the findings you already have, and gate only new ones. |
| `--classpath` | Dependency JARs, to improve how Java symbols are resolved. |
| `--source-root` | Extra source directories for non-standard layouts. |
| `--config` | A `diagscope.yml` policy: disable rules, override severities, ignore paths. |

Exit codes: `0` success · `1` the gate failed (`--fail-on` or `gate:`) · `2` invalid configuration or scanner
failure · `3` unsupported project structure. Without `--fail-on` or a `gate:`, exit code `0` does **not** mean
"no findings".

The full reference is in the
[CLI documentation](https://github.com/DiagScope/diagscope/blob/main/docs/CLI.md).

---

## Setting the tolerance: the gate

`--fail-on ERROR` is the simplest gate. When it is too blunt, describe the tolerance in `diagscope.yml`, so
it is versioned and reviewed with the code:

```yaml
schemaVersion: "1.0"
gate:
  failOn:                       # a finding breaks the build when it matches ANY entry
    - severity: ERROR
      confidence: HIGH          # minimums; default confidence is LOW
    - severity: INFO
      rules: [SILENT_CATCH]     # optional: only these rules
  maxFindings:                  # tolerate up to N visible findings of a severity
    WARNING: 20
  profiles:                     # alternatives that replace the gate, chosen with --gate-profile
    release:
      failOn:
        - severity: WARNING
```

```bash
diagscope scan --project .                          # the default gate
diagscope scan --project . --gate-profile release   # a stricter one for release branches
```

A failing gate prints every breached condition with its count. The gate judges the findings left after the
baseline, waivers and `--changed-since`, so on a project with a baseline it only judges what is new. An explicit
`--fail-on` always wins. Details: [CONFIGURATION.md](https://github.com/DiagScope/diagscope/blob/main/docs/CONFIGURATION.md#gate).

---

## Using it in CI

Fail the build only on findings introduced by the current change:

```bash
# once, on the main branch: record what exists today
diagscope scan --project . --update-baseline

# on every pull request: gate only new findings
diagscope scan --project . --baseline --fail-on ERROR
```

Or look only at the files a pull request touches:

```bash
diagscope scan --project . --changed-since origin/main --fail-on ERROR
```

Keep the reports as build artifacts, for example on GitHub Actions:

```yaml
- run: diagscope scan --project . --format HTML,JSON,SARIF --fail-on ERROR
- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: diagscope
    path: target/diagscope/
```

DiagScope also ships a ready-made GitHub Action; see the
[CI guide](https://github.com/DiagScope/diagscope/blob/main/docs/CI.md).

---

## Using it in a Maven build

The Maven plugin runs the scan during `mvn verify` and fails the build with the same gate as the command line, so the
tolerance in `diagscope.yml` governs the CLI, CI and the build alike. It is on Maven Central: no repository to add.

```xml
<plugin>
  <groupId>io.github.diagscope</groupId>
  <artifactId>diagscope-maven-plugin</artifactId>
  <version>0.1.8</version>
  <executions>
    <execution>
      <goals><goal>scan</goal></goals>   <!-- bound to the verify phase -->
    </execution>
  </executions>
</plugin>
```

With no gate configured the scan only reports (to `target/diagscope`). To break the build, either set the tolerance in
`diagscope.yml` (see [the gate](#setting-the-tolerance-the-gate)) or pass it on the command line:

```bash
mvn verify -Ddiagscope.failOn=ERROR -Ddiagscope.failOnConfidence=HIGH
mvn verify -Ddiagscope.gateProfile=release          # a profile of the gate: section
```

Or run it once, without editing the POM:

```bash
mvn io.github.diagscope:diagscope-maven-plugin:0.1.8:scan -Ddiagscope.failOn=ERROR
```

Good to know:

- **Maven runs on JDK 17 or newer.** Nothing else to install: the analyzer comes with the plugin (one download of about
  78 MB, cached afterwards).
- **It runs per module.** In a multi-module build each module is judged on its own, `pom` modules are skipped, and one
  `diagscope.yml` at the repository root governs them all.
- **Libraries and code no endpoint reaches:** add `-Ddiagscope.entrypoints=REST,KAFKA_LISTENER,REACTIVE_MESSAGE,SCHEDULED,PUBLIC_METHOD`
  (or the `entrypoints` parameter), as with `--entrypoint PUBLIC_METHOD` on the command line.
- **Legacy code:** record a baseline with the CLI and point `-Ddiagscope.baseline=diagscope-baseline.json` at it, so the
  build judges only new findings.

All parameters and the details:
[MAVEN_PLUGIN.md](https://github.com/DiagScope/diagscope/blob/main/docs/MAVEN_PLUGIN.md).

---

## Using it with AI coding assistants

When a team generates code with an assistant, run DiagScope before the assistant declares the work done. Set it
up once per project:

```bash
diagscope init-agent --project .
```

It only adds, and it is safe to run again:

- a marked block in `AGENTS.md` (read by most assistants) and `CLAUDE.md` telling the assistant to run
  `diagscope scan --format AGENT --entrypoint ...,PUBLIC_METHOD --files <changed files>` before finishing, to fix the cause, and not to add
  `diagscope:ignore` comments, waivers, baseline entries or overrides without asking you;
- for Claude Code, a `Stop` hook (`.claude/hooks/diagscope-stop.sh`) that scans the changed Java and Kotlin files
  when a task ends and hands the findings back once, plus its registration in `.claude/settings.json`. Your other
  settings are kept.

`--format AGENT` is plain text made to be read by a model: the worst finding first, one `fix:` line each, at
most 30, about 3 KB where the Markdown report is 22 KB.

```text
ERROR HIGH SILENT_CATCH src/main/java/example/PaymentListener.java:6
  Exception is caught and ignored.
  fix: Log, propagate, preserve the cause, ...
```

What to expect, honestly:

- The automatic hook exists for Claude Code only. Other assistants read `AGENTS.md` and may run the command, but
  nothing forces them to.
- Without `PUBLIC_METHOD` among the entrypoints, code that no endpoint, listener or job reaches is not checked at
  all. The generated instructions and hook include it.
- A scan costs 1 to 15 seconds whatever the number of changed files, because the whole project is analyzed. That is
  why the check runs once at the end of a task and not after every edit.
- An assistant told to fix findings may "fix" a false positive, so the hook only blocks on ERROR findings of `HIGH`
  confidence (and honours `diagscope-baseline.json` when it exists, so legacy findings in a file it touched do not
  block it). To change that, define a profile in `diagscope.yml` and run
  `diagscope init-agent --gate-profile assistant`. Read what an assistant changes in response anyway.

---

## Suppressing findings

When a finding is intentional, say why — vague comments and plain `// TODO` lines are not accepted:

```java
catch (CleanupException ignored) {
    // diagscope:ignore SILENT_CATCH -- best-effort cleanup after the response was committed
}
```

For many pre-existing findings at once, record a baseline (see [Using it in CI](#using-it-in-ci)). For a reviewed
per-finding decision, add a waiver to `diagscope.yml` with a reason and an optional expiry date
([details](https://github.com/DiagScope/diagscope/blob/main/docs/CONFIGURATION.md#reviewed-waivers)).

---

## Troubleshooting

| Symptom | What to try |
|---|---|
| `0 flows` or very few findings | No entrypoint was recognised. Run `diagscope doctor`, and for plain code add `--entrypoint PUBLIC_METHOD`. |
| Exit code `3` | The project layout is not a conventional Maven or Gradle one. Point `--project` at the module root, or add `--source-root`. |
| Calls into your own libraries show as flow boundaries | Pass the dependency JARs with `--classpath`. |
| `command not found: diagscope` | `brew install diagscope`, then open a new terminal. |
| An old version after an update | `brew update && brew upgrade diagscope`, and check with `diagscope --version`. |
| A finding you disagree with | Read `diagscope explain <RULE_ID>`, suppress it with a reason if it is intentional, and tell us — a false positive is a bug in the rule. |

Questions and bug reports: [DiagScope/diagscope issues](https://github.com/DiagScope/diagscope/issues).

---

## Privacy and security

DiagScope is designed to be safe to run on proprietary and company codebases.

**Your code never leaves your machine.** DiagScope reads source files from the path you specify and
writes results to a local output directory. It makes no network requests during analysis — there
are no telemetry calls, no licence checks, no cloud backends.

**Nothing is collected or transmitted.** There is no analytics, no crash reporting and no update
ping. It does not know you ran it, what project you analyzed, or what it found.

**No code is executed or compiled.** It reads `.java` and `.kt` files and reasons about their
structure. It never invokes `javac`, runs your tests, or loads your application's classes.

**Results stay where you put them.** `report.html`, `report.md`, `result.json` and `result.sarif`
are written to your local filesystem, and nothing is uploaded unless you share them yourself.

**You can verify this.** DiagScope is a self-contained JAR. Tools like
[Wireshark](https://www.wireshark.org) or `sudo lsof -i -p <pid>` can confirm that no network
connections are opened while it runs.

---

## Update and uninstall

```bash
brew update && brew upgrade diagscope     # update
brew uninstall diagscope                  # remove
brew untap DiagScope/tap                  # remove the tap as well
```
