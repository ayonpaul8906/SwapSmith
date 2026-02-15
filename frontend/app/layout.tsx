'use client'

import './globals.css'
import { Inter } from 'next/font/google'
import { Providers } from './providers'

const inter = Inter({ subsets: ['latin'] })

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body
        className={`${inter.className} min-h-screen selection:bg-blue-500/30`}
        style={{ backgroundColor: 'rgb(var(--background))', color: 'rgb(var(--foreground))' }}
      >
        {/* Animated Background Mesh */}
        <div className="fixed inset-0 z-[-1]">
          <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-blue-600/10 blur-[120px]" />
          <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-purple-600/10 blur-[120px]" />
        </div>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}