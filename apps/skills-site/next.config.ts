import type { NextConfig } from "next";

const config: NextConfig = {
  reactStrictMode: true,
  // Public, static-friendly site. Skills content is read at build/request time
  // from the canonical registry at the repo root, NOT bundled at build.
  experimental: {
    typedRoutes: true,
  },
};

export default config;
