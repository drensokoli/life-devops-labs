'use client';

import { useState, useEffect } from 'react';

interface ShortenedUrl {
  id: number;
  code: string;
  originalUrl: string;
  createdAt: string;
  clickCount: number;
}

interface ShortenResponse {
  code: string;
  short_url: string;
  original_url: string;
  created_at: string;
}

export default function Home() {
  const [url, setUrl] = useState('');
  const [recent, setRecent] = useState<ShortenedUrl[]>([]);
  const [result, setResult] = useState<ShortenResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

  async function fetchRecent() {
    try {
      const res = await fetch(`${apiUrl}/api/urls`);
      if (res.ok) setRecent(await res.json());
    } catch (err) {
      console.log('Failed to fetch URLs:', err);
    }
  }

  async function shortenUrl(e: React.FormEvent) {
    e.preventDefault();
    if (!url.trim()) return;
    setLoading(true);
    setError('');
    setResult(null);
    try {
      const res = await fetch(`${apiUrl}/api/shorten`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url: url.trim() }),
      });
      const data = await res.json();
      if (res.ok) { setResult(data); setUrl(''); await fetchRecent(); }
      else setError(data.error || 'Failed to shorten');
    } catch {
      setError('Cannot connect to backend API');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { fetchRecent(); }, []);

  return (
    <main className="container">
      <h1>LIFE Shortener</h1>
      <p className="lead">Paste a URL, get a short code.</p>
      <form onSubmit={shortenUrl} className="form">
        <input type="url" value={url} onChange={(e) => setUrl(e.target.value)}
          placeholder="https://example.com/long/url" disabled={loading} />
        <button type="submit" disabled={loading || !url.trim()}>
          {loading ? 'Shortening...' : 'Shorten'}
        </button>
      </form>
      {error && <p className="error">{error}</p>}
      {result && (
        <div className="result">
          <p>Short URL:</p>
          <code>{result.short_url}</code>
          <p className="orig">→ {result.original_url}</p>
        </div>
      )}
      <h2>Recently shortened ({recent.length})</h2>
      {recent.length === 0
        ? <p className="empty">No URLs yet. Be the first.</p>
        : <ul>{recent.map((r) => (
            <li key={r.id}><code>{r.code}</code><span>{r.originalUrl}</span></li>
          ))}</ul>
      }
    </main>
  );
}
