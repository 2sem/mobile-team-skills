---
name: appstore-screenshot-designer
description: Use when planning or generating App Store screenshots for an iOS app listing, including slot order, overlay copy, screenshot prompts, device-safe layouts, localization, or a creative brief; escalate when final visual polish or full ASO strategy is needed.
---

# App Store Screenshot Designer

Fast App Store screenshot strategy for the main agent. Use it to turn an app's value proposition into a clear screenshot narrative, short benefit-led overlays, AI-generation-ready prompts, and a designer-ready shot list.

**Announce at start:** "Using appstore-screenshot-designer skill for this App Store screenshot plan."

## Use this skill when

- planning a new App Store screenshot set,
- refreshing screenshots for a release,
- rewriting screenshot overlay copy,
- deciding what each screenshot slot should communicate,
- preparing a creative brief for `designer`,
- reviewing whether a screenshot set tells the right story.

## Escalate when

- to `designer` for pixel-perfect production, typography/layout exploration, or final asset creation,
- to `marketer` for competitive ASO strategy, keyword positioning, or campaign-level messaging,
- to `cs` if the task depends on new review mining before messaging is chosen.

## The First 3 Screenshots Rule

The first 3 screenshots do almost all of the conversion work. Plan them before anything else.

| Slot | Job | Question it must answer |
|---|---|---|
| 1 | Core value | What does this app help me do right now? |
| 2 | Differentiator | Why choose this app over alternatives? |
| 3 | Proof of usefulness | What strong feature or outcome makes me trust it? |

If slot 1 shows settings, onboarding, or infrastructure, the set is weak.

## Story Arc Patterns

Pick one story arc before drafting captions.

### Utility / productivity
1. Solve the main problem
2. Save time or effort
3. Show the best workflow
4. Show organization or control
5. Show follow-through or reminders

### Travel / discovery
1. Discover nearby or relevant places
2. Compare or filter quickly
3. Trust the recommendations or map context
4. Show category breadth
5. Show trip-planning or seasonal relevance

### Social / creator
1. Create or connect instantly
2. Show expression or customization
3. Show social proof or engagement
4. Show standout feature
5. Show retention loop

## Overlay Copy Rules

- Lead with the user benefit, not the feature name.
- Keep each overlay to 2 lines max.
- Prefer 3-7 words for the headline.
- Use plain language a user can scan in under 2 seconds.
- One message per screenshot.

Examples:

- Bad: `Advanced Filter Options`
- Good: `Find the right place faster`
- Bad: `Push Notification System`
- Good: `Never miss a travel update`

## Layout and Readability Rules

- Make the UI the proof, not the headline dump.
- Keep strong contrast between overlay text and background.
- Do not let status-bar clutter or stale timestamps make the app look outdated.
- Use one visual system across the full set: same headline style, spacing rhythm, and brand accents.
- Highlight one primary idea per screenshot; supporting callouts are optional.
- If the UI is dense, simplify the displayed data before capture.

## Production Specs and Safe Zones

Use these when preparing screenshot assets or generation prompts.

### Common iOS portrait sizes

| Device class | Size |
|---|---|
| iPhone 6.7" | 1290 × 2796 |
| iPhone 6.5" | 1284 × 2778 |
| iPhone 5.5" | 1242 × 2208 |
| iPad 12.9" | 2048 × 2732 |

### Safe-zone rules

- Avoid placing key copy flush to the top edge; leave a generous top buffer for device chrome and visual breathing room.
- Keep headline and callout text away from the outer 8-10% of the canvas on every side.
- Do not rely on tiny UI labels to communicate the value proposition.
- If showing a device frame, keep all overlay text outside the bezel area unless intentionally built into the mockup.
- Use portrait layouts unless the app is clearly landscape-first.

## Composition Patterns

Choose one pattern per slot instead of improvising each frame.

| Pattern | Best for | Rule |
|---|---|---|
| Device frame + headline | most app listings | safest default for clarity |
| Full-bleed UI | visually strong product screens | use when the UI itself is beautiful and readable |
| Feature callout | complex feature explanation | one primary callout cluster only |
| Lifestyle composite | emotional or aspirational categories | keep the app screen clearly legible |
| Before/after split | transformation products | use only when the comparison is instantly obvious |

## Consistency Rules Across the Set

- Reuse the same background family, headline style, and accent treatment.
- Keep the device angle/frame treatment consistent unless you intentionally reserve one standout hero frame.
- Use the same overlay placement system across all screenshots.
- Keep the visual density similar across slots so one frame does not feel like a different campaign.

## AI Prompt Template

When an agent must actually generate or draw screenshots, create one structured prompt per slot:

```markdown
### Screenshot [N]
- Goal: [what this slot must communicate]
- Audience: [who this is for]
- Core promise: [benefit]
- Device size: [e.g. iPhone 6.7" 1290x2796]
- Composition pattern: [device frame / full-bleed / callout / lifestyle / before-after]
- UI focus: [screen and state to show]
- Overlay: "[headline]"
- Visual style: [clean/minimal/premium/playful/etc.]
- Background treatment: [solid/gradient/context scene]
- Consistency notes: [how it should match the rest of the set]
- Avoid: [onboarding, settings, stale status bar, loading states, dense copy]
```

If the app UI is not available, specify the intended UI structure and ideal demo data before generating.

## Localization Guidance

- Translate the meaning, not just the words.
- Re-check line length per locale; short English overlays often expand in German, French, or Spanish.
- If a market has a different purchase trigger, adapt the message order, not only the language.
- Keep numerals, place names, and social proof culturally appropriate.
- Do not assume English line breaks will survive localization; reflow each overlay per locale.

## Generated-Asset QA

- Readable at thumbnail size
- One clear focal point per screenshot
- Overlay remains under 2 lines
- Modern-looking device/UI treatment
- No stale timestamps, loading spinners, permission prompts, or dead-end empty states unless intentional
- The first 3 screenshots clearly communicate value, differentiation, and proof
- The full set looks like one campaign, not 5 unrelated images

## Common Mistakes

| Mistake | Why it hurts | Better move |
|---|---|---|
| Showing onboarding first | sells friction instead of value | show in-use outcome first |
| Showing settings | communicates maintenance, not benefit | show the strongest user result |
| Repeating the same layout | gives no reason to scroll | vary composition and message |
| Feature-name overlays | low emotional pull | rewrite as user outcome |
| Too much text | unreadable at thumbnail size | keep one short promise |
| Randomizing style between shots | breaks campaign coherence | keep one visual system across the full set |
| Using undefined UI states | creates weak or generic output | define the exact screen state and demo data |

## Output Format

When asked to design a screenshot set, return:

```markdown
## App Store Screenshot Plan

### Positioning
- Audience: [who]
- Core promise: [one sentence]
- Story arc: [selected pattern]

### Shot List
1. **Slot 1 — [goal]**
   - Overlay: "[headline]"
   - UI focus: [screen/state]
   - Visual direction: [background/framing/callout]
   - Generation notes: [size/pattern/avoid list]

2. **Slot 2 — [goal]**
   - Overlay: "[headline]"
   - UI focus: [screen/state]
   - Visual direction: [background/framing/callout]
   - Generation notes: [size/pattern/avoid list]

3. **Slot 3 — [goal]**
   - Overlay: "[headline]"
   - UI focus: [screen/state]
   - Visual direction: [background/framing/callout]
   - Generation notes: [size/pattern/avoid list]

### Production Settings
- Target device class: [6.7" / 6.5" / iPad / etc.]
- Composition system: [chosen pattern family]
- Visual consistency rules: [shared background, typography, framing]

### Localization Notes
- [locale-specific note]

### Review Checklist
- First 3 screenshots communicate value, differentiation, and proof
- Each overlay is benefit-led and short
- The full set has visual variety without losing consistency
- No screenshot leads with onboarding, settings, or low-value infrastructure
- Every screenshot has generation-ready instructions
- Output matches device size and safe-zone constraints

### Escalate?
- [yes/no and why]
```

## Quick Decision Rule

If you are unsure what to show, ask:

1. What is the app's fastest visible value?
2. What makes it different?
3. What screen proves that claim best?

Those answers usually define screenshots 1 to 3.
