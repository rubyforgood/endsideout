# Game API

This document tells game developers how a game reports play to the EndsideOut LMS.
A game runs inside an iframe (a web page embedded in another page). The LMS shows the iframe to a signed-in student.

## Summary
- The LMS loads your game in an iframe with a `token` GET parameter in the URL.
- The game calls the LMS API using the token to report when the game starts and finishes.

## API Request Documentation

### Start a game

```http
POST https://LMS_HOST/game_attempts/start
Content-Type: application/json
```

**Request Body Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "token": {
      "type": "string",
      "description": "The signed token from the URL."
    }
  },
  "required": ["token"]
}
```

**Example**
```json
{ 
  "token": "abcd" 
}
```

### Finish a game

```http
POST https://LMS_HOST/game_attempts/finish
Content-Type: application/json
```

**Request Body Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "token": {
      "type": "string",
      "description": "The signed token from the URL."
    },
    "game_attempt": {
      "type": "object",
      "properties": {
        "outcome": {
          "type": "string",
          "description": "The result of the play.",
          "enum": ["game_completed", "game_over"]
        },
        "score": {
          "type": "integer",
          "description": "The score of the student."
        }
      },
      "required": ["outcome"]
    }
  },
  "required": ["token", "game_attempt"]
}
```

**Example**
```json
{ 
  "token": "abcd",
  "game_attempt": {
    "outcome": "game_completed",
    "score": 93
  }
}
```


## Details

The LMS loads the game in an iframe using the following URL:

```
https://<game host>/<slug>?token=<token>
```

The `slug` is the unique name of the game, such as `fruit-veggie-quiz`. The `token` is a signed value that identifies one play session of one student.
The token is a GET parameter (a value in the URL query string).

When your game loads, read the `token` from the URL. For example:

```js
const token = new URLSearchParams(window.location.search).get("token")
```

Send this exact value in every call to the LMS. Do not change it, and do not decode it.
If the game loads without a `token`, the game cannot report play. In that case, do not call the API.

## Hosts

| Environment | Game host | LMS host                         |
| --- | --- |----------------------------------|
| Production | `endsideoutgames.netlify.app` | classroom.endsideout.org         |
| Staging | `staging--endsideout-games.netlify.app` | staging-classroom.endsideout.org |

Only a game that runs on the matching game host can call the LMS from a browser.
A call from any other origin fails the browser CORS check.

## Request rules

- Send a `POST` request with the header `Content-Type: application/json`.
- Put the `token` in the JSON body.
- Do not send cookies. Do not send a CSRF token. The `token` is the only credential.
- Every response is JSON with a `status` field. The value is `ok` or `error`. An error also has a `message`.


## Errors

If a call fails, it returns status 422.

| Message | Cause | Fix |
| --- | --- | --- |
| `Invalid token` | The token is missing, changed, or not from the LMS. | Send the `token` from the page URL without any change. |
| `Game attempt has not been started` | You called `finish` before `start`. | Call `start` first. |
