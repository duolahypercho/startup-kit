# UI templates

Visual reference layouts for building product surfaces on the kit theme. These are
inspiration boards, not code — match the layout, density, and information hierarchy,
then implement with the kit's tokens, type scale, and shadcn/ui primitives.

| File | Surface | Use it for |
| --- | --- | --- |
| `issue-tracker.png` | Dense issue list with left nav, grouped rows, inline metadata | Project/task tools, list-heavy dashboards, admin tables |
| `calendar-planner.png` | Week calendar + task sidebar, time-blocked events | Scheduling, planners, time-based views |
| `finance-dashboard.png` | Overview cards, trend chart, recent activity, KPIs | Analytics dashboards, finance/metrics overviews |
| `ai-chat.png` | Conversation canvas with left thread nav and composer | AI assistants, chat-first products, doc generation |

All four favor quiet, dense, tool-like UI — the kit default. Keep accent color
restrained, lean on the neutral intent colors, and pull color through tokens
(`assets/theme/`), never hardcoded hex.
