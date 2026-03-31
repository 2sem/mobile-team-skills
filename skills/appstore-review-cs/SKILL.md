---
name: appstore-review-cs
description: Use when the cs agent needs to fetch App Store reviews or submit responses through the App Store Connect customer review workflow.
---

# Appstore Review CS

Use the external App Store skill installed at `~/.config/opencode/skills/appstore`.

## Workflow

1. Get the numeric app ID if needed: `getappid {bundle_id}`
2. Fetch reviews: `reviews {app_id} {count?}`
3. Submit a response: `response {review_id}`

## Requirements

- Use the external `appstore` skill for command execution details and auth setup.
- Always include the **Review ID** when reporting actionable feedback to the reporter agent.
- Preserve review categorization: Bug, Feature Request, Question, Praise, Complaint.

## Example

```text
getappid com.2sem.wherewego
reviews 1234567890 5
response 00000046-ea46-3002-cf40-2d5b00000000
```
