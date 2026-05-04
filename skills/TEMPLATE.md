---
name: {nombre-en-minusculas-con-guiones}
description: >
  {Una línea: qué hace esta skill — ej. "TypeScript and React conventions for this project."}.
  Trigger: {Cuándo cargarla — ej. "When writing TypeScript, React components, or modifying .ts/.tsx files."}.
license: MIT
metadata:
  version: "1.0"
---

## Critical Patterns

<!--
  Estas son las reglas que el AI inyecta en cada sub-agente cuando la skill matchea.
  El skill-registry extrae esta sección para generar las compact rules.
  Máximo 15 reglas. Solo lo accionable: "hacer X", "nunca Y", "preferir Z sobre W".
-->

- {Regla 1 — ej. "Use strict TypeScript (noImplicitAny: true, strict: true)"}
- {Regla 2 — ej. "Functional components only — no class components"}
- {Regla 3}
- {Regla 4}
- {Regla 5}

## Code Examples

<!--
  Ejemplos mínimos que ilustran los patrones críticos.
  Solo lo necesario para que el AI entienda el patrón.
  Si el ejemplo necesita más de 20 líneas, es demasiado largo.
-->

```{lenguaje}
// Ejemplo de patrón correcto
```

```{lenguaje}
// Ejemplo de patrón incorrecto (con comentario de por qué)
```

## Commands

<!--
  Comandos del stack que el AI puede necesitar ejecutar.
  Incluí test runner, linter, formatter, build.
-->

```bash
# Correr tests
{comando}

# Linter
{comando}

# Formatter
{comando}

# Build
{comando}
```
