# Mock API — TaskFlow

A [json-server](https://github.com/typicode/json-server) + [json-server-auth](https://github.com/jeremyben/json-server-auth) backend for the TaskFlow Flutter app.

## Setup & Run

```bash
# 1. Install dependencies
npm install

# 2. Generate db.json with hashed passwords (run ONCE before first start)
npm run setup

# 3. Start the server
npm start
```

Server runs at: **http://localhost:3000**

## Credentials

| Field | Value |
|-------|-------|
| Email | `test@example.com` |
| Password | `password123` |

## Endpoints

| Method | Endpoint | Auth required |
|--------|----------|--------------|
| POST | `/login` | No |
| POST | `/register` | No |
| GET | `/tasks` | ✅ Yes |
| POST | `/tasks` | ✅ Yes |
| PUT | `/tasks/:id` | ✅ Yes |
| DELETE | `/tasks/:id` | ✅ Yes |

## Login Response

```json
{
  "accessToken": "<JWT token>",
  "user": {
    "id": 1,
    "email": "test@example.com",
    "name": "John Doe"
  }
}
```

Include the token in all subsequent requests:
```
Authorization: Bearer <accessToken>
```