import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'LIFE Shortener',
  description: 'Paste a URL, get a short code.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
