import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Create Next App",
  description: "Generated by create next app",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <header className="border-neutral-border mx-auto mb-2 flex max-w-[90rem] items-baseline gap-4 border-b-[1px] px-4 pb-2 pt-4">
          <a className="block" href="/list">
            <h1 className="text-4xl font-bold">Todo List</h1>
          </a>
          <nav className="flex-grow items-center pb-1 md:flex">
            <div className="ml-auto">
              <button>Sign out</button>
              {/* <button onClick={() => signOut()}>Sign out</button> */}
            </div>
          </nav>
        </header>
        <main>{children}</main>
      </body>
    </html>
  );
}
