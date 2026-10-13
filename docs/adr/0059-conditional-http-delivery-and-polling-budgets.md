# Deliver certified availability through conditional HTTP and bounded polling

Status: Accepted. Date: 2026-10-11. Decision: D-059.

A waiting room does not bound public read fanout, and unchanged bytes do not prove freshness. Use jittered conditional HTTP polling, initially at least five seconds between private queue polls and one second between visible detail refreshes, with up to two sections and one in-flight detail refresh. Keep anonymous detailed browsing, validate proof before 200 or 304, and bind proof headers to the exact stable representation derived from one certified frame. Separate private status, public read and checkout resources; preserve original admission deadlines and model request, authentication, connection and egress costs explicitly. See D-059 and Review 059 for cache/client age rules, admission delivery health, unproved capacity and free-deployment gaps; retain the 1M active-user requirement and every original SLO.
