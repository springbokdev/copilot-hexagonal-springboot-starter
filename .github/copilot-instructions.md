# Project instructions

This repository is a Spring Boot microservice starter using hexagonal architecture and spec-driven development.

## Build and test

- Java 21 is required; see `pom.xml`.
- Use the Maven Wrapper, not a separately installed Maven: `.\mvnw.cmd test` and `.\mvnw.cmd verify` on Windows, or `./mvnw test` and `./mvnw verify` on macOS/Linux.
- `test` runs unit tests; `verify` also runs acceptance tests named `*IT`.
- Run one test with `.\mvnw.cmd '-Dtest=ClassName#methodName' test` (use `./mvnw` on macOS/Linux).
- Running the service requires PostgreSQL. Configure it with Spring Boot's `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, and `SPRING_DATASOURCE_PASSWORD` environment variables.
- Flyway migrations own the schema. Hibernate validates the schema and must not generate it.

## Architecture

- Dependencies flow inward: adapters depend on application ports, which depend on the domain.
- Domain code is pure Java. Do not import Spring or JPA into `domain/`.
- Keep orchestration in application services and business rules in the domain.
- Web controllers are thin, use request/response DTOs, delegate to application services, and map domain exceptions to HTTP responses.
- JPA entities belong only in `adapter/out/persistence/`; never expose them outside that adapter.
- Use constructor injection. Use MapStruct in adapters for DTO and persistence conversions; keep mapper dependencies out of the domain. Use Lombok where appropriate, and use `@SuperBuilder` when a builder is needed on a subclass.

## API and testing

- Read the relevant OpenAPI contract in `doc/api/` before changing a controller or writing an acceptance test. If no contract exists, do not invent one; clarify the expected contract first.
- Domain tests use plain JUnit and AssertJ without Spring. Repository tests use `@DataJpaTest`; web tests use `@WebMvcTest`; acceptance tests use `@SpringBootTest` and MockMvc.
- Acceptance tests live under `src/test/java/.../acceptance/` and end in `IT`; other tests end in `Test`.
- Use inline test data and concrete expected values. Do not recalculate expected results in tests or change tests to make production code pass.
- Compare monetary values with `isEqualByComparingTo`; use `BigDecimal`, an explicit `RoundingMode`, and scale 2.
- Path-specific rules in `.github/instructions/` supplement these instructions.

## Feature workflow

Follow the repository skills in order for feature work; honor each skill's stop-and-wait gate:

1. Use `discover` to map a user story into business rules, examples, counter-examples, and resolved decisions. Present the draft spec and wait for approval before saving it under `doc/specs/`.
2. Use `accept` to write and run a failing acceptance test for only the next approved rule. Do not write production code in this step.
3. Use `tdd` for one RED → GREEN → REFACTOR cycle at a time. Do not weaken tests or continue to the next cycle without the user's direction.
4. Use `review` as a read-only review before committing.

For focused commit summaries or the full quality pipeline, use the matching skill in `.github/skills/`. Do not skip workflow steps or combine independent rules into one cycle.
