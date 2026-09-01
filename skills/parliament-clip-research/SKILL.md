---
name: parliament-clip-research
description: Context for working with UK Parliament clips from Parliament Connect — what the library covers, what makes a query land, and which link to share. Use when someone asks what an MP said in Parliament, or wants a clip or quote from a Commons debate or committee session on a particular subject.
---

# Working with Parliament Connect clips

Five things the tools themselves do not tell you. Everything else about how the
tools behave — how matching works, what the filters mean, how results are paged
— is described by the tools and is authoritative there.

## Nothing here comes from memory

A question about what was said in Parliament is a search, including when the
answer feels well known. Recall about a debate is not evidence about it, and
this library is the only source a citation from here can rest on.

So nothing reaches the reader that a tool call in this conversation did not
return — not a link, a clip id, a quote, a speaker or a sitting date. If the
search was not run, say that rather than answering anyway: invented
parliamentary content is indistinguishable from the real thing to whoever reads
it, and an MP's office may publish it.

## What the library covers

**House of Commons chamber sittings, plus — from September 2026 — parliamentary
committee sessions**: select, Lords and delegated legislation committees, any
sitting listed as a committee. Not in the library: the House of Lords
chamber, Westminster Hall, and the devolved legislatures. Public bill
committees are listed by bill name rather than as committees, so they are not
picked up. Committee coverage is forward-only — sittings from before September
2026 were never captured.

This matters because a question about an uncovered room — or a committee moment
from before September 2026 — returns no matches rather than an error, and
no-matches reads like "they never said it" when it actually means "that room,
or that date, is not covered". Say which it is.

The same applies to people: a member of the Lords resolves as a member. Their
chamber is not captured, so a clip of one could only come from a committee
session — an empty result there is the coverage boundary, not silence.

## What makes a query land

A half-remembered sentence in the speaker's own words tends to find the moment;
a topic label tends not to, because nobody says "housing policy" out loud in a
debate about it.

A narrow first query and then one rephrasing usually gets there faster than
several broad ones fired at once. The excerpt on each result is often enough to
answer the question or to tell which clip is the right one — opening the full
transcript is the step for when it is not.

## Which link to share

The anonymous link is for anyone outside the office — a journalist, a
constituent, a post. The Clip Library link is for the office's own workflow.
Sending the second to someone outside the account gives them a sign-in wall.

Most clips have both, but not all: a clip with no playable source video has no
anonymous link. When that happens, say the clip cannot be shared anonymously
rather than handing over the Clip Library link as a substitute — that is the
sign-in wall this section exists to avoid.

## "What has my MP said this week?"

This one needs care, because it sounds like a listing and the library only does
search. There is no way to ask for everything a member said in a window — every
query needs a subject. So establish what they are actually looking for: a topic,
the office's standing subjects, or the constituency name.

Then say what came back honestly. It is "clips matching what you asked about in
that window", never "everything they said". An empty result means nothing
matched that search in that window — it does not mean the member was silent, and
it does not tell you whether the House was even sitting. If nothing lands,
widening the dates backwards to find their most recent clip is more useful than
reporting a blank week.

Standing alerts are not something to set up from here. Parliament Connect has
monitors for that in the web app; this connector only reads.

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
