# Spring Boot Hexagonal Starter for GitHub Copilot

A Spring Boot microservice starter for building hexagonal applications with a spec-driven development workflow. The repository includes GitHub Copilot instructions, reusable agent skills, custom review agents, and optional Copilot hooks under `.github/`.

## Prerequisites

- **Java 21** — available from [Adoptium](https://adoptium.net/) or [SDKMAN](https://sdkman.io/).
- **GitHub Copilot** — use a supported Copilot client with agent skills enabled, such as agent mode in VS Code or GitHub Copilot CLI. See [Copilot agent skills](https://docs.github.com/copilot/concepts/agents/about-agent-skills).
- **PowerShell 7+ on Windows** — needed by the Windows Copilot hook commands.
- **jq on macOS/Linux** — needed by the Bash Copilot hook scripts.
- **Docker (optional)** — only needed if you want to run PostgreSQL locally using Docker.

Maven is provided by the wrapper; no separate Maven installation is needed.

## Copilot customizations

- `.github/copilot-instructions.md` contains repository-wide conventions, architecture guidance, build commands, and the feature workflow.
- `.github/instructions/*.instructions.md` contains path-scoped rules for domain, money, persistence, web, and test code.
- `.github/skills/` contains the `discover`, `accept`, `tdd`, `review`, `commit-summary`, and `quality-check` workflows. Skills include their supporting references and templates.
- `.github/agents/*.agent.md` contains focused architecture, spec-compliance, and mutation-report reviewers.
- `.github/hooks/` contains optional session context and protected-file guard hooks. These are supported in Copilot CLI and Copilot cloud-agent environments; IDE support depends on the client and version. The shell-command scan is best-effort, not a security sandbox.

Use the skills by asking Copilot to run the named workflow, for example: “Use the discover skill for this user story…”. For feature development, follow **Discover → Accept → TDD → Review**. The first three skills stop at their review gates and wait for your direction before proceeding.

## Architecture and development conventions

- **Hexagonal architecture** — domain code stays framework-free; adapters depend on application ports, which depend on the domain.
- **Money handling** — use `BigDecimal`, scale 2, and explicit `RoundingMode.HALF_EVEN`; never use `float`, `double`, or `int` for money.
- **Persistence** — PostgreSQL is the production database. Flyway migrations own the schema; Hibernate validates it and does not create it.
- **Specs as the source of truth** — when a feature spec exists under `doc/specs/`, tests verify its rules and examples before production code is written.
- **Tests** — plain JUnit + AssertJ for domain logic, `@DataJpaTest` for repositories, `@WebMvcTest` for controllers, and `@SpringBootTest` for acceptance tests.

## Useful commands

```powershell
.\mvnw.cmd test
.\mvnw.cmd verify
.\mvnw.cmd '-Dtest=ApplicationTests#contextLoads' test
.\mvnw.cmd spring-boot:run
.\mvnw.cmd clean package
```

On macOS/Linux, use `./mvnw` instead of `.\mvnw.cmd`. Tests use H2; `verify` also runs acceptance tests ending in `IT`.

### Running locally with PostgreSQL

`spring-boot:run` needs a PostgreSQL instance. Configure the connection with
Spring Boot's `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, and
`SPRING_DATASOURCE_PASSWORD` environment variables. To start PostgreSQL with Docker:

```bash
docker run --name demo-app-pg -e POSTGRES_DB=demo_app \
  -e POSTGRES_USER=demo_app -e POSTGRES_PASSWORD=demo_app -p 5432:5432 -d postgres:17
```

## Copilot workflow examples

- **New feature:** “Use the `discover` skill to map this story: As a customer, I want…”
- **Next spec rule:** “Use the `accept` skill for the next rule in `doc/specs/<feature>.md`.”
- **One inner TDD cycle:** “Use the `tdd` skill to drive `ClassName#methodName`.”
- **Review before commit:** “Use the `review` skill on the current feature changes.”
- **Quality pipeline:** “Use the `quality-check` skill and write the consolidated report.”
- **Change summary:** “Use the `commit-summary` skill for this branch.”
