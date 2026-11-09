---
applyTo: "src/main/java/**/domain/**/*.java"
---

You are editing domain layer code.

NEVER import org.springframework.
NEVER import jakarta.persistence.
Business logic only — pure Java. Dependencies flow inward; domain depends on nothing outward.

Java 21 idioms:
records for value objects, sealed interfaces for closed hierarchies, pattern matching.
No Lombok — records replace it.
No MapStruct.
Raise domain exceptions for business-rule violations (mapped to HTTP in the web layer, never here).
Money handling: see the money rule — BigDecimal only.
Test with plain JUnit + AssertJ, no Spring.
