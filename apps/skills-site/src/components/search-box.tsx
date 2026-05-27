"use client";

import { useEffect, useRef, useState, useTransition } from "react";
import { useRouter, useSearchParams, usePathname } from "next/navigation";

/**
 * Debounced search input. Mirrors `?q=` into the URL via shallow router
 * push so server component on / re-runs with the new filter. Preserves
 * `source` param.
 */
export function SearchBox({ initial = "" }: { initial?: string }) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const [value, setValue] = useState(initial);
  const [, startTransition] = useTransition();
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    // Sync external nav changes back to local state.
    setValue(params.get("q") ?? "");
  }, [params]);

  function push(next: string) {
    const sp = new URLSearchParams(params.toString());
    if (next) sp.set("q", next.slice(0, 100));
    else sp.delete("q");
    const qs = sp.toString();
    startTransition(() => {
      router.replace(`${pathname}${qs ? `?${qs}` : ""}`, { scroll: false });
    });
  }

  function onChange(e: React.ChangeEvent<HTMLInputElement>) {
    const v = e.target.value;
    setValue(v);
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(() => push(v), 180);
  }

  function clear() {
    setValue("");
    if (timer.current) clearTimeout(timer.current);
    push("");
  }

  return (
    <div className="search-bar" role="search">
      <span className="search-icon" aria-hidden>⌕</span>
      <input
        type="search"
        name="q"
        value={value}
        onChange={onChange}
        maxLength={100}
        placeholder="Search skills by name, id, or description…"
        autoComplete="off"
        aria-label="Search skills"
      />
      {value && (
        <button
          type="button"
          onClick={clear}
          className="search-clear"
          aria-label="Clear search"
        >
          ×
        </button>
      )}
    </div>
  );
}
