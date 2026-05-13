import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'LIFE-3 Student Registry',
  description: 'Register students for the LIFE-3 DevOps course',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body style={{ margin: 0, fontFamily: 'system-ui, -apple-system, sans-serif' }}>
        {children}
      </body>
    </html>
  );
}
