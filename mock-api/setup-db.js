/**
 * Run ONCE before starting the mock API server.
 * Generates db.json with properly bcrypt-hashed passwords.
 *
 * Usage: node setup-db.js
 */
const bcryptjs = require('bcryptjs');
const fs = require('fs');

const hash = bcryptjs.hashSync('password123', 10);

const db = {
  users: [
    {
      id: 1,
      email: 'test@example.com',
      password: hash,
      name: 'John Doe',
    },
  ],
  tasks: [
    {
      id: 1,
      title: 'Design system architecture',
      description:
        'Define the component library and design tokens for the new product dashboard. Includes color palette, typography, spacing, and component specs.',
      status: 'done',
      priority: 'high',
      dueDate: '2026-03-28',
      assignedUser: 'John Doe',
    },
    {
      id: 2,
      title: 'Implement authentication flow',
      description:
        'Set up JWT-based auth with refresh token support and secure storage. Handle auto-login on restart and 401 redirect.',
      status: 'done',
      priority: 'high',
      dueDate: '2026-04-02',
      assignedUser: 'Jane Smith',
    },
    {
      id: 3,
      title: 'Build task list UI',
      description:
        'Create the main task list screen with filtering (status, priority) and title search. Use shimmer loading and empty state illustration.',
      status: 'in_progress',
      priority: 'high',
      dueDate: '2026-04-10',
      assignedUser: 'John Doe',
    },
    {
      id: 4,
      title: 'Write unit tests for providers',
      description:
        'Cover all Riverpod providers and repository implementations with unit tests. Target 80%+ coverage.',
      status: 'in_progress',
      priority: 'medium',
      dueDate: '2026-04-15',
      assignedUser: 'Alex Johnson',
    },
    {
      id: 5,
      title: 'Setup CI/CD pipeline',
      description:
        'Configure GitHub Actions for automated testing, building, and deployment. Include lint checks and test reporting.',
      status: 'todo',
      priority: 'medium',
      dueDate: '2026-04-20',
      assignedUser: 'Jane Smith',
    },
    {
      id: 6,
      title: 'Performance optimization',
      description:
        'Profile and optimize the app for 60fps scroll performance and reduced memory usage. Use DevTools to identify bottlenecks.',
      status: 'todo',
      priority: 'low',
      dueDate: '2026-04-30',
      assignedUser: 'Alex Johnson',
    },
  ],
};

fs.writeFileSync('db.json', JSON.stringify(db, null, 2));
console.log('✅ db.json generated successfully!');
console.log('🔑 Login credentials: test@example.com / password123');
