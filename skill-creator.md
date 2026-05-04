---
name: skill-creator
description: >
  Creates new AI agent skills following the skill spec — frontmatter, compact rules, full patterns.
  Trigger: When user asks to create a new skill, document patterns for AI, or add agent instructions for a tech stack.
license: MIT
metadata:
  version: "1.0"
---

## Cuándo crear una skill

Creá una skill cuando:
- Un patrón se usa repetidamente y el AI necesita guía específica del equipo
- Las convenciones del proyecto difieren de las mejores prácticas genéricas
- Un workflow complejo necesita instrucciones paso a paso
- El equipo tiene reglas de código que el AI debe seguir en todo el proyecto

**No creés una skill cuando:**
- La documentación ya existe (referenciala en lugar de duplicarla)
- El patrón es trivial o evidente del código
- Es una tarea de una sola vez

---

## Cómo funciona una skill en el ciclo SDD

Cuando instalás una skill y corrés `/sdd-init`, el skill registry la detecta automáticamente:

1. Lee el frontmatter → extrae el `Trigger:`
2. Lee el contenido → genera **compact rules** (5-15 líneas)
3. Escribe ambas cosas en `.atl/skill-registry.md`

El orquestador lee el registry y cuando lanza un sub-agente que toca archivos relevantes, inyecta esas compact rules en el prompt. El sub-agente aplica las reglas del equipo sin leer el archivo original.

---

## Estructura de una skill

```
~/.claude/skills/{nombre}/
└── SKILL.md          ← archivo principal (el único requerido)
```

Para VS Code Copilot, el mismo archivo en `~/.copilot/skills/{nombre}/SKILL.md`.

---

## Template de SKILL.md

```markdown
---
name: {nombre-en-minusculas-con-guiones}
description: >
  {Una línea: qué hace esta skill}.
  Trigger: {Cuándo el AI debe cargarla — patrones de archivo, keywords, acciones}.
license: MIT
metadata:
  version: "1.0"
---

## Critical Patterns

{Las reglas más importantes — qué DEBE aplicar el AI. Máximo 15 reglas.}

- Regla 1
- Regla 2
- ...

## Code Examples

{Ejemplos mínimos y enfocados que ilustran los patrones críticos}

## Commands

\`\`\`bash
{Comandos comunes de este tech stack}
\`\`\`
```

---

## Convenciones de nombres

| Tipo | Patrón | Ejemplos |
|------|--------|---------|
| Tecnología genérica | `{tecnología}` | `typescript`, `pytest`, `react` |
| Específico del proyecto | `{proyecto}-{componente}` | `myapp-api`, `myapp-ui` |
| Testing específico | `{proyecto}-test-{componente}` | `myapp-test-e2e` |
| Workflow | `{acción}-{objetivo}` | `branch-pr`, `work-unit-commits` |

---

## El campo Trigger (crítico)

El trigger es lo que el orchestrator usa para decidir cuándo inyectar la skill. Debe ser específico:

**Malo** (demasiado vago):
```
Trigger: When writing code.
```

**Bueno** (específico y matcheable):
```
Trigger: When writing TypeScript, React components, or modifying .ts/.tsx files.
```

```
Trigger: When writing Go tests, using testify, or adding test coverage to .go files.
```

```
Trigger: When creating a pull request, opening a PR, or preparing changes for review.
```

El orchestrator matchea el trigger contra:
- **Code context**: extensiones de archivo que toca el sub-agente
- **Task context**: palabras clave de la acción ("write", "test", "review", "create PR")

---

## Guía de contenido

### SÍ
- Empezá con los patrones más críticos (el AI los lee en orden)
- Usá tablas para árboles de decisión
- Ejemplos de código mínimos — solo lo necesario para entender el patrón
- Incluí los comandos más usados del stack

### NO
- No duplices documentación que ya existe (referenciala)
- No pongas explicaciones largas (el AI no necesita el "por qué", necesita las reglas)
- No agregues secciones de troubleshooting
- No pongas URLs externas en references (usá paths locales)

---

## Cómo instalar una skill nueva

Una vez creada:

```powershell
# Claude Code (Windows)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills\{nombre}"
Copy-Item ".\{nombre}.md" "$env:USERPROFILE\.claude\skills\{nombre}\SKILL.md"

# VS Code Copilot (Windows)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.copilot\skills\{nombre}"
Copy-Item ".\{nombre}.md" "$env:USERPROFILE\.copilot\skills\{nombre}\SKILL.md"
```

Después de instalar, corré `/sdd-init` en el proyecto para que el registry la detecte.

---

## Checklist antes de crear

- [ ] La skill no existe ya (revisá los directorios de skills)
- [ ] El patrón es reutilizable, no one-off
- [ ] El nombre sigue las convenciones
- [ ] El frontmatter está completo (el `Trigger:` es específico)
- [ ] Los critical patterns son ≤ 15 reglas accionables
- [ ] Los ejemplos de código son mínimos y enfocados
