# CLAUDE.md — Agent Instructions for TicketForge

## 1. Context

- The user is a beginner. The user has zero experience with this type of system.
- The user must learn while the project is built.
- The learning process must not stop or slow the build.
- Write all documents in simple English. Use short sentences.

## 2. Documents

Make these files in the `docs/` folder at the start of the project.

```
docs/
├── DECISIONS.md
├── CONCEPTS.md
├── LEARNING_LOG.md
├── QUESTIONS.md
├── MISTAKES.md
├── ARCHITECTURE.md
├── RUNBOOK.md
└── INTERVIEW.md
```

| File | Purpose |
|---|---|
| DECISIONS.md | Records each technical decision and the reason for it. |
| CONCEPTS.md | Explains each new concept in simple words. |
| LEARNING_LOG.md | Records what was built and learned in each session. |
| QUESTIONS.md | Contains the questions of the user, with answers. |
| MISTAKES.md | Records each bug, its cause, and its fix. |
| ARCHITECTURE.md | Shows the full system, the services, and the data flow. |
| RUNBOOK.md | Gives the steps to start, test, deploy, and debug the system. |
| INTERVIEW.md | Contains interview questions about this project, with answers. |

## 3. Rules

1. After each task, update the related documents in `docs/`.
2. For each technical decision, add an entry to DECISIONS.md.
3. For each new concept, add an entry to CONCEPTS.md.
4. At the end of each session, add an entry to LEARNING_LOG.md.
5. For each bug or failure, add an entry to MISTAKES.md.
6. When the architecture changes, update ARCHITECTURE.md. Use Mermaid diagrams.
7. When a command or a setup step changes, update RUNBOOK.md.
8. At the end of each session, answer all open items in QUESTIONS.md.
9. For each completed feature, add 3 questions and answers to INTERVIEW.md.
10. Keep each entry short. Do not write more than 10 lines for one entry.
11. Do not stop the build to teach. Write the explanation in the documents.
12. Do not delete old decisions. Mark them as replaced and link the new decision.
13. In the code, add a short comment that links to the related decision ID (example: `// See D-004`).

## 4. Templates

### DECISIONS.md

```
## D-001: <Decision title>
Date:
Status: Accepted | Replaced by D-00X
Problem:
Options:
Decision:
Reason:
Disadvantages:
Related concepts:
```

### CONCEPTS.md

```
## <Concept name>
Definition: <one or two simple sentences>
Why we use it: <the problem it solves>
Example in this project: <short example>
Location in code: <file path>
Related decisions: <D-00X>
```

### LEARNING_LOG.md

```
## Session <number> — <date>
Built:
New concepts:
Decisions made:
Problems found:
Next step:
```

### QUESTIONS.md

```
## Q-001: <question>
Status: Open | Answered
Answer:
```

### MISTAKES.md

```
## M-001: <short title>
Symptom:
Cause:
Fix:
Lesson:
```

### INTERVIEW.md

```
## <Feature name>
Q: <question>
A: <answer in 3 to 5 sentences>
```

## 5. End of Session Checklist

Do these steps before the session ends:

- [ ] DECISIONS.md is updated.
- [ ] CONCEPTS.md is updated.
- [ ] LEARNING_LOG.md has a new entry.
- [ ] All open items in QUESTIONS.md have answers.
- [ ] MISTAKES.md is updated, if a bug occurred.
- [ ] ARCHITECTURE.md is updated, if the architecture changed.
- [ ] RUNBOOK.md is updated, if a command changed.
- [ ] INTERVIEW.md is updated, if a feature is complete.
