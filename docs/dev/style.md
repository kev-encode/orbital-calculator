# Style Guide

## Codebase Priorities

Performant, skimmable, sparse code; no standard

## Naming Conventions

All names should be as concise as possible.

* **Variables:** snake case and screaming snake case; clear, explicit (e.g., `loading_bar`, `SCREEN_WIDTH`)
* **Functions:** camel case; short, implicit (e.g., `print()`)
* **Classes:** pascal case; short, clear (e.g., `QTWidget`)

## Commenting Conventions

* Be concise
* Use conventional comments (e.g., `note`, `to-do`)
* Only comment when necessary and explain the why

```python
# note: print() doesn't work
# to-do: add error handling
```

Comment types:

* `praise`: highlights something positive
* `nitpick`: points out trivial or preference-based
* `suggestion`: proposes an improvement
* `issue`: highlights a problem
* `to-do`: marks a necessary task
* `question`: asks for clarification
* `thought`: shares an idea or observation

## Commit Conventions

* Use conventional commits  (e.g., `feat`, `chore`)
* Use scope (e.g., `docs(readme)`, `refactor(main)`)
* If breaking change, use `!`, a body, and a footer (e.g., `feat(api)!`,  `-m "BREAKING CHANGE: ..."`, `-m "Refs: ..."`)
* Only use body if change is complex, constrasting, or contains new design decisions
* Only use footers if there is a body and to track breaking changes, issues, or acknowledgements

```bash
git commit -m "docs(readme): update project description"
# breaking change commit
git commit -m "feat(window)!: add new button" -m "..." -m "BREAKING CHANGE: ..."
# new issue commit
git commit -m "chore(auth): add failure token test" -m "..." -m "Refs: NEW-ISSUE ()"
# contribution to issue solution
git commit -m "chore(auth): add token test" -m "..." -m "Refs: #..."
# resolving an issue
git commit -m "fix(auth): resolve token failure" -m "..." -m "Closes: #..."
```

Commit types:

* `feat`: new feature (user end or codebase)
* `fix`: patches a bug
* `docs`: adds or updates documentation
* `style`: improves code structure or formatting
* `refactor`: modifies code logic
* `perf`: improves performance
* `test`: adds missing tests or corrects existing tests
* `chore`: handles routine maintenance or tasks
* `build`: affects the build system or external dependencies
* `ci`: changes continuous integration configuration
* `revert`: reverts a previous commit