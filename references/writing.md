# Writing And Microcopy

UI copy is part of the interface. Write it with the same restraint as the layout.

## Voice

Plain, direct, and specific. Talk like a knowledgeable colleague, not a brand.

- Use the user's words for the user's objects ("project", "invoice"), not internal jargon.
- Prefer the active voice and present tense.
- Cut filler: "please", "simply", "just", "in order to", "successfully".
- Write sentence case for everything: buttons, labels, titles, menus. No Title Case, no ALL CAPS.

## Buttons And Actions

- Name the result with a verb: "Create project", "Send invite", "Delete file".
- Avoid "Submit", "OK", and "Yes/No". Echo the action: "Delete" / "Keep".
- Keep it to one to three words.

## Labels And Fields

- Name the object, not the interface: "Email", not "Enter your email here".
- Mark the rare optional field; assume the rest are required.
- Helper text explains constraints ("Used for sign-in"), not the obvious.

## Empty, Error, Success

- Empty: state what's missing and the one next step. "No projects yet. Create your first project."
- Error: what failed + how to recover. "Couldn't save. Check your connection and try again." Never expose codes or stack traces to users.
- Success: confirm the result, not the act. "Invite sent to ada@example.com."

## Numbers, Dates, Units

- Use locale-aware formatting (`Intl.NumberFormat`, `Intl.DateTimeFormat`).
- Use relative time for recency ("2 minutes ago"), absolute for records (full date on hover).
- Always show units and currency. Never a bare number where it's ambiguous.

## Inclusive And Honest

- No dark patterns. Confirmations state the real consequence.
- Avoid idioms and humor that don't translate.
- Don't overpromise ("instantly", "guaranteed") unless it's literally true.

## Before Done

- Remove all placeholder/lorem copy.
- Read each string aloud; if it sounds like marketing inside a tool, cut it.
- Check that every button, empty state, and error has been written, not defaulted.
