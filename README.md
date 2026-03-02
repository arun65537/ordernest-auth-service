# Auth Service

Spring Boot authentication service with JWT-based login and PostgreSQL persistence.

## Tech Stack
- Java 17
- Spring Boot 3.3.2
- Spring Security
- Spring Data JPA
- PostgreSQL
- JWT (`jjwt`)

## Prerequisites
- JDK 17+
- PostgreSQL (or compatible managed PostgreSQL, such as Neon)
- Gradle wrapper (included)

## Configuration
Application settings are in `src/main/resources/application.properties`.

Current project values include:
- `spring.datasource.url`
- `spring.datasource.username`
- `spring.datasource.password`
- `spring.jpa.hibernate.ddl-auto=validate`

`ddl-auto=validate` means required tables must already exist in the database.

## Run Locally
```bash
./gradlew bootRun
```

On Windows PowerShell:
```powershell
.\gradlew.bat bootRun
```

Default server URL: `http://localhost:8080`

## API
Base path: `/api/auth`

### Endpoint Flow Diagram
```mermaid
flowchart TD
    C[Client / ordernest-web]
    DB[(PostgreSQL)]

    subgraph AUTH[ordernest-auth-service - /api/auth]
      R["POST /register<br/>Public<br/>Req: RegisterRequest<br/>Res: 201 MessageResponse"]
      L["POST /login<br/>Public<br/>Req: LoginRequest<br/>Res: 200 AuthResponse (JWT)"]
      M["GET /me<br/>Protected (Bearer JWT)<br/>Res: 200 UserInfoResponse"]
    end

    C --> R
    C --> L
    C -->|"Authorization: Bearer &lt;jwt&gt;"| M
    R -->|"Create user (INSERT)"| DB
    L -->|"Validate user (SELECT)"| DB
    M -->|"Fetch current user (SELECT)"| DB
```

### 1) Register User
- Method: `POST`
- URL: `/api/auth/register`

Request body:
```json
{
  "email": "arun@example.com",
  "password": "Arun@1234",
  "firstName": "arun",
  "lastName": ""
}
```

Success response:
- Status: `201 Created`
- Body:
```json
{
  "message": "User registered successfully"
}
```

Possible errors:
- `400 Bad Request` (validation)
- `409 Conflict` (email already exists)

### 2) Login
- Method: `POST`
- URL: `/api/auth/login`

Request body:
```json
{
  "email": "arun@example.com",
  "password": "Arun@1234"
}
```

Success response:
- Status: `200 OK`
- Body:
```json
{
  "token": "<jwt-token>"
}
```

Possible errors:
- `400 Bad Request` (validation)
- `401 Unauthorized` (invalid credentials or inactive user)

## Notes
- JWT expiry is currently 1 hour.
- JWT signing secret is hardcoded in `JwtService`; move this to environment/config before production use.
- Passwords are stored using BCrypt hashing.
