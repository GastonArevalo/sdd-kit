# SDD Kit — OpenSpec Edition

> Spec-Driven Development para Claude Code y VS Code Copilot, sin dependencias externas.

Cada fase del ciclo genera artefactos legibles en `openspec/` que viven en tu repositorio como contratos entre el equipo y el asistente de IA.

---

## ¿Qué es?

SDD Kit convierte a tu asistente de IA en un coordinador disciplinado de cambios de software. En lugar de generar código sin contrato, el asistente sigue un ciclo estructurado:

```
explorar → proponer → especificar → diseñar → desglosar → implementar → verificar → archivar
```

Cada fase produce documentos en `openspec/` que sirven como evidencia, trazabilidad y punto de recuperación entre sesiones.

---

## Prerequisitos

| Herramienta | Mínimo | Verificar |
|---|---|---|
| **Claude Code** (CLI o desktop) | Cualquier versión reciente | `claude --version` |
| — o — | | |
| **VS Code** + extensión **GitHub Copilot Chat** | VS Code 1.90+ | Ver extensiones |
| Cuenta **Anthropic** o **GitHub Copilot** | Con acceso activo | — |

Claude Code → [claude.ai/code](https://claude.ai/code)

---

## Instalación

### Opción A — Script automático (Windows)

```powershell
.\install.ps1
```

El script pregunta para qué agente instalar (Claude Code, VS Code Copilot, o ambos), copia los archivos a los destinos correctos, e indica los pasos manuales restantes.

> macOS / Linux: instalación manual — ver guía completa en [`docs/install-manual.md`](docs/install-manual.md) *(próximamente)*

---

### Opción B — Manual

<details>
<summary><strong>Claude Code</strong></summary>

**1. Skill files** → `~/.claude/skills/`

```
~/.claude/skills/
├── _shared/
│   ├── openspec-convention.md
│   ├── persistence-contract.md
│   ├── sdd-phase-common.md
│   └── skill-resolver.md
├── sdd-init/SKILL.md
├── sdd-explore/SKILL.md
├── sdd-propose/SKILL.md
├── sdd-spec/SKILL.md
├── sdd-design/SKILL.md
├── sdd-tasks/SKILL.md
├── sdd-apply/
│   ├── SKILL.md
│   └── strict-tdd.md
├── sdd-verify/
│   ├── SKILL.md
│   └── strict-tdd-verify.md
└── sdd-archive/SKILL.md
```

Los archivos del kit tienen prefijo (`sdd-init.md`). Al copiarlos, renombralos a `SKILL.md` dentro de cada subcarpeta.

**2. Slash commands** → `~/.claude/commands/`

Copiar todo el contenido de la carpeta `commands/` sin cambiar los nombres.

**3. CLAUDE.md** → `~/.claude/CLAUDE.md`

Agregar el contenido de `CLAUDE-sdd-orchestrator.md` dentro de estos marcadores:

```markdown
<!-- sdd:orchestrator -->
[contenido de CLAUDE-sdd-orchestrator.md]
<!-- /sdd:orchestrator -->
```

Opcionalmente, agregar `CLAUDE-persona.md` ANTES del bloque del orquestador:

```markdown
<!-- sdd:persona -->
[contenido de CLAUDE-persona.md]
<!-- /sdd:persona -->
```

**Verificar**: abrir Claude Code en cualquier proyecto y ejecutar `/sdd-init`.

</details>

<details>
<summary><strong>VS Code Copilot</strong></summary>

**1. Skill files** → `~/.copilot/skills/`

Misma estructura que Claude Code, pero en `~/.copilot/skills/`.

**2. Archivo de instrucciones**

Copiar `sdd.instructions.md` a:
- Windows: `C:\Users\{usuario}\AppData\Roaming\Code\User\prompts\`
- macOS: `~/Library/Application Support/Code/User/prompts/`

**3. Habilitar instrucciones en VS Code**

```
File > Preferences > Settings
→ github.copilot.chat.codeGeneration.useInstructionFiles = true
```

**Verificar**: abrir Copilot Chat y escribir `/sdd-init`.

</details>

---

## Comandos

### Flujo completo

```bash
/sdd-init              # inicializar el proyecto (una sola vez)
/sdd-new <nombre>      # explorar una idea y crear la propuesta
/sdd-ff <nombre>       # fast-forward: specs → diseño → tareas (en paralelo)
/sdd-apply             # implementar las tareas
/sdd-verify            # verificar que la implementación cumple las specs
/sdd-archive           # cerrar el cambio y actualizar las specs principales
```

### Continuar donde quedó

```bash
/sdd-continue          # retoma automáticamente desde la última fase guardada
```

### Aprender el workflow

```bash
/sdd-onboard           # walkthrough guiado con tu codebase real
```

---

## Artefactos generados

```
openspec/
├── config.yaml                        ← stack, strict_tdd, reglas del proyecto
├── specs/
│   └── {dominio}/spec.md              ← fuente de verdad (specs principales)
└── changes/
    ├── {nombre-del-cambio}/
    │   ├── state.yaml                 ← fase actual + última actualización
    │   ├── proposal.md
    │   ├── specs/{dominio}/spec.md
    │   ├── design.md
    │   ├── tasks.md                   ← [x] progreso de implementación
    │   └── verify-report.md
    └── archive/
        └── 2026-05-03-{nombre}/       ← cambios completados
```

Todo vive en tu repositorio con historial de git. Specs escritas antes del código, verificables post-implementación.

---

## Skills incluidas

| Skill | Cuándo activa | Para qué |
|---|---|---|
| `work-unit-commits` | Al preparar commits o PRs | Commits como unidades entregables (código + tests + docs juntos) |
| `chained-pr` | PRs > 400 líneas | Protocolo para dividir cambios grandes en PRs encadenados |
| `judgment-day` | "dual review" / "revisión adversarial" | Dos jueces independientes en paralelo; sintetiza y parchea hallazgos confirmados |
| `skill-creator` | "create a skill for..." | Guía al AI para crear nuevas skills con el formato correcto |

> `judgment-day` requiere agent mode (Claude Code o VS Code Copilot Agent Mode).

---

## Skills de tech stack (opcionales)

El ciclo SDD funciona sin ellas. Pero si el equipo tiene convenciones específicas (TypeScript, Go, React), una skill las convierte en instrucciones que el AI aplica automáticamente en cada fase relevante.

Las skills de stack **no vienen con el kit** — cada equipo las crea según su stack. El template está en `skills/TEMPLATE.md`. Una vez instalada, `/sdd-init` la detecta y el orquestador la inyecta donde corresponde.

Instalación manual:

```powershell
# Claude Code
$name = "typescript"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills\$name"
Copy-Item ".\skills\$name.md" "$env:USERPROFILE\.claude\skills\$name\SKILL.md"

# Luego re-ejecutar /sdd-init para actualizar el registry
```

---

## Troubleshooting

| Síntoma | Causa probable | Solución |
|---|---|---|
| `/sdd-init` no aparece en autocomplete (CC) | Falta `~/.claude/commands/sdd-init.md` | Copiar la carpeta `commands/` |
| `/sdd-init` aparece pero falla (CC) | Falta `~/.claude/skills/sdd-init/SKILL.md` | Verificar que el archivo existe y tiene contenido |
| Claude no delega fases | Falta el bloque de orquestador en CLAUDE.md | Verificar marcadores `<!-- sdd:orchestrator -->` |
| `config.yaml` queda vacío | Ejecución incompleta de init | Correr `/sdd-init` de nuevo |
| `/sdd-init` no aparece en autocomplete (VS Code) | Falta skill o requiere reinicio | Verificar `~/.copilot/skills/sdd-init/SKILL.md`, reiniciar VS Code |
| Orquestador inactivo en VS Code | Instrucciones no cargadas | Verificar ruta de `sdd.instructions.md` y setting `useInstructionFiles` |
| Las fases no guardan artefactos (VS Code) | Sin agent mode | Usar **Agent Mode** en Copilot Chat |

**¿Cómo actualizar el kit?** Reemplazar los archivos y volver a correr `install.ps1`. CLAUDE.md y `sdd.instructions.md` se actualizan a mano (reemplazar el contenido entre marcadores).
