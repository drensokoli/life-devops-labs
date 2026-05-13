import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'LIFE DevOps Demo',
  description: 'Multi-stage Docker build demo',
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
