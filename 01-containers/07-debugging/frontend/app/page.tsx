'use client';

import { useState, useEffect } from 'react';

interface Student {
  id: number;
  name: string;
  registeredAt: string;
}

export default function Home() {
  const [name, setName] = useState('');
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

  async function fetchStudents() {
    try {
      console.log(`[Frontend] GET ${apiUrl}/api/students`);
      const res = await fetch(`${apiUrl}/api/students`);
      if (res.ok) {
        const data = await res.json();
        setStudents(data);
        setError('');
      }
    } catch (err) {
      console.log(`[Frontend] Failed to fetch students: ${err}`);
    }
  }

  async function registerStudent(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;

    setLoading(true);
    setError('');

    try {
      console.log(`[Frontend] POST ${apiUrl}/api/students { name: "${name}" }`);
      const res = await fetch(`${apiUrl}/api/students`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: name.trim() }),
      });

      if (res.ok) {
        setName('');
        await fetchStudents();
      } else {
        const data = await res.json();
        setError(data.error || 'Failed to register');
      }
    } catch (err) {
      setError('Cannot connect to backend API');
      console.log(`[Frontend] Error: ${err}`);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchStudents();
  }, []);

  return (
    <main style={{ maxWidth: 600, margin: '0 auto', padding: '2rem' }}>
      <h1 style={{ color: '#1a1a2e', marginBottom: '0.5rem' }}>
        LIFE-3 Student Registry
      </h1>
      <p style={{ color: '#666', marginBottom: '2rem' }}>
        Docker Debugging Demo — register your name and watch the logs
      </p>

      <form onSubmit={registerStudent} style={{ display: 'flex', gap: '0.5rem', marginBottom: '2rem' }}>
        <input
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Enter your name"
          disabled={loading}
          style={{
            flex: 1,
            padding: '0.75rem',
            fontSize: '1rem',
            border: '2px solid #e0e0e0',
            borderRadius: '6px',
            outline: 'none',
          }}
        />
        <button
          type="submit"
          disabled={loading || !name.trim()}
          style={{
            padding: '0.75rem 1.5rem',
            fontSize: '1rem',
            backgroundColor: '#1a1a2e',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: loading ? 'wait' : 'pointer',
            opacity: loading || !name.trim() ? 0.6 : 1,
          }}
        >
          {loading ? 'Saving...' : 'Register'}
        </button>
      </form>

      {error && (
        <p style={{ color: '#dc3545', marginBottom: '1rem' }}>{error}</p>
      )}

      <h2 style={{ color: '#333', marginBottom: '1rem' }}>
        Registered Students ({students.length})
      </h2>

      {students.length === 0 ? (
        <p style={{ color: '#999' }}>No students registered yet. Be the first!</p>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {students.map((s) => (
            <li
              key={s.id}
              style={{
                padding: '0.75rem 1rem',
                marginBottom: '0.5rem',
                backgroundColor: '#f8f9fa',
                borderRadius: '6px',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
              }}
            >
              <span style={{ fontWeight: 500 }}>{s.name}</span>
              <span style={{ color: '#999', fontSize: '0.85rem' }}>
                {new Date(s.registeredAt).toLocaleTimeString()}
              </span>
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}
