import type { Metadata } from "next"
import "./globals.css"

export const metadata: Metadata = {
  title: "GoBoilerplate",
  description:
    "A modern full-stack boilerplate with Go backend and Next.js frontend.",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
