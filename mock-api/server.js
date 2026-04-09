const jsonServer = require('json-server')
const auth = require('json-server-auth')
const path = require('path')

const app = jsonServer.create()
const router = jsonServer.router(path.join(__dirname, 'db.json'))
const middlewares = jsonServer.defaults()

// REQUIRED: bind the router db to the app for json-server-auth to work
app.db = router.db

// Rewrite rules — applies 660 permissions to /tasks (auth required for read+write)
const rules = auth.rewriter({
  '/tasks*': '/660/tasks$1',
})

// Order matters:
// 1. Default middlewares (logger, static, cors, no-cache)
app.use(middlewares)
// 2. Route rewriter (auth guard rules)
app.use(rules)
// 3. json-server-auth (provides /login, /register, JWT guard)
app.use(auth)
// 4. Main router (handles /tasks, /users etc.)
app.use(router)

const PORT = 3000
app.listen(PORT, () => {
  console.log(`\n  {^_^} JSON Server with Auth is running!\n`)
  console.log(`  Resources`)
  console.log(`  http://localhost:${PORT}/users`)
  console.log(`  http://localhost:${PORT}/tasks\n`)
  console.log(`  Auth endpoints`)
  console.log(`  POST http://localhost:${PORT}/login`)
  console.log(`  POST http://localhost:${PORT}/register\n`)
  console.log(`  Credentials: test@example.com / password123\n`)
})
