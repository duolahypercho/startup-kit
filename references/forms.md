# Forms

Build forms with shadcn/ui `Form` on top of `react-hook-form` and `zod`. Do not hand-roll validation or error markup.

## Setup

```bash
npx shadcn@latest add form input label select textarea checkbox switch
npm install react-hook-form zod @hookform/resolvers
```

## Rule

Validate on the schema, show one clear error per field, and never block the user from typing.

- Define the schema once with `zod` and infer the type.
- Validate on submit and on blur, not on every keystroke.
- Keep the label, control, and message in one `FormItem`.
- Disable the submit button while the request is in flight; never disable inputs mid-typing.
- Show server errors inline against the field that caused them, with a form-level fallback for everything else.

## Example

```tsx
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import {
  Form, FormControl, FormField, FormItem, FormLabel, FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";

const schema = z.object({
  email: z.string().email("Enter a valid email."),
  name: z.string().min(1, "Name is required."),
});

type Values = z.infer<typeof schema>;

export function SignUpForm({ onSubmit }: { onSubmit: (v: Values) => Promise<void> }) {
  const form = useForm<Values>({
    resolver: zodResolver(schema),
    defaultValues: { email: "", name: "" },
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input placeholder="Ada Lovelace" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" placeholder="ada@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Creating account…" : "Create account"}
        </Button>
      </form>
    </Form>
  );
}
```

## Server Errors

Map a failed request back onto fields, then fall back to a form-level message:

```tsx
try {
  await createAccount(values);
} catch (err) {
  if (isFieldError(err)) {
    form.setError(err.field, { message: err.message });
  } else {
    form.setError("root", { message: "Something went wrong. Try again." });
  }
}
```

## Product Defaults

- Use one column. Multi-column forms only when fields are short and paired (e.g. city/zip).
- Use real labels above inputs. Placeholders are examples, not labels.
- Mark optional fields, not required ones, when most fields are required.
- Use action verbs on the submit button that name the result ("Create account", not "Submit").
- Keep helper text short and below the input.
- Validate destructive or irreversible actions with a typed confirmation, not just a dialog.
