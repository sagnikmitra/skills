"use client";

import { useState } from "react";

export function CopyLink({ path }: { path: string }) {
  const [copied, setCopied] = useState(false);

  async function copy() {
    const url = typeof window !== "undefined" ? `${window.location.origin}${path}` : path;
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      setTimeout(() => setCopied(false), 1400);
    } catch {
      // Clipboard blocked (e.g. insecure context). Fallback: select via prompt.
      window.prompt("Copy URL", url);
    }
  }

  return (
    <button
      type="button"
      onClick={copy}
      className="copy-link"
      aria-label={copied ? "Link copied" : "Copy permalink"}
    >
      {copied ? "✓ Copied" : "⎘ Copy link"}
    </button>
  );
}
