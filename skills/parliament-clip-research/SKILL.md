---
name: parliament-clip-research
description: Context for working with UK Parliament clips from Parliament Connect — what the library covers, what makes a query land, and which link to share. Use when someone asks what an MP said in Parliament, or wants a clip or quote from a Commons debate.
---

# Working with Parliament Connect clips

Four things the tools themselves do not tell you. Everything else about how the
tools behave — how matching works, what the filters mean, how results are paged
— is described by the tools and is authoritative there.

## What the library covers

**House of Commons chamber sittings only.** No House of Lords, no select or
public bill committees, no Westminster Hall, no devolved legislatures.

This matters because a question about any of those returns no matches rather
than an error, and no-matches reads like "they never said it" when it actually
means "that room is not covered". Say which it is.

The same applies to people: a member of the Lords resolves as a member, and
then has no clips — because their chamber is not captured, not because they
were silent.

## What makes a query land

Matching runs on what was spoken. A half-remembered sentence in the speaker's
own words tends to find the moment; a topic label tends not to, because nobody
says "housing policy" out loud in a debate about it.

A narrow first query and then one rephrasing usually gets there faster than
several broad ones fired at once. Each result already carries an excerpt of the
transcript around the match, which is often enough to answer the question or to
tell which clip is the right one — opening the full transcript is the step for
when it is not.

## Which link to share

Every clip has two.

- The **anonymous share link** plays the video for anyone who opens it, with no
  sign-in. This is the one for a journalist, a constituent, a post, or anyone
  outside the office.
- The **Clip Library link** opens the clip inside Parliament Connect and needs a
  signed-in account with access. This is the one for the office's own workflow.

Sending the second to someone outside the account gives them a sign-in wall.

## If no Parliament Connect capability is available

Two different causes, and they need different fixes:

- **Signed in but not yet connected** — the connection exists and is waiting for
  authorisation. In Claude Code run `/mcp` and authenticate. In Codex run
  `codex mcp login parliament-connect`. In Cowork use the Connect prompt shown
  in the conversation.
- **Nothing registered at all** — the plugin's server was not picked up, which
  usually means the harness predates support for it. Check the version before
  chasing an authentication problem that is not one.

There is no API key to create or paste in either case.
