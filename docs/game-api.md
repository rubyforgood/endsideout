# Game API

This document tells game developers how a game reports play to the EndsideOut LMS.
A game runs inside an iframe (a web page embedded in another page). The LMS shows the iframe to a signed-in student.

## How a game starts

The LMS loads your game at this address:

```
https://<game host>/games/<slug>?token=<token>
```

The `slug` is the short name of the game in the LMS. The `token` is a signed value that identifies one play session of one student.
The token is a GET parameter (a value in the URL query string).

When your game loads, read the `token` from the URL. For example:

```js
const token = new URLSearchParams(window.location.search).get("token")
```

Send this exact value in every call to the LMS. Do not change it, and do not decode it.
If the game loads without a `token`, the game cannot report play. In that case, do not call the API.

## Hosts

| Environment | Game host | LMS host |
| --- | --- | --- |
| Production | `endsideoutgames.netlify.app` | `LMS_HOST` (ask EndsideOut for the production address) |
| Staging | `staging--endsideout-games.netlify.app` | `LMS_HOST` (ask EndsideOut for the staging address) |

Only a game that runs on the matching game host can call the LMS from a browser.
A call from any other origin fails the browser CORS check (the browser rule for calls between sites).

## Request rules

- Send a `POST` request with the header `Content-Type: application/json`.
- Put the `token` in the JSON body.
- Do not send cookies. Do not send a CSRF token. The `token` is the only credential.
- Every response is JSON with a `status` field. The value is `ok` or `error`. An error also has a `message`.

## Start a game

When the student begins to play, call this once.

```
POST https://LMS_HOST/game_attempts/start
```

Body:

```json
{ "token": "<token>" }
```

Success response, status 200:

```json
{ "status": "ok" }
```

Example:

```js
await fetch(`https://${LMS_HOST}/game_attempts/start`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ token })
})
```

## Finish a game

When the student finishes the game, call this once. You must call `start` first.

```
POST https://LMS_HOST/game_attempts/finish
```

Body:

```json
{
  "token": "<token>",
  "game_attempt": { "outcome": "win", "score": 100 }
}
```

The `game_attempt` fields are:

| Field | Type | Meaning |
| --- | --- | --- |
| `outcome` | string | The result of the play, for example `win`. |
| `score` | integer | The score of the student. |

Success response, status 200:

```json
{ "status": "ok" }
```

Example:

```js
await fetch(`https://${LMS_HOST}/game_attempts/finish`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ token, game_attempt: { outcome: "win", score: 100 } })
})
```

## Errors

If a call fails, it returns status 422.

| Message | Cause | Fix |
| --- | --- | --- |
| `Invalid token` | The token is missing, changed, or not from the LMS. | Send the `token` from the page URL without any change. |
| `Game attempt has not been started` | You called `finish` before `start`. | Call `start` first. |

## Try it with curl

Replace `<token>` with a token from a game page URL.

```sh
curl -X POST https://LMS_HOST/game_attempts/start \
  -H "Content-Type: application/json" \
  -d '{"token":"<token>"}'

curl -X POST https://LMS_HOST/game_attempts/finish \
  -H "Content-Type: application/json" \
  -d '{"token":"<token>","game_attempt":{"outcome":"win","score":100}}'
```
