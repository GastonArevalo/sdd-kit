# SDD Kit — OpenSpec Edition

Spec-Driven Development para Claude Code y VS Code Copilot, sin dependencias externas. Todos los artefactos viven como archivos en tu repositorio dentro de `openspec/`.

---

## Qué es esto

Este kit te da el ciclo completo de SDD: explorar → proponer → especificar → diseñar → desglosar → implementar → verificar → archivar. Cada fase genera documentos legibles que sirven como contrato entre el equipo y el asistente de IA.

**No necesitás instalar ninguna herramienta adicional.** Solo el asistente de IA y los archivos de este kit.

---

## Prerequisitos

| Herramienta | Versión mínima | Cómo verificar |
|---|---|---|
| **Claude Code** (CLI o desktop app) | Cualquier versión reciente | `claude --version` |
| **— o —** | | |
| **VS Code** con extensión **GitHub Copilot Chat** | VS Code 1.90+ | Ver extensiones instaladas |
| **Cuenta de Anthropic o GitHub Copilot** | Con acceso a Claude / Copilot | — |

Claude Code se descarga desde [claude.ai/code](https://claude.ai/code).

---

## Qué hay en este kit

```
sdd-kit/
├── README.md                      ← esta guía
├── CLAUDE-sdd-orchestrator.md     ← bloque de orquestador para CLAUDE.md (Claude Code)
├── CLAUDE-persona.md              ← bloque de persona para CLAUDE.md (opcional)
├── sdd.instructions.md            ← archivo de instrucciones para VS Code Copilot
├── install.ps1                    ← instalador automático (Windows — Claude Code y VS Code Copilot)
│
├── commands/                      ← slash commands de Claude Code
│   ├── sdd-init.md
│   ├── sdd-explore.md
│   ├── sdd-new.md
│   ├── sdd-apply.md
│   ├── sdd-verify.md
│   ├── sdd-archive.md
│   ├── sdd-ff.md
│   └── sdd-onboard.md
│
├── sdd-init.md                    ← skill files (instrucciones de cada fase)
├── sdd-explore.md
├── sdd-propose.md
├── sdd-spec.md
├── sdd-design.md
├── sdd-tasks.md
├── sdd-apply.md
├── sdd-apply-strict-tdd.md
├── sdd-verify.md
├── sdd-verify-strict-tdd.md
├── sdd-archive.md
├── sdd-onboard.md
├── skill-creator.md               ← skill opcional: guía al AI para crear nuevas skills
├── work-unit-commits.md           ← skill: commits por unidades de trabajo
├── chained-pr.md                  ← skill: PRs encadenados para cambios grandes
├── judgment-day.md                ← skill: revisión adversarial con dos jueces paralelos
├── _shared-*.md                   ← archivos compartidos entre fases
│
└── skills/                        ← skills opcionales de tech stack
    └── TEMPLATE.md                ← template para crear skills propias
```

Los skill files (`sdd-init.md`, `sdd-explore.md`, etc.) se usan en **ambos agentes**. Los archivos `CLAUDE-*` son específicos de Claude Code. `sdd.instructions.md` es específico de VS Code Copilot.

---

## Instalación

### Opción A — Script automático (Windows)

```powershell
# Desde la carpeta del kit
.\install.ps1
```

El script te pregunta para cuál agente instalar (Claude Code, VS Code Copilot, o ambos), copia los archivos a los destinos correctos, y te indica los pasos manuales restantes.

> **macOS / Linux**: el instalador automático no está incluido. Seguí la Opción B (manual).

---

### Opción B — Manual

Seguí la sección correspondiente a tu agente.

---

## Instalación para Claude Code

### Paso 1: Copiar los skill files

Destino: `~/.claude/skills/` (crear la carpeta si no existe)

```
~/.claude/skills/
├── _shared/
│   ├── openspec-convention.md     ← de _shared-openspec-convention.md
│   ├── persistence-contract.md    ← de _shared-persistence-contract.md
│   ├── sdd-phase-common.md        ← de _shared-sdd-phase-common.md
│   └── skill-resolver.md          ← de _shared-skill-resolver.md
├── sdd-init/
│   └── SKILL.md                   ← de sdd-init.md
├── sdd-explore/
│   └── SKILL.md                   ← de sdd-explore.md
├── sdd-propose/
│   └── SKILL.md                   ← de sdd-propose.md
├── sdd-spec/
│   └── SKILL.md                   ← de sdd-spec.md
├── sdd-design/
│   └── SKILL.md                   ← de sdd-design.md
├── sdd-tasks/
│   └── SKILL.md                   ← de sdd-tasks.md
├── sdd-apply/
│   ├── SKILL.md                   ← de sdd-apply.md
│   └── strict-tdd.md              ← de sdd-apply-strict-tdd.md
├── sdd-verify/
│   ├── SKILL.md                   ← de sdd-verify.md
│   └── strict-tdd-verify.md       ← de sdd-verify-strict-tdd.md
├── sdd-archive/
│   └── SKILL.md                   ← de sdd-archive.md
└── sdd-onboard/
    └── SKILL.md                   ← de sdd-onboard.md
```

> Los archivos del kit tienen nombres con prefijo (`sdd-init.md`) para mantenerlos en una sola carpeta. Al copiarlos, renombralos a `SKILL.md` dentro de la subcarpeta correspondiente.

### Paso 2: Copiar los slash commands

Destino: `~/.claude/commands/` (crear si no existe)

Copiar todo el contenido de la carpeta `commands/` a `~/.claude/commands/`. Los nombres no cambian.

### Paso 3: Configurar CLAUDE.md

`~/.claude/CLAUDE.md` es el archivo de instrucciones globales que Claude Code lee en todas las conversaciones.

**¿Dónde está?**
- Windows: `C:\Users\{tu-usuario}\.claude\CLAUDE.md`
- macOS/Linux: `~/.claude/CLAUDE.md`

Si no existe, crealo vacío.

#### Bloque 1: Orquestador SDD (REQUERIDO)

Copiá el contenido de `CLAUDE-sdd-orchestrator.md` y pegalo al final de tu CLAUDE.md, rodeado de estos marcadores:

```markdown
<!-- sdd:orchestrator -->
[contenido de CLAUDE-sdd-orchestrator.md]
<!-- /sdd:orchestrator -->
```

Sin este bloque, Claude no sabe cómo coordinar las fases de SDD.

#### Bloque 2: Persona (OPCIONAL)

Copiá el contenido de `CLAUDE-persona.md` y pegalo ANTES del bloque del orquestador:

```markdown
<!-- sdd:persona -->
[contenido de CLAUDE-persona.md]
<!-- /sdd:persona -->
```

### Verificar

Abrí Claude Code en cualquier proyecto y ejecutá `/sdd-init`. Deberías ver:
- Detección del stack del proyecto
- Creación de `openspec/config.yaml`
- Creación de `openspec/specs/` y `openspec/changes/`

---

## Instalación para VS Code Copilot

### Paso 1: Copiar los skill files

Destino: `~/.copilot/skills/` (Windows: `C:\Users\{tu-usuario}\.copilot\skills\`)

La estructura es idéntica a la de Claude Code, pero en otra carpeta:

```
~/.copilot/skills/
├── _shared/
│   ├── openspec-convention.md
│   ├── persistence-contract.md
│   ├── sdd-phase-common.md
│   └── skill-resolver.md
├── sdd-init/
│   └── SKILL.md
... (misma estructura)
```

Copiá los mismos archivos con la misma estructura que en el Paso 1 de Claude Code.

### Paso 2: Instalar el archivo de instrucciones

Copiá `sdd.instructions.md` a:

- Windows: `C:\Users\{tu-usuario}\AppData\Roaming\Code\User\prompts\sdd.instructions.md`
- macOS: `~/Library/Application Support/Code/User/prompts/sdd.instructions.md`

Este archivo activa el orquestador SDD en todos los chats de VS Code Copilot automáticamente.

### Paso 3: Habilitar instrucciones en VS Code

Abrí VS Code y habilitá la siguiente configuración:

```
File > Preferences > Settings
Buscar: github.copilot.chat.codeGeneration.useInstructionFiles
Activar: ✓ (true)
```

Sin esto, VS Code no lee el archivo de instrucciones.

### Verificar

Abrí Copilot Chat en VS Code y escribí `/sdd-init`. Debería aparecer en el autocomplete y ejecutar la inicialización.

---

## Cómo funciona el sistema

### Claude Code — tres capas

```
~/.claude/CLAUDE.md
└── Le dice a Claude cómo COORDINAR (orquestador + persona)

~/.claude/commands/sdd-*.md
└── Los slash commands que usás para arrancar cada fase

~/.claude/skills/sdd-*/SKILL.md
└── Las instrucciones detalladas de CADA FASE
```

Cuando escribís `/sdd-apply`, Claude Code ejecuta `~/.claude/commands/sdd-apply.md`, que le dice a Claude que lea `~/.claude/skills/sdd-apply/SKILL.md` antes de escribir código.

### VS Code Copilot — dos capas

```
Code/User/prompts/sdd.instructions.md
└── Siempre activo: le dice a Copilot cómo coordinar SDD
    (equivalente al CLAUDE.md de Claude Code)

~/.copilot/skills/sdd-*/SKILL.md
└── Las instrucciones detalladas de CADA FASE
    (el nombre en el frontmatter crea el slash command /sdd-*)
```

En VS Code, los "slash commands" SDD no son archivos de comandos separados — son los **skill files mismos**. VS Code Copilot lee el campo `name: sdd-init` del frontmatter YAML de cada skill y lo expone como `/sdd-init` en el chat. Por eso no hay carpeta `commands/` para VS Code.

### Los skill files funcionan en ambos agentes

Los archivos `sdd-init.md`, `sdd-explore.md`, etc. tienen frontmatter YAML compatible con VS Code Copilot y contenido compatible con Claude Code. Son los mismos archivos para los dos destinos (`~/.claude/skills/` y `~/.copilot/skills/`).

### El orquestador

El bloque del orquestador (en CLAUDE.md para Claude Code, en `sdd.instructions.md` para VS Code) convierte al asistente en un **coordinador**: sigue el ciclo de fases SDD, aplica el Init Guard antes de cada comando, y gestiona la entrega por etapas cuando un cambio es grande.

### La persona (Claude Code)

El bloque de persona es exclusivo de Claude Code. Le da a Claude un estilo de comunicación consistente: respuestas cortas por defecto, una pregunta a la vez, tono directo. Podés editar `CLAUDE-persona.md` para ajustar el tono al estilo del equipo.

### Los archivos `_shared`

Infraestructura interna del sistema, compartida entre fases:
- `_shared-openspec-convention.md` → estructura de carpetas de `openspec/`
- `_shared-persistence-contract.md` → cómo leen y escriben artefactos las fases
- `_shared-sdd-phase-common.md` → protocolo común entre fases
- `_shared-skill-resolver.md` → cómo el orquestador inyecta contexto en sub-agentes

No los editás directamente.

### Skills de tecnología (stack-specific)

`sdd-init` detecta el stack del proyecto y construye `.atl/skill-registry.md` escaneando **todos** los directorios de skills instalados. Si el equipo tiene skills adicionales para su tecnología (TypeScript, Go, React, etc.), `sdd-init` las detecta automáticamente y el orquestador las inyecta en las fases relevantes.

**Las skills de tecnología NO vienen con este kit** — son capas adicionales que cada equipo instala por separado según su stack. El kit de SDD provee el ciclo; las skills de stack agregan las convenciones específicas.

---

## El ciclo SDD

```
/sdd-init           → inicializar el proyecto (una sola vez)
/sdd-new <nombre>   → explorar una idea y crear la propuesta
/sdd-ff <nombre>    → fast-forward: propuesta → specs → diseño → tareas
/sdd-apply          → implementar las tareas
/sdd-verify         → verificar que la implementación cumple las specs
/sdd-archive        → cerrar el cambio y actualizar las specs principales
```

O faseado:
```
/sdd-explore <tema>   → investigar antes de comprometerse
/sdd-apply            → implementar tareas pendientes
/sdd-verify           → correr la verificación
/sdd-archive          → archivar y actualizar specs
```

Para aprender el workflow de cero, usá `/sdd-onboard`.

### Estructura de artefactos que genera

```
openspec/
├── config.yaml                       ← config del proyecto (stack, strict_tdd, etc.)
├── specs/                            ← fuente de verdad: specs principales
│   └── {dominio}/
│       └── spec.md
└── changes/
    ├── {nombre-del-cambio}/           ← cambio activo
    │   ├── proposal.md
    │   ├── specs/{dominio}/spec.md
    │   ├── design.md
    │   ├── tasks.md
    │   └── verify-report.md
    └── archive/
        └── 2026-05-03-{nombre}/       ← cambios completados
```

Todo esto va en tu repositorio y tiene historial de git.

---

## Skills incluidas de workflow

El kit incluye tres skills de workflow que complementan directamente el ciclo SDD. Se instalan automáticamente junto con las skills de fases.

### `work-unit-commits`

**Trigger**: cuando el AI prepara commits o planifica PRs.

Enseña a estructurar commits como unidades de trabajo entregables en lugar de agrupar por tipo de archivo (`models`, luego `services`, luego `tests`). Cada commit incluye tests y docs de la funcionalidad que verifica. Se integra con el Review Workload Forecast de `sdd-tasks`: si el cambio supera 400 líneas, los commits se organizan como slices de PR antes de implementar.

### `chained-pr`

**Trigger**: cuando un PR supera 400 líneas cambiadas o `sdd-tasks` recomienda chained PRs.

Define el protocolo completo para dividir cambios grandes en PRs encadenados o apilados. Incluye dos estrategias (Stacked PRs to main vs Feature Branch Chain), los requisitos de autonomía de cada PR, el diagrama de dependencias obligatorio, y el template de "Chain Context" para el cuerpo del PR. Sin esta skill, el equipo recibe la recomendación de encadenar PRs pero no sabe cómo.

### `judgment-day`

**Trigger**: cuando el usuario pide "judgment day", "dual review", o "revisión adversarial".

Protocolo de revisión con dos sub-agentes jueces que trabajan en paralelo de forma independiente — ninguno sabe del otro. El orquestador sintetiza sus veredictos, clasifica los hallazgos (CRITICAL / WARNING real / WARNING teórico / SUGGESTION), y lanza un Fix Agent solo para los confirmados. Itera hasta que ambos jueces aprueban o el usuario decide escalar.

> **Requiere agent mode**: `judgment-day` usa delegación a sub-agentes. Funciona en Claude Code con agent mode habilitado. En VS Code Copilot requiere Copilot Agent Mode.

---

## Crear skills de tecnología propias

Las skills de tech stack NO vienen con el kit — el ciclo SDD funciona sin ellas, pero si el equipo tiene convenciones de código específicas (TypeScript estricto, patrones de testing, reglas de arquitectura), una skill las convierte en instrucciones que el AI aplica automáticamente en cada fase.

### Cómo funciona la inyección

Cuando el orquestador lanza un sub-agente para `sdd-apply` en un archivo `.ts`, busca en el skill registry una skill con un Trigger que matchee `.ts` o "TypeScript". Si la encuentra, inyecta sus reglas compactas en el prompt del sub-agente. El sub-agente aplica las convenciones del equipo sin que nadie tenga que recordárselas.

### Crear una skill nueva

Copiá el template y completalo:

```
skills/TEMPLATE.md  ← punto de partida
```

El campo más importante es el `Trigger:` dentro de `description`:

```yaml
description: >
  TypeScript and React conventions for this project.
  Trigger: When writing TypeScript, React components, or modifying .ts/.tsx files.
```

Reglas del trigger:
- Mencioná extensiones de archivo (`.ts`, `.tsx`, `.go`, `.py`)
- Mencioná acciones relevantes ("writing", "testing", "reviewing")
- Sé específico — si es muy vago, matchea todo y ensucia todos los prompts

### Instalar una skill custom

Guardá tu skill como `{nombre}.md` en la carpeta `skills/` del kit. El script de instalación la detecta automáticamente (todo `.md` en `skills/` excepto `TEMPLATE.md` se instala).

O instalala manualmente:

```powershell
# Claude Code
$name = "typescript"  # cambiá por el nombre de tu skill
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills\$name"
Copy-Item ".\skills\$name.md" "$env:USERPROFILE\.claude\skills\$name\SKILL.md"

# VS Code Copilot
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.copilot\skills\$name"
Copy-Item ".\skills\$name.md" "$env:USERPROFILE\.copilot\skills\$name\SKILL.md"
```

Después de instalar, corré `/sdd-init` en el proyecto para que el registry la detecte.

### skill-creator (opcional)

El kit incluye `skill-creator.md` — una skill que enseña al AI el formato y te guía para crear nuevas skills. Si la instalás, podés escribir "create a skill for our TypeScript conventions" en el chat y el AI generará el archivo correcto.

El instalador pregunta si la querés incluir.

---

## Personalizar la persona (Claude Code)

El archivo `CLAUDE-persona.md` tiene varios bloques que podés adaptar:

**`## Rules`** — reglas de comportamiento (largo de respuestas, una pregunta a la vez, etc.)
**`## Language`** — idioma y tono de comunicación
**`## Expertise`** — áreas de especialidad que Claude debe priorizar
**`## Skills (Auto-load)`** — skills que Claude carga automáticamente según el contexto del código

Si tu equipo trabaja en React con TypeScript y tiene skills instaladas para eso, las agregás en la tabla de `Skills`. Si el idioma del equipo es inglés, ajustás `## Language`.

> **Importante**: La persona vive en `~/.claude/CLAUDE.md`, que es global. Cada miembro del equipo tiene que agregar el bloque a su propio CLAUDE.md.

---

## Troubleshooting

### Claude Code

**`/sdd-init` no aparece en el autocomplete**
→ Verificá que `~/.claude/commands/sdd-init.md` existe

**`/sdd-init` aparece pero falla**
→ Verificá que `~/.claude/skills/sdd-init/SKILL.md` existe y tiene contenido (más de 3KB)

**Claude no coordina las fases (hace todo en línea sin delegar)**
→ El bloque de orquestador no está en CLAUDE.md. Revisá los marcadores `<!-- sdd:orchestrator -->` y `<!-- /sdd:orchestrator -->`.

**`openspec/` se crea pero `config.yaml` está vacío**
→ Ejecutá `/sdd-init` de nuevo.

### VS Code Copilot

**`/sdd-init` no aparece en el autocomplete**
→ Verificá que `~/.copilot/skills/sdd-init/SKILL.md` existe. Reiniciá VS Code después de copiar los archivos.

**El orquestador SDD no está activo (Copilot no sigue las fases)**
→ Verificá que `Code\User\prompts\sdd.instructions.md` existe y que la configuración `github.copilot.chat.codeGeneration.useInstructionFiles` está en `true`.

**Las fases no guardan artefactos entre sesiones**
→ VS Code Copilot no tiene sub-agentes con herramientas de filesystem en modo chat estándar. Verificá que estás usando **Agent Mode** en Copilot Chat (el ícono de agente en el chat). Sin agent mode, las fases corren inline y no pueden escribir archivos.

### Ambos agentes

**¿Cómo actualizo el kit cuando haya nuevas versiones?**
→ Reemplazá los archivos del kit y volvé a correr `install.ps1`. El CLAUDE.md y `sdd.instructions.md` los actualizás a mano (reemplazás el contenido entre los marcadores o el archivo completo).
